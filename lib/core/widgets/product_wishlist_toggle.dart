import 'package:flutter/material.dart';

import '../di/injection.dart';
import '../state/wishlist_state_notifier.dart';
import '../theme/app_colors.dart';
import '../../features/products/domain/entities/product_entity.dart';
import '../../features/wishlist/domain/usecases/is_in_wishlist.dart';
import '../../features/wishlist/domain/usecases/toggle_wishlist.dart';
import '../presentation/result_extensions.dart';

/// Compact wishlist toggle for product cards.
class ProductWishlistToggle extends StatefulWidget {
  const ProductWishlistToggle({
    super.key,
    required this.product,
    this.iconSize = 20,
  });

  final ProductEntity product;
  final double iconSize;

  @override
  State<ProductWishlistToggle> createState() => _ProductWishlistToggleState();
}

class _ProductWishlistToggleState extends State<ProductWishlistToggle> {
  late final ToggleWishlistUseCase _toggleWishlist;
  late final IsInWishlistUseCase _isInWishlist;

  bool _inWishlist = false;

  @override
  void initState() {
    super.initState();
    configureDependencies();
    _toggleWishlist = sl<ToggleWishlistUseCase>();
    _isInWishlist = sl<IsInWishlistUseCase>();
    _syncWishlistState();
    WishlistStateNotifier.revision.addListener(_syncWishlistState);
  }

  @override
  void dispose() {
    WishlistStateNotifier.revision.removeListener(_syncWishlistState);
    super.dispose();
  }

  Future<void> _syncWishlistState() async {
    final inWishlist = await unwrapFutureResult(
      _isInWishlist(widget.product.id),
      fallback: false,
    );
    if (!mounted) {
      return;
    }
    setState(() => _inWishlist = inWishlist);
  }

  Future<void> _onTap() async {
    await unwrapFutureResult(
      _toggleWishlist(widget.product),
      fallback: null,
    );
    await _syncWishlistState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 1),
        child: Icon(
          _inWishlist ? Icons.bookmark : Icons.bookmark_border,
          size: widget.iconSize,
          color: _inWishlist ? AppColors.burgundy : AppColors.textMuted,
        ),
      ),
    );
  }
}
