import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../account/domain/entities/order_entity.dart';
import '../../../account/presentation/utils/order_formatters.dart';
import '../../../account/presentation/widgets/order_detail_bottom_sheet.dart';
import '../controllers/owner_dashboard_controller.dart';
import '../utils/owner_order_status_l10n.dart';

class OwnerOrdersScreen extends StatefulWidget {
  const OwnerOrdersScreen({super.key});

  @override
  State<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends State<OwnerOrdersScreen> {
  late final OwnerDashboardController _controller;
  late final Future<void> _loadFuture;
  final Map<String, OrderEntity> _orderOverrides = {};

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
      appBar: CavaAppBar(title: l10n.ownerOrdersTitle, showBack: false),
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
              final orders = _controller.snapshot?.recentOrders ?? const [];
              if (orders.isEmpty) {
                return Center(
                  child: Text(
                    l10n.ownerNoRecentOrders,
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
                  final override = _orderOverrides[o.id];
                  final displayStatus = override?.fulfillmentStatus ?? override?.status ?? o.statusLabel;
                  final paymentMethod = override?.paymentMethod ?? o.paymentMethod;
                  final paymentStatus = override?.paymentStatus ?? o.paymentStatus;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      onTap: () => showOrderDetailBottomSheet(
                        context: context,
                        order: OrderEntity(
                          id: o.id,
                          orderNumber: o.orderNumber,
                          status: override?.status ?? o.statusLabel,
                          fulfillmentStatus: override?.fulfillmentStatus ?? o.statusLabel,
                          paymentMethod: paymentMethod,
                          paymentStatus: paymentStatus,
                          total: override?.total ?? o.total,
                          itemCount: override?.itemCount ?? 0,
                          customer: override?.customer,
                          createdAt: override?.createdAt ?? o.createdAt,
                          items: override?.items ?? const [],
                          totals: override?.totals,
                        ),
                        onOrderUpdated: _replaceOrder,
                      ),
                      child: Container(
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
                                    '${o.customerName} · ${OwnerOrderStatusL10n.labelOf(l10n, displayStatus)}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  Text(
                                    formatPaymentSummary(
                                      method: paymentMethod,
                                      paymentStatus: paymentStatus,
                                      l10n: l10n,
                                    ),
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              Formatters.currency(override?.total ?? o.total),
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.burgundy,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  void _replaceOrder(OrderEntity updatedOrder) {
    setState(() {
      _orderOverrides[updatedOrder.id] = updatedOrder;
    });
  }
}
