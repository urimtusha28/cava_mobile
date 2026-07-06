import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/constants/app_spacing.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CavaAppBar(title: 'Politika e privatësisë', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(
            'Cava Premium respekton privatësinë tuaj dhe mbron të dhënat personale që na besoni.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Të dhënat që mbledhim', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Mund të mbledhim emrin, email-in, adresën e dërgesës dhe historikun e porosive për të përpunuar blerjet tuaja.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Si i përdorim', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Të dhënat përdoren për përpunimin e porosive, komunikimin me klientët dhe përmirësimin e shërbimit.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Siguria', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Aplikojmë masa të arsyeshme sigurie për të mbrojtur informacionin tuaj nga aksesi i paautorizuar.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
