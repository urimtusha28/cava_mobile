import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/locale/locale_scope.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeController = LocaleScope.of(context);
    final currentCode = localeController.locale.languageCode;

    final options = [
      (code: 'sq', label: l10n.languageAlbanian),
      (code: 'en', label: l10n.languageEnglish),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(title: l10n.language, showBack: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screen),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, index) {
          final option = options[index];
          final selected = option.code == currentCode;

          return InkWell(
            onTap: () => localeController.setLocale(Locale(option.code)),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: selected ? AppColors.burgundy : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(option.label, style: AppTextStyles.body),
                  ),
                  if (selected)
                    const Icon(Icons.check, color: AppColors.burgundy, size: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
