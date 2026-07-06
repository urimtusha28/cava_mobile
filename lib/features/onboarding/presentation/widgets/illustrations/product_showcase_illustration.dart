import 'package:flutter/material.dart';

import 'product_showcase/premium_product_showcase_illustration.dart';

class ProductShowcaseIllustration extends StatelessWidget {
  const ProductShowcaseIllustration({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return PremiumProductShowcaseIllustration(isActive: isActive);
  }
}
