import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../domain/entities/owner_dashboard_entities.dart';
import '../controllers/owner_dashboard_controller.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  late final OwnerDashboardController _controller;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _controller = createOwnerDashboardController();
    _loadFuture = _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CavaAppBar(title: 'Dashboard', showBack: false),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, _) {
          return ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return RefreshIndicator(
                color: AppColors.burgundy,
                onRefresh: _controller.refresh,
                child: _buildBody(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_controller.status) {
      case OwnerDashboardViewStatus.initial:
      case OwnerDashboardViewStatus.loading:
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: const [
            SizedBox(height: 120),
            Center(child: CircularProgressIndicator(color: AppColors.burgundy)),
          ],
        );
      case OwnerDashboardViewStatus.error:
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            const SizedBox(height: 80),
            Text(
              _controller.sectionError ?? 'Dashboard nuk u ngarkua.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: TextButton(
                onPressed: _controller.load,
                child: Text(
                  'Provo përsëri',
                  style: AppTextStyles.body.copyWith(color: AppColors.burgundy),
                ),
              ),
            ),
          ],
        );
      case OwnerDashboardViewStatus.empty:
      case OwnerDashboardViewStatus.success:
      case OwnerDashboardViewStatus.refreshing:
        final snap = _controller.snapshot;
        if (snap == null) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'Nuk ka të dhëna ende.',
                    style: AppTextStyles.emptyState,
                  ),
                ),
              ),
            ],
          );
        }
        return _DashboardContent(
          snapshot: snap,
          isRefreshing:
              _controller.status == OwnerDashboardViewStatus.refreshing,
        );
    }
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.snapshot,
    required this.isRefreshing,
  });

  final OwnerDashboardSnapshot snapshot;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final s = snapshot.summary;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.sm,
        AppSpacing.screen,
        AppSpacing.xxxl,
      ),
      children: [
        if (isRefreshing)
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: LinearProgressIndicator(
              color: AppColors.burgundy,
              backgroundColor: AppColors.surfaceMuted,
            ),
          ),
        Text('Përmbledhje', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Burimi: statsDaily / stats (si Overview admin)',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.35,
          children: [
            _StatCard(
              label: 'Shitjet Sot',
              value: Formatters.currency(s.salesToday),
            ),
            _StatCard(
              label: 'Shitjet 7 ditë',
              value: Formatters.currency(s.salesLast7Days),
            ),
            _StatCard(
              label: 'Shitjet 30 ditë',
              value: Formatters.currency(s.salesLast30Days),
            ),
            _StatCard(
              label: 'Totali i të Ardhurave',
              value: Formatters.currency(s.totalRevenue),
            ),
            _StatCard(
              label: 'Numri i Porosive',
              value: '${s.totalOrders}',
            ),
            _StatCard(
              label: 'Porosi në Pritje',
              value: '${s.pendingOrders}',
            ),
            _StatCard(
              label: 'Porosi në Proces',
              value: '${s.processingOrders}',
            ),
            _StatCard(
              label: 'Porosi të Përfunduara',
              value: '${s.completedOrders}',
            ),
            _StatCard(
              label: 'Porosi të Anuluara',
              value: '${s.cancelledOrders}',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Grafiku i shitjeve', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '7 ditët e fundit (UTC, statsDaily.revenue)',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        _SalesChart(points: snapshot.chartLast7Days),
        const SizedBox(height: AppSpacing.xxl),
        Text('Porositë e fundit', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        if (snapshot.recentOrders.isEmpty)
          Text('Nuk ka porosi.', style: AppTextStyles.bodySmall)
        else
          ...snapshot.recentOrders.map(
            (o) => _ListTileCard(
              title: '#${o.orderNumber}',
              subtitle: '${o.customerName} · ${o.statusLabel}',
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Formatters.currency(o.total),
                    style: AppTextStyles.body,
                  ),
                  Text(o.paymentMethod, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Produktet më të shitura', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Nuk ofrohet në dashboard-in admin të website-it — pa agregim top-selling.',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Produkte me stok të ulët', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Pragu web: stock 1–9 · Numër: ${s.lowStockCount}',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        if (snapshot.lowStockProducts.isEmpty)
          Text(
            s.lowStockCount == 0
                ? 'Nuk ka produkte me stok të ulët.'
                : 'Lista nuk u lexua (kontrollo indeksin Firestore).',
            style: AppTextStyles.bodySmall,
          )
        else
          ...snapshot.lowStockProducts.map(
            (p) => _ListTileCard(
              title: p.name,
              subtitle: 'Pragu max: ${p.thresholdMax}',
              trailing: Text(
                '${p.stock}',
                style: AppTextStyles.h3.copyWith(color: AppColors.burgundy),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Klientët', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.sm),
        _ListTileCard(
          title: snapshot.newCustomers.label,
          subtitle: 'Si Overview admin — shuma e uniqueBuyerCount ditor',
          trailing: Text(
            '${snapshot.newCustomers.count}',
            style: AppTextStyles.h3.copyWith(color: AppColors.burgundy),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall,
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.h3.copyWith(color: AppColors.burgundy),
          ),
        ],
      ),
    );
  }
}

class _ListTileCard extends StatelessWidget {
  const _ListTileCard({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _SalesChart extends StatelessWidget {
  const _SalesChart({required this.points});

  final List<SalesChartPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text('Nuk ka të dhëna për grafikun.', style: AppTextStyles.bodySmall),
      );
    }

    final maxRevenue = points
        .map((p) => p.revenue)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final safeMax = maxRevenue <= 0 ? 1.0 : maxRevenue;

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < points.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor:
                            (points[i].revenue / safeMax).clamp(0.08, 1.0),
                        widthFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.burgundy.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    points[i].dateKey.length >= 10
                        ? points[i].dateKey.substring(8, 10)
                        : points[i].dateKey,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
