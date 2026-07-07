import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/product_image_view.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../domain/entities/order_item_entity.dart';
import '../utils/order_formatters.dart';
import '../utils/order_item_image_resolver.dart';

class OrderDetailItemRow extends StatefulWidget {
  const OrderDetailItemRow({
    super.key,
    required this.item,
    this.imageResolver,
  });

  final OrderItemEntity item;
  final OrderItemImageSource? imageResolver;

  @override
  State<OrderDetailItemRow> createState() => _OrderDetailItemRowState();
}

class _OrderDetailItemRowState extends State<OrderDetailItemRow> {
  static const double _imageSize = 52;

  String? _resolvedImageUrl;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final resolver = widget.imageResolver ??
        OrderItemImageResolver(sl<ProductRepository>());
    final imageUrl = await resolver.resolve(widget.item);
    if (!mounted) {
      return;
    }
    setState(() {
      _resolvedImageUrl = imageUrl;
      _resolved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: _imageSize,
      height: _imageSize,
      color: AppColors.surfaceMuted,
      child: Icon(
        Icons.wine_bar_outlined,
        size: 24,
        color: AppColors.burgundy.withValues(alpha: 0.35),
      ),
    );

    final imageUrl = _resolved
        ? _resolvedImageUrl
        : (ProductImageView.hasUrl(widget.item.imageUrl)
            ? widget.item.imageUrl
            : null);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProductImageView(
            imageUrl: imageUrl,
            width: _imageSize,
            height: _imageSize,
            borderRadius: BorderRadius.circular(11),
            placeholder: placeholder,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name,
                  style: AppTextStyles.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.item.quantity} x ${formatOrderTotal(widget.item.price)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            formatOrderTotal(widget.item.lineTotal),
            style: AppTextStyles.price.copyWith(
              fontSize: 14,
              color: AppColors.burgundy,
            ),
          ),
        ],
      ),
    );
  }
}
