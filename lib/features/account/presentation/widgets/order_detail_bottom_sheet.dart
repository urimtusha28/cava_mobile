import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order_entity.dart';
import '../utils/order_formatters.dart';

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
    final totals = order.totals;

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
                child: Text('Detajet e porosisë', style: AppTextStyles.h2),
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
              _InfoRow(label: 'Porosia', value: order.displayOrderNumber),
              _InfoRow(
                label: 'Statusi',
                value: formatOrderStatus(order.status),
              ),
              _InfoRow(
                label: 'Pagesa',
                value: formatPaymentStatus(order.paymentStatus),
              ),
              if (order.createdAt != null)
                _InfoRow(
                  label: 'Data',
                  value: formatOrderDate(order.createdAt),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text('Produktet', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.sm),
              if (order.items.isEmpty)
                Text(
                  'Nuk ka produkte në këtë porosi.',
                  style: AppTextStyles.bodySmall,
                )
              else
                ...order.items.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: AppTextStyles.body),
                        const SizedBox(height: 4),
                        Text(
                          '${item.quantity} x ${formatOrderTotal(item.price)}',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatOrderTotal(item.lineTotal),
                          style: AppTextStyles.price.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text('Totali', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.sm),
              if (totals?.subtotal != null)
                _TotalRow(
                  label: 'Nëntotali',
                  value: formatOrderTotal(totals!.subtotal!),
                ),
              if (totals?.discount != null && totals!.discount! > 0)
                _TotalRow(
                  label: 'Zbritja',
                  value: '-${formatOrderTotal(totals.discount!)}',
                ),
              if (totals?.shipping != null && totals!.shipping! > 0)
                _TotalRow(
                  label: 'Transporti',
                  value: formatOrderTotal(totals.shipping!),
                ),
              if (totals?.vat != null && totals!.vat! > 0)
                _TotalRow(
                  label: 'TVSH',
                  value: formatOrderTotal(totals.vat!),
                ),
              _TotalRow(
                label: 'Totali',
                value: formatOrderTotal(order.total),
                emphasized: true,
              ),
              if (order.customer?.hasInfo == true) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('Klienti', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.sm),
                if (order.customer!.name != null)
                  _InfoRow(label: 'Emri', value: order.customer!.name!),
                if (order.customer!.phone != null)
                  _InfoRow(label: 'Telefoni', value: order.customer!.phone!),
                if (order.customer!.address != null)
                  _InfoRow(label: 'Adresa', value: order.customer!.address!),
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
                      child: Text('Mbyll', style: AppTextStyles.button),
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
    final style = emphasized ? AppTextStyles.price : AppTextStyles.body;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style.copyWith(fontSize: emphasized ? 16 : 14)),
          Text(
            value,
            style: style.copyWith(
              fontSize: emphasized ? 16 : 14,
              color: emphasized ? AppColors.burgundy : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
