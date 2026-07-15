import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../controllers/owner_dashboard_controller.dart';

class OwnerOrdersScreen extends StatefulWidget {
  const OwnerOrdersScreen({super.key});

  @override
  State<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends State<OwnerOrdersScreen> {
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
      appBar: const CavaAppBar(title: 'Porositë', showBack: false),
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
              final orders = _controller.snapshot?.recentOrders ?? const [];
              if (orders.isEmpty) {
                return Center(
                  child: Text(
                    'Nuk ka porosi të fundit.',
                    style: AppTextStyles.emptyState,
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.screen),
                itemCount: orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final o = orders[index];
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
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
                              Text('#${o.orderNumber}', style: AppTextStyles.body),
                              Text(
                                '${o.customerName} · ${o.statusLabel}',
                                style: AppTextStyles.bodySmall,
                              ),
                              Text(
                                '${o.paymentMethod} · ${o.paymentStatus}',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Formatters.currency(o.total),
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.burgundy,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
