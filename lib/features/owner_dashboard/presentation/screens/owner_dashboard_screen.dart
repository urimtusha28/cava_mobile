import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../account/presentation/utils/order_formatters.dart';
import '../../domain/entities/owner_dashboard_entities.dart';
import '../controllers/owner_dashboard_controller.dart';
import '../utils/owner_dashboard_today.dart';
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
    final todayOrders = filterTodaysOrders(snapshot.recentOrders);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
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

        // —— Hero: shitjet sot (pa container) ——
        Text(
          l10n.ownerSalesToday.toUpperCase(),
          style: AppTextStyles.bodySmall.copyWith(
            letterSpacing: 1.2,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          Formatters.currency(s.salesToday),
          style: AppTextStyles.h1.copyWith(
            fontSize: 40,
            height: 1.1,
            letterSpacing: -1.0,
            color: AppColors.burgundy,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.ownerTodayOrdersCount(todayOrders.length),
          style: AppTextStyles.bodySmall,
        ),

        const SizedBox(height: AppSpacing.xxl),
        _SectionTitle(l10n.ownerTodayOrders),
        const SizedBox(height: AppSpacing.sm),
        if (todayOrders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text(
              l10n.ownerNoTodayOrders,
              style: AppTextStyles.bodySmall,
            ),
          )
        else
          _TodayOrdersList(orders: todayOrders),

        const SizedBox(height: AppSpacing.xxl),
        _SectionTitle(l10n.ownerSalesChart),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.ownerSalesChartSubtitle, style: AppTextStyles.bodySmall),
        const SizedBox(height: AppSpacing.lg),
        _SalesChart(points: snapshot.chartLast7Days),

        const SizedBox(height: AppSpacing.xxl),
        _SectionTitle(l10n.ownerPeriodOverview),
        const SizedBox(height: AppSpacing.md),
        _PeriodStrip(
          items: [
            (
              l10n.ownerDays7Short,
              Formatters.currency(s.salesLast7Days),
            ),
            (
              l10n.ownerDays30Short,
              Formatters.currency(s.salesLast30Days),
            ),
            (
              l10n.ownerLifetimeShort,
              Formatters.currency(s.totalRevenue),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _InlineStatRow(
          label: l10n.ownerLifetimeOrders,
          value: '${s.totalOrders}',
        ),

        const SizedBox(height: AppSpacing.xxl),
        _SectionTitle(l10n.ownerOrderPipeline),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.ownerOrderPipelineSubtitle,
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        _OrderPipelineBars(
          pending: s.pendingOrders,
          processing: s.processingOrders,
          completed: s.completedOrders,
          cancelled: s.cancelledOrders,
          pendingLabel: l10n.ownerOrdersPending,
          processingLabel: l10n.ownerOrdersProcessing,
          completedLabel: l10n.ownerOrdersCompleted,
          cancelledLabel: l10n.ownerOrdersCancelled,
        ),

        const SizedBox(height: AppSpacing.xxl),
        _SectionTitle(l10n.ownerCustomers),
        const SizedBox(height: AppSpacing.md),
        _InlineStatRow(
          label: l10n.ownerUniqueBuyersLabel,
          value: '${snapshot.newCustomers.count}',
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.h3);
  }
}

class _TodayOrdersList extends StatelessWidget {
  const _TodayOrdersList({required this.orders});

  final List<OwnerRecentOrder> orders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        for (var i = 0; i < orders.length; i++) ...[
          if (i > 0)
            const Divider(height: 1, thickness: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${orders[i].orderNumber}',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${orders[i].customerName} · ${OwnerOrderStatusL10n.labelOf(l10n, orders[i].statusLabel)}',
                        style: AppTextStyles.bodySmall,
                      ),
                      Text(
                        formatPaymentSummary(
                          method: orders[i].paymentMethod,
                          paymentStatus: orders[i].paymentStatus,
                          l10n: l10n,
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatters.currency(orders[i].total),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.burgundy,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PeriodStrip extends StatelessWidget {
  const _PeriodStrip({required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Container(
              width: 1,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              color: AppColors.border,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  items[i].$1,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  items[i].$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h3.copyWith(color: AppColors.burgundy),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _InlineStatRow extends StatelessWidget {
  const _InlineStatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodySmall)),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: AppColors.burgundy),
          ),
        ],
      ),
    );
  }
}

class _OrderPipelineBars extends StatelessWidget {
  const _OrderPipelineBars({
    required this.pending,
    required this.processing,
    required this.completed,
    required this.cancelled,
    required this.pendingLabel,
    required this.processingLabel,
    required this.completedLabel,
    required this.cancelledLabel,
  });

  final int pending;
  final int processing;
  final int completed;
  final int cancelled;
  final String pendingLabel;
  final String processingLabel;
  final String completedLabel;
  final String cancelledLabel;

  @override
  Widget build(BuildContext context) {
    final total = pending + processing + completed + cancelled;
    final safeTotal = total <= 0 ? 1 : total;

    Widget row(String label, int count, Color color) {
      final fraction = count / safeTotal;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label, style: AppTextStyles.bodySmall),
                ),
                Text(
                  '$count',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: fraction.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.surfaceMuted,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        row(pendingLabel, pending, AppColors.burgundy.withValues(alpha: 0.45)),
        row(processingLabel, processing, AppColors.burgundy.withValues(alpha: 0.7)),
        row(completedLabel, completed, AppColors.burgundy),
        row(cancelledLabel, cancelled, AppColors.textMuted),
      ],
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
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(l10n.ownerChartNoData, style: AppTextStyles.bodySmall),
        ),
      );
    }

    final maxRevenue = points
        .map((p) => p.revenue)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final safeMax = maxRevenue <= 0 ? 1.0 : maxRevenue;

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < points.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (points[i].revenue > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        points[i].revenue >= 10
                            ? points[i].revenue.toStringAsFixed(0)
                            : points[i].revenue.toStringAsFixed(1),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor:
                            (points[i].revenue / safeMax).clamp(0.04, 1.0),
                        widthFactor: 0.7,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: i == points.length - 1
                                ? AppColors.burgundy
                                : AppColors.burgundy.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(6),
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
                    style: AppTextStyles.bodySmall.copyWith(
                      color: i == points.length - 1
                          ? AppColors.burgundy
                          : AppColors.textMuted,
                      fontWeight: i == points.length - 1
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
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
