import 'package:flutter/material.dart';

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
  String _selected = 'EUR (€)';

  static const _currencies = ['EUR (€)', 'USD (\$)', 'ALL (L)'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CavaAppBar(title: 'Valuta', showBack: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screen),
        itemCount: _currencies.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, index) {
          final currency = _currencies[index];
          final selected = currency == _selected;

          return InkWell(
            onTap: () => setState(() => _selected = currency),
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
                  Expanded(child: Text(currency, style: AppTextStyles.body)),
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
