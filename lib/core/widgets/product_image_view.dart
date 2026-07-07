import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Network product image with identical placeholder/error fallback.
///
/// Uses [CachedNetworkImage] (memory + disk cache). No layout properties —
/// callers keep existing width, height, and decoration.
class ProductImageView extends StatelessWidget {
  const ProductImageView({
    super.key,
    required this.imageUrl,
    required this.placeholder,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String? imageUrl;
  final Widget placeholder;
  final double? width;
  final double? height;
  final BoxFit fit;

  static bool hasUrl(String? url) => url != null && url.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!hasUrl(imageUrl)) {
      return placeholder;
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!.trim(),
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 250),
      fadeOutDuration: const Duration(milliseconds: 100),
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => placeholder,
    );
  }
}
