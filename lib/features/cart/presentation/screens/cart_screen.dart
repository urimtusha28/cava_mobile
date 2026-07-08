import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/checkout_screen_header.dart';
import '../../../../core/widgets/product_image_view.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/state/cart_state_notifier.dart';
import '../controllers/cart_controller.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final CartController _controller;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _controller = createCartController();
    _loadFuture = _controller.load();
  }

  void _updateQuantity(int index, int quantity) {
    _controller.updateQuantity(index, quantity);
  }

  void _removeItem(int index) {
    _controller.removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        return ValueListenableBuilder<int>(
          valueListenable: CartStateNotifier.revision,
          builder: (context, _, child) {
            return ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                final items = _controller.items;

                return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: items.isEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckoutScreenHeader(
                        scriptTitle: 'Shporta',
                        boldTitle: 'Juaj',
                        showBack: true,
                        onBack: () => context.go(AppRoutes.home),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Shporta është bosh',
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckoutScreenHeader(
                        scriptTitle: 'Shporta',
                        boldTitle: 'Juaj',
                        showBack: true,
                        onBack: () => context.go(AppRoutes.home),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screen,
                            0,
                            AppSpacing.screen,
                            AppSpacing.md,
                          ),
                          children: [
                            for (var i = 0; i < items.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: _CartItemCard(
                                  item: items[i],
                                  onDecrease: items[i].quantity > 1
                                      ? () => _updateQuantity(i, items[i].quantity - 1)
                                      : null,
                                  onIncrease: () =>
                                      _updateQuantity(i, items[i].quantity + 1),
                                  onRemove: () => _removeItem(i),
                                ),
                              ),
                            const SizedBox(height: AppSpacing.lg),
                            _OrderSummaryCard(controller: _controller),
                          ],
                        ),
                      ),
                      _CartFooter(
                        total: _controller.total,
                        onContinue: () => context.push(AppRoutes.checkout),
                      ),
                    ],
                  ),
          ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onIncrease,
    this.onDecrease,
    required this.onRemove,
  });

  final CartItemEntity item;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final color = Color(product.placeholderColor ?? 0xFF6B1D2A);
    final placeholder = Icon(
      Icons.wine_bar_outlined,
      color: color.withValues(alpha: 0.45),
      size: 32,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Container(
            width: 56,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            clipBehavior: Clip.antiAlias,
            child: ProductImageView(
              imageUrl: product.imageUrl,
              width: 56,
              height: 72,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              placeholder: Center(child: placeholder),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.brand, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  product.name,
                  style: AppTextStyles.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  Formatters.currency(product.price),
                  style: AppTextStyles.price.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
              ),
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QtyButton(icon: Icons.chevron_left, onTap: onDecrease),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text('${item.quantity}', style: AppTextStyles.body),
                    ),
                    _QtyButton(icon: Icons.chevron_right, onTap: onIncrease),
                  ],
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? AppColors.textMuted : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.controller});

  final CartController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text('Totali i porosisë', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.lg),
          _SummaryRow('Çmimi', Formatters.currency(controller.subtotal)),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow('TVSH', Formatters.currency(controller.vat)),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow('Transporti', Formatters.currency(controller.shipping)),
          if (controller.discount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow('Zbritja', Formatters.currency(controller.discount)),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _SummaryRow(
            'Totali:',
            Formatters.currency(controller.total),
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.emphasized = false});

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = emphasized ? AppTextStyles.h3 : AppTextStyles.body;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}

class _CartFooter extends StatelessWidget {
  const _CartFooter({required this.total, required this.onContinue});

  final double total;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.6))),
      ),
      child: Row(
        children: [
          Text.rich(
            TextSpan(
              text: 'Totali: ',
              style: AppTextStyles.body,
              children: [
                TextSpan(
                  text: Formatters.currency(total),
                  style: AppTextStyles.h3,
                ),
              ],
            ),
          ),
          const Spacer(),
          Material(
            color: AppColors.burgundy,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onContinue,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                child: Text('Vazhdo', style: AppTextStyles.button),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
