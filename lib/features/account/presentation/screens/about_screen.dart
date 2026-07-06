import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CavaAppBar(title: 'Rreth Cava Premium', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.burgundyDark, AppColors.burgundy],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cava Premium', style: AppTextStyles.h2.copyWith(color: Colors.white)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Dyqani juaj premium për verëra, spirits dhe aksesorë të zgjedhur me kujdes.',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Misioni ynë', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ofrojmë produkte cilësore me shërbim të shkëlqyer dhe përvojë blerjeje moderne për klientët tanë premium.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Versioni', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text('1.0.0', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
