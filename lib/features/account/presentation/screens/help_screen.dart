import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(title: l10n.helpAndContact, showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          _InfoCard(
            iconAsset: AppAssets.mail,
            title: l10n.email,
            value: l10n.helpEmailValue,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoCard(
            iconAsset: AppAssets.phone,
            title: l10n.phone,
            value: l10n.helpPhoneValue,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoCard(
            iconAsset: AppAssets.supportHours,
            title: l10n.schedule,
            value: l10n.helpHoursValue,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.faqTitle, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          _FaqTile(l10n.faqTrackOrder),
          _FaqTile(l10n.faqPaymentMethods),
          _FaqTile(l10n.faqDeliveryTime),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.iconAsset,
    required this.title,
    required this.value,
  });

  final String iconAsset;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            alignment: Alignment.center,
            child: Image.asset(
              iconAsset,
              width: 22,
              height: 22,
              fit: BoxFit.contain,
              color: AppColors.burgundy,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile(this.question);

  final String question;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(question, style: AppTextStyles.body),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
    );
  }
}
