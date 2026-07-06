import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static const _orders = [
    ('#CP-2024-01568', 'Stone Castle Merlot', '18,90 €', 'Në rrugëtim'),
    ('#CP-2024-01402', 'Jack Daniel\'s No.7', '32,00 €', 'Përfunduar'),
    ('#CP-2024-01311', 'Trius Sparkling', '28,00 €', 'Përfunduar'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CavaAppBar(title: 'Porositë e mia', showBack: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screen),
        itemCount: _orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, index) {
          final order = _orders[index];
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order.$1, style: AppTextStyles.bodySmall),
                    Text(order.$4, style: AppTextStyles.caption.copyWith(
                      color: AppColors.burgundy,
                    )),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(order.$2, style: AppTextStyles.body),
                const SizedBox(height: 4),
                Text(order.$3, style: AppTextStyles.price.copyWith(fontSize: 15)),
              ],
            ),
          );
        },
      ),
    );
  }
}
