import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../domain/entities/owner_dashboard_entities.dart';
import '../controllers/owner_dashboard_controller.dart';
import '../utils/owner_order_status_l10n.dart';

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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(title: l10n.ownerDashboardTitle, showBack: false),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, _) {
          return ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return RefreshIndicator(
                color: AppColors.burgundy,
                onRefresh: _controller.refresh,
                child: _buildBody(l10n),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
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
              _controller.sectionError ?? l10n.ownerDashboardLoadFailed,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: TextButton(
                onPressed: _controller.load,
                child: Text(
                  l10n.retry,
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
                    l10n.ownerNoDataYet,
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
    final l10n = AppLocalizations.of(context);
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
        Text(l10n.ownerSummary, style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.ownerSummarySource,
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
              label: l10n.ownerSalesToday,
              value: Formatters.currency(s.salesToday),
            ),
            _StatCard(
              label: l10n.ownerSales7Days,
              value: Formatters.currency(s.salesLast7Days),
            ),
            _StatCard(
              label: l10n.ownerSales30Days,
              value: Formatters.currency(s.salesLast30Days),
            ),
            _StatCard(
              label: l10n.ownerTotalRevenue,
              value: Formatters.currency(s.totalRevenue),
            ),
            _StatCard(
              label: l10n.ownerOrdersCount,
              value: '${s.totalOrders}',
            ),
            _StatCard(
              label: l10n.ownerOrdersPending,
              value: '${s.pendingOrders}',
            ),
            _StatCard(
              label: l10n.ownerOrdersProcessing,
              value: '${s.processingOrders}',
            ),
            _StatCard(
              label: l10n.ownerOrdersCompleted,
              value: '${s.completedOrders}',
            ),
            _StatCard(
              label: l10n.ownerOrdersCancelled,
              value: '${s.cancelledOrders}',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(l10n.ownerSalesChart, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.ownerSalesChartSubtitle,
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        _SalesChart(points: snapshot.chartLast7Days),
        const SizedBox(height: AppSpacing.xxl),
        Text(l10n.ownerRecentOrders, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        if (snapshot.recentOrders.isEmpty)
          Text(l10n.ownerNoOrders, style: AppTextStyles.bodySmall)
        else
          ...snapshot.recentOrders.map(
            (o) => _ListTileCard(
              title: '#${o.orderNumber}',
              subtitle:
                  '${o.customerName} · ${OwnerOrderStatusL10n.labelOf(l10n, o.statusLabel)}',
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
        Text(l10n.ownerTopSelling, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.ownerTopSellingUnavailable,
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(l10n.ownerLowStockProducts, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.ownerLowStockThreshold(s.lowStockCount),
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        if (snapshot.lowStockProducts.isEmpty)
          Text(
            s.lowStockCount == 0
                ? l10n.ownerNoLowStock
                : l10n.ownerLowStockListFailed,
            style: AppTextStyles.bodySmall,
          )
        else
          ...snapshot.lowStockProducts.map(
            (p) => _ListTileCard(
              title: p.name,
              subtitle: l10n.ownerThresholdMax(p.thresholdMax),
              trailing: Text(
                '${p.stock}',
                style: AppTextStyles.h3.copyWith(color: AppColors.burgundy),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.xxl),
        Text(l10n.ownerCustomers, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.sm),
        _ListTileCard(
          title: l10n.ownerUniqueBuyersLabel,
          subtitle: l10n.ownerCustomersSubtitle,
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
    final l10n = AppLocalizations.of(context);
    if (points.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(l10n.ownerChartNoData, style: AppTextStyles.bodySmall),
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
