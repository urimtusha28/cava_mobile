import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CavaAppBar(title: 'Ndihmë & Kontakt', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          _InfoCard(
            icon: Icons.email_outlined,
            title: 'Email',
            value: 'info@cava-premium.com',
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoCard(
            icon: Icons.phone_outlined,
            title: 'Telefon',
            value: '+355 69 000 0000',
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoCard(
            icon: Icons.schedule_outlined,
            title: 'Orari',
            value: 'E Hënë – E Shtunë, 09:00 – 20:00',
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Pyetje të shpeshta', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          _FaqTile('Si mund ta ndjek porosinë time?'),
          _FaqTile('Cilat janë metodat e pagesës?'),
          _FaqTile('Sa kohë zgjat dërgesa?'),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
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
            child: Icon(icon, color: AppColors.burgundy, size: 22),
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
