import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../domain/entities/owner_dashboard_entities.dart';
import '../controllers/owner_dashboard_controller.dart';

class OwnerAnalyticsScreen extends StatefulWidget {
  const OwnerAnalyticsScreen({super.key});

  @override
  State<OwnerAnalyticsScreen> createState() => _OwnerAnalyticsScreenState();
}

class _OwnerAnalyticsScreenState extends State<OwnerAnalyticsScreen> {
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
      appBar: CavaAppBar(title: l10n.ownerAnalyticsTitle, showBack: false),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, _) {
          return ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.status == OwnerDashboardViewStatus.loading ||
                  _controller.status == OwnerDashboardViewStatus.initial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.burgundy),
                );
              }
              if (_controller.status == OwnerDashboardViewStatus.error) {
                return Center(
                  child: Text(
                    _controller.sectionError ?? l10n.errorGeneric,
                    style: AppTextStyles.body,
                  ),
                );
              }
              final snap = _controller.snapshot;
              final s = snap?.summary;
              if (s == null || snap == null) {
                return Center(
                  child: Text(l10n.ownerNoData, style: AppTextStyles.emptyState),
                );
              }

              return RefreshIndicator(
                color: AppColors.burgundy,
                onRefresh: _controller.refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.md,
                    AppSpacing.screen,
                    AppSpacing.xxxl,
                  ),
                  children: [
                    // Lifetime KPIs — no heavy cards
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _KpiHero(
                            label: l10n.ownerTotalRevenueLifetime,
                            value: Formatters.currency(s.totalRevenue),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        Expanded(
                          child: _KpiHero(
                            label: l10n.ownerTotalOrdersLifetime,
                            value: '${s.totalOrders}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: AppSpacing.lg),

                    // Period strip
                    _PeriodRow(
                      items: [
                        (
                          l10n.ownerDays7Short,
                          Formatters.currency(s.salesLast7Days),
                        ),
                        (
                          l10n.ownerDays30Short,
                          Formatters.currency(s.salesLast30Days),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      l10n.ownerAnalyticsRevenueTitle,
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.ownerSalesChartSubtitle,
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: 220,
                      child: _RevenueLineChart(points: snap.chartLast7Days),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      l10n.ownerAnalyticsOrdersTitle,
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.ownerAnalyticsOrdersSubtitle,
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: 200,
                      child: _OrderStatusDonut(
                        pending: s.pendingOrders,
                        processing: s.processingOrders,
                        completed: s.completedOrders,
                        cancelled: s.cancelledOrders,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _DonutLegend(
                      pending: s.pendingOrders,
                      processing: s.processingOrders,
                      completed: s.completedOrders,
                      cancelled: s.cancelledOrders,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _KpiHero extends StatelessWidget {
  const _KpiHero({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.bodySmall.copyWith(
            letterSpacing: 0.8,
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.burgundy,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Container(
              width: 1,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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

class _RevenueLineChart extends StatelessWidget {
  const _RevenueLineChart({required this.points});

  final List<SalesChartPoint> points;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (points.isEmpty) {
      return Center(
        child: Text(
          l10n.ownerAnalyticsNoChart,
          style: AppTextStyles.bodySmall,
        ),
      );
    }

    final maxY = points
        .map((p) => p.revenue)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final chartMax = maxY <= 0 ? 1.0 : maxY * 1.15;

    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].revenue),
    ];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: chartMax,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: chartMax / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: chartMax / 4,
              getTitlesWidget: (value, _) {
                if (value <= 0 || value >= chartMax) {
                  return const SizedBox.shrink();
                }
                return Text(
                  value >= 10
                      ? value.toStringAsFixed(0)
                      : value.toStringAsFixed(1),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, _) {
                final i = value.round();
                if (i < 0 || i >= points.length) {
                  return const SizedBox.shrink();
                }
                final key = points[i].dateKey;
                final day = key.length >= 10 ? key.substring(8, 10) : key;
                final isLast = i == points.length - 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    day,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: isLast
                          ? AppColors.burgundy
                          : AppColors.textMuted,
                      fontWeight:
                          isLast ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.burgundyDark,
            getTooltipItems: (touched) {
              return touched.map((spot) {
                final i = spot.x.round();
                final label = i >= 0 && i < points.length
                    ? Formatters.currency(points[i].revenue)
                    : Formatters.currency(spot.y);
                return LineTooltipItem(
                  label,
                  AppTextStyles.bodySmall.copyWith(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: AppColors.burgundy,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                final isLast = index == points.length - 1;
                return FlDotCirclePainter(
                  radius: isLast ? 4.5 : 3,
                  color: AppColors.burgundy,
                  strokeWidth: 0,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.burgundy.withValues(alpha: 0.22),
                  AppColors.burgundy.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderStatusDonut extends StatelessWidget {
  const _OrderStatusDonut({
    required this.pending,
    required this.processing,
    required this.completed,
    required this.cancelled,
  });

  final int pending;
  final int processing;
  final int completed;
  final int cancelled;

  static const _colors = [
    Color(0xFFB87A84), // pending — soft burgundy
    Color(0xFF8F3D4A), // processing
    Color(0xFF6B1D2A), // completed
    Color(0xFFB0B0B0), // cancelled
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final values = [pending, processing, completed, cancelled];
    final total = values.fold<int>(0, (a, b) => a + b);

    if (total == 0) {
      return Center(
        child: Text(
          l10n.ownerAnalyticsNoChart,
          style: AppTextStyles.bodySmall,
        ),
      );
    }

    final sections = <PieChartSectionData>[
      for (var i = 0; i < values.length; i++)
        if (values[i] > 0)
          PieChartSectionData(
            value: values[i].toDouble(),
            color: _colors[i],
            radius: 52,
            showTitle: false,
          ),
    ];

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 48,
            startDegreeOffset: -90,
            sections: sections,
            pieTouchData: PieTouchData(enabled: false),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$total',
              style: AppTextStyles.h2.copyWith(color: AppColors.burgundy),
            ),
            Text(
              l10n.ownerOrdersCount,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}

class _DonutLegend extends StatelessWidget {
  const _DonutLegend({
    required this.pending,
    required this.processing,
    required this.completed,
    required this.cancelled,
  });

  final int pending;
  final int processing;
  final int completed;
  final int cancelled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      (l10n.ownerAnalyticsPendingShort, pending, const Color(0xFFB87A84)),
      (l10n.ownerAnalyticsProcessingShort, processing, const Color(0xFF8F3D4A)),
      (l10n.ownerAnalyticsCompletedShort, completed, AppColors.burgundy),
      (l10n.ownerAnalyticsCancelledShort, cancelled, AppColors.textMuted),
    ];

    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: item.$3,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${item.$1}  ${item.$2}',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
      ],
    );
  }
}
