import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/constants/app_spacing.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CavaAppBar(title: 'Kushtet e përdorimit', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(
            'Duke përdorur aplikacionin Cava Premium, ju pranoni kushtet e mëposhtme të përdorimit.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('1. Përdorimi i shërbimit', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Aplikacioni ofrohet për blerje produktesh të ligjshme nga persona të moshës 18 vjeç e lart.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('2. Porositë', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Çmimet dhe disponueshmëria e produkteve mund të ndryshojnë. Porosia konfirmohet pas pranimit të pagesës.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('3. Përgjegjësia', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Cava Premium përpiqet të ofrojë informacion të saktë, por nuk mban përgjegjësi për gabime teknike të përkohshme.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
