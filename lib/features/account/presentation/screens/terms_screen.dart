import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/constants/app_spacing.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(title: l10n.termsOfUse, showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(
            l10n.termsIntro,
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.termsSection1Title, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.termsSection1Body,
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.termsSection2Title, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.termsSection2Body,
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.termsSection3Title, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.termsSection3Body,
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
