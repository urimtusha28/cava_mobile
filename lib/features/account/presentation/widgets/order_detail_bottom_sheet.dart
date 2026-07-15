import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order_entity.dart';
import '../utils/order_formatters.dart';
import 'order_detail_item_row.dart';

Future<void> showOrderDetailBottomSheet({
  required BuildContext context,
  required OrderEntity order,
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

class _OrderDetailSheetBody extends StatelessWidget {
  const _OrderDetailSheetBody({
    required this.order,
    required this.scrollController,
  });

  final OrderEntity order;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totals = order.totals;
    final customer = order.customer;

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
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              AppSpacing.lg,
            ),
            children: [
              _InfoRow(label: l10n.orderLabel, value: order.displayOrderNumber),
              _InfoRow(
                label: l10n.orderStatus,
                value: formatOrderStatus(order.status, l10n),
              ),
              _InfoRow(
                label: l10n.orderPayment,
                value: formatPaymentStatus(order.paymentStatus, l10n),
              ),
              if (order.createdAt != null)
                _InfoRow(
                  label: l10n.orderDate,
                  value: formatOrderDate(order.createdAt),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.orderProducts, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.sm),
              if (order.items.isEmpty)
                Text(
                  l10n.orderNoProducts,
                  style: AppTextStyles.bodySmall,
                )
              else
                ...order.items.map(
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
                value: formatOrderTotal(order.total),
                emphasized: true,
              ),
              if (customer?.hasInfo == true) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.orderCustomer, style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.sm),
                if (_hasText(customer!.name))
                  _InfoRow(label: l10n.name, value: customer.name!.trim()),
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
