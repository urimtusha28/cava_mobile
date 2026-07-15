import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String _selected = 'eur';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencies = [
      (code: 'eur', label: l10n.currencyEur),
      (code: 'usd', label: l10n.currencyUsd),
      (code: 'all', label: l10n.currencyAll),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(title: l10n.currency, showBack: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screen),
        itemCount: currencies.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, index) {
          final currency = currencies[index];
          final selected = currency.code == _selected;

          return InkWell(
            onTap: () => setState(() => _selected = currency.code),
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
                    child: Text(currency.label, style: AppTextStyles.body),
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
