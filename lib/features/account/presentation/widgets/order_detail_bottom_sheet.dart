import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/auth/app_session_notifier.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_fulfillment_status.dart';
import '../../domain/utils/order_fulfillment_status_machine.dart';
import '../../domain/usecases/get_order_by_id_for_admin.dart';
import '../../domain/usecases/update_order_fulfillment_status.dart';
import '../utils/order_fulfillment_status_l10n.dart';
import '../utils/order_formatters.dart';
import 'order_detail_item_row.dart';

Future<void> showOrderDetailBottomSheet({
  required BuildContext context,
  required OrderEntity order,
  ValueChanged<OrderEntity>? onOrderUpdated,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 24,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: _OrderDetailSheetBody(
                  order: order,
                  onOrderUpdated: onOrderUpdated,
                  scrollController: scrollController,
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

class _OrderDetailSheetBody extends StatefulWidget {
  const _OrderDetailSheetBody({
    required this.order,
    this.onOrderUpdated,
    required this.scrollController,
  });

  final OrderEntity order;
  final ValueChanged<OrderEntity>? onOrderUpdated;
  final ScrollController scrollController;

  @override
  State<_OrderDetailSheetBody> createState() => _OrderDetailSheetBodyState();
}

class _OrderDetailSheetBodyState extends State<_OrderDetailSheetBody> {
  late OrderEntity _order;
  late final GetOrderByIdForAdminUseCase _getOrderByIdForAdmin;
  late final UpdateOrderFulfillmentStatusUseCase _updateOrderFulfillmentStatus;

  bool _loadingDetail = false;
  bool _statusUpdating = false;
  String? _statusError;

  bool get _canEditStatus => AppSessionNotifier.instance.isOwner;

  String get _currentFulfillmentRaw =>
      _order.fulfillmentStatus?.trim().isNotEmpty == true
          ? _order.fulfillmentStatus!.trim()
          : _order.status;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    configureDependencies();
    _getOrderByIdForAdmin = sl<GetOrderByIdForAdminUseCase>();
    _updateOrderFulfillmentStatus = sl<UpdateOrderFulfillmentStatusUseCase>();
    if (_canEditStatus) {
      _reloadAdminOrder();
    }
  }

  Future<void> _reloadAdminOrder() async {
    setState(() => _loadingDetail = true);
    final result = await _getOrderByIdForAdmin(
      GetOrderByIdForAdminParams(orderId: _order.id),
    );
    if (!mounted) {
      return;
    }
    result.fold(
      onSuccess: (data) {
        if (data != null) {
          _order = data;
        }
      },
      onFailure: (_) {},
    );
    setState(() => _loadingDetail = false);
  }

  Future<void> _onStatusChanged(FulfillmentStatusDetail? newStatus) async {
    final l10n = AppLocalizations.of(context);
    if (newStatus == null || _statusUpdating) {
      return;
    }
    final current = normalizeFulfillmentForTransitions(_currentFulfillmentRaw);
    if (current == newStatus) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.orderStatusChangeTitle),
          content: Text(
            l10n.orderStatusChangeConfirm(
              _order.displayOrderNumber,
              OrderFulfillmentStatusL10n.labelOf(l10n, current),
              OrderFulfillmentStatusL10n.labelOf(l10n, newStatus),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _statusUpdating = true;
      _statusError = null;
    });

    final result = await _updateOrderFulfillmentStatus(
      UpdateOrderFulfillmentStatusParams(
        orderId: _order.id,
        newStatus: newStatus,
        adminUid: await sl<AuthRepository>().getCurrentUserId(),
      ),
    );
    if (!mounted) {
      return;
    }

    result.fold(
      onSuccess: (updatedOrder) {
        if (updatedOrder != null) {
          _order = updatedOrder;
          widget.onOrderUpdated?.call(updatedOrder);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.orderStatusChangeSuccess),
            backgroundColor: AppColors.burgundy,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onFailure: (failure) {
        _statusError = failure.message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );

    setState(() => _statusUpdating = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totals = _order.totals;
    final customer = _order.customer;
    final currentStatus = normalizeFulfillmentForTransitions(_currentFulfillmentRaw);
    final allowedStatuses = allowedStatusesForCurrent(_currentFulfillmentRaw);

    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.lg,
            AppSpacing.screen,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(l10n.orderDetailTitle, style: AppTextStyles.h2),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 22),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              AppSpacing.lg,
            ),
            children: [
              if (_loadingDetail)
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: LinearProgressIndicator(color: AppColors.burgundy),
                ),
              _InfoRow(label: l10n.orderLabel, value: _order.displayOrderNumber),
              _InfoRow(
                label: l10n.orderStatus,
                value: OrderFulfillmentStatusL10n.labelOfRaw(
                  l10n,
                  _currentFulfillmentRaw,
                ),
              ),
              _InfoRow(
                label: l10n.orderPayment,
                value: formatPaymentSummary(
                  method: _order.paymentMethod,
                  paymentStatus: _order.paymentStatus,
                  l10n: l10n,
                ),
              ),
              if (_order.createdAt != null)
                _InfoRow(
                  label: l10n.orderDate,
                  value: formatOrderDate(_order.createdAt),
                ),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.orderFulfillmentStatusTitle, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.sm),
              _InfoRow(
                label: l10n.orderStatus,
                value: OrderFulfillmentStatusL10n.labelOf(l10n, currentStatus),
              ),
              if (_canEditStatus) ...[
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<FulfillmentStatusDetail>(
                  initialValue: currentStatus,
                  items: allowedStatuses
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(
                            OrderFulfillmentStatusL10n.labelOf(l10n, status),
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged:
                      currentStatus.isTerminal || _statusUpdating
                          ? null
                          : _onStatusChanged,
                  decoration: InputDecoration(
                    labelText: l10n.orderStatusSelectorLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.burgundy),
                    ),
                  ),
                ),
                if (_statusUpdating) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.burgundy,
                        ),
                      ),
                    ],
                  ),
                ],
                if (_statusError != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _statusError!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.orderProducts, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.sm),
              if (_order.items.isEmpty)
                Text(
                  l10n.orderNoProducts,
                  style: AppTextStyles.bodySmall,
                )
              else
                ..._order.items.map(
                  (item) => OrderDetailItemRow(item: item),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.total, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.sm),
              if (totals?.subtotal != null)
                _TotalRow(
                  label: l10n.orderSubtotal,
                  value: formatOrderTotal(totals!.subtotal!),
                ),
              if (totals?.discount != null && totals!.discount! > 0)
                _TotalRow(
                  label: l10n.cartDiscount,
                  value: '-${formatOrderTotal(totals.discount!)}',
                ),
              if (totals?.shipping != null && totals!.shipping! > 0)
                _TotalRow(
                  label: l10n.cartShipping,
                  value: formatOrderTotal(totals.shipping!),
                ),
              if (totals?.vat != null && totals!.vat! > 0)
                _TotalRow(
                  label: l10n.cartVat,
                  value: formatOrderTotal(totals.vat!),
                ),
              _TotalRow(
                label: l10n.total,
                value: formatOrderTotal(_order.total),
                emphasized: true,
              ),
              if (customer?.hasInfo == true) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.orderCustomer, style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.sm),
                if (_hasText(customer!.name))
                  _InfoRow(label: l10n.name, value: customer.name!.trim()),
                if (_hasText(customer.email))
                  _InfoRow(label: l10n.email, value: customer.email!.trim()),
                if (_hasText(customer.phone))
                  _InfoRow(label: l10n.phoneLabel, value: customer.phone!.trim()),
                if (_hasText(customer.address))
                  _InfoRow(label: l10n.address, value: customer.address!.trim()),
              ],
              const SizedBox(height: AppSpacing.xl),
              Material(
                color: AppColors.burgundy,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 52,
                    child: Center(
                      child: Text(l10n.close, style: AppTextStyles.button),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ],
    );
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: emphasized
                ? AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  )
                : AppTextStyles.body.copyWith(fontSize: 14),
          ),
          Text(
            value,
            style: AppTextStyles.price.copyWith(
              fontSize: emphasized ? 17 : 14,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
              color: emphasized ? AppColors.burgundy : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
