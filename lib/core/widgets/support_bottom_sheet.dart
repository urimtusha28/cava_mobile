import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_bottom_sheet.dart';

Future<void> showSupportBottomSheet(BuildContext context) {
  return showAppBottomSheet(
    context: context,
    title: 'Support',
    subtitle: 'Jemi këtu për t\'ju ndihmuar',
    headerIcon: Icons.support_agent_rounded,
    child: const _SupportSheetBody(),
  );
}

class _SupportSheetBody extends StatefulWidget {
  const _SupportSheetBody();

  @override
  State<_SupportSheetBody> createState() => _SupportSheetBodyState();
}

class _SupportSheetBodyState extends State<_SupportSheetBody> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Si mund t\'ju ndihmojmë?', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Pyet për produkte, porosi, dërgesa ose çdo gjë tjetër rreth Cava Premium.',
                style: AppTextStyles.bodySmall.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: const [
            Expanded(
              child: _QuickContactChip(
                icon: Icons.email_outlined,
                label: 'Email',
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _QuickContactChip(
                icon: Icons.phone_outlined,
                label: 'Telefon',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Shkruaj pyetjen tënde', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _controller,
          minLines: 4,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'P.sh. A e keni këtë verë në stok?',
            hintStyle: AppTextStyles.bodySmall,
            filled: true,
            fillColor: AppColors.surfaceMuted,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.lg),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Material(
          color: AppColors.burgundy,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Mesazhi u dërgua. Do t\'ju përgjigjemi së shpejti.',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                  ),
                  backgroundColor: AppColors.burgundy,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 52,
              child: Center(child: Text('Dërgo pyetjen', style: AppTextStyles.button)),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SheetActionCard(
          icon: Icons.schedule_outlined,
          title: 'Orari i supportit',
          subtitle: 'E Hënë – E Shtunë, 09:00 – 20:00',
        ),
      ],
    );
  }
}

class _QuickContactChip extends StatelessWidget {
  const _QuickContactChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.burgundy),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
