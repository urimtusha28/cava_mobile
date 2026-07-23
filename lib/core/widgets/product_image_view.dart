import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_assets.dart';

/// Network product image with identical placeholder/error fallback.
///
/// Uses [CachedNetworkImage] (memory + disk cache). Real images use
/// [BoxFit.cover] to fill the container; placeholders are unchanged.
class ProductImageView extends StatelessWidget {
  const ProductImageView({
    super.key,
    required this.imageUrl,
    required this.placeholder,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? imageUrl;
  final Widget placeholder;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  static bool hasUrl(String? url) => url != null && url.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!hasUrl(imageUrl)) {
      return placeholder;
    }

    final image = CachedNetworkImage(
      imageUrl: imageUrl!.trim(),
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 250),
      fadeOutDuration: const Duration(milliseconds: 100),
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => placeholder,
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}

/// Shared fallback when a product has no (or a broken) image URL.
class ProductImagePlaceholder extends StatelessWidget {
  const ProductImagePlaceholder({
    super.key,
    this.size = 48,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.productPlaceholder,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: color != null ? BlendMode.srcIn : null,
    );
  }
}
