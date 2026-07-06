import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  static const _addresses = [
    ('Shtëpi', 'Rruga e Dibrës 12, Tiranë', '1001'),
    ('Punë', 'Bulevardi Dëshmorët e Kombit, Tiranë', '1001'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CavaAppBar(title: 'Adresat', showBack: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screen),
        itemCount: _addresses.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, index) {
          final address = _addresses[index];
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
                Text(address.$1, style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.sm),
                Text(address.$2, style: AppTextStyles.body),
                const SizedBox(height: 4),
                Text('Kodi postar: ${address.$3}', style: AppTextStyles.bodySmall),
              ],
            ),
          );
        },
      ),
    );
  }
}
