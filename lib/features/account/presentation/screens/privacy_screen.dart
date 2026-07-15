import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/constants/app_spacing.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(title: l10n.privacyPolicy, showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(
            l10n.privacyIntro,
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.privacyDataTitle, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.privacyDataBody,
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.privacyUseTitle, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.privacyUseBody,
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.privacySecurityTitle, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.privacySecurityBody,
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
