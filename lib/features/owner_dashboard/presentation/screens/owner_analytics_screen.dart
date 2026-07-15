import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/cava_app_bar.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CavaAppBar(title: 'Analitika', showBack: false),
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
                    _controller.sectionError ?? 'Gabim',
                    style: AppTextStyles.body,
                  ),
                );
              }
              final s = _controller.snapshot?.summary;
              if (s == null) {
                return Center(
                  child: Text('Nuk ka të dhëna.', style: AppTextStyles.emptyState),
                );
              }
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.screen),
                children: [
                  Text(
                    'Të njëjtat burime si Analytics/Overview admin (statsDaily UTC).',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _Metric(
                    label: 'Shitjet 7 ditë',
                    value: Formatters.currency(s.salesLast7Days),
                  ),
                  _Metric(
                    label: 'Shitjet 30 ditë',
                    value: Formatters.currency(s.salesLast30Days),
                  ),
                  _Metric(
                    label: 'Porosi totale (lifetime)',
                    value: '${s.totalOrders}',
                  ),
                  _Metric(
                    label: 'Të ardhura totale (lifetime)',
                    value: Formatters.currency(s.totalRevenue),
                  ),
                  _Metric(
                    label: 'Përfunduar (30 ditë, donut_delivered)',
                    value: '${s.completedOrders}',
                  ),
                  _Metric(
                    label: 'Anuluar/kthyer (30 ditë)',
                    value: '${s.cancelledOrders}',
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: AppColors.burgundy),
          ),
        ],
      ),
    );
  }
}
