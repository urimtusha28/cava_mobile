import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/router/app_routes.dart';
import '../../data/mock/mock_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CavaAppBar(title: 'Profili'),
      body: ValueListenableBuilder<bool>(
        valueListenable: MockAuth.revision,
        builder: (context, isLoggedIn, child) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              _ProfileHeader(
                isLoggedIn: isLoggedIn,
                onLoginTap: MockAuth.login,
              ),
              const SizedBox(height: AppSpacing.xxl),
              _Tile(
                icon: Icons.shopping_bag_outlined,
                title: 'Porositë e mia',
                onTap: () => context.push(AppRoutes.orders),
              ),
              _Tile(
                icon: Icons.location_on_outlined,
                title: 'Adresat',
                onTap: () => context.push(AppRoutes.addresses),
              ),
              _Tile(
                icon: Icons.help_outline,
                title: 'Ndihmë & Kontakt',
                onTap: () => context.push(AppRoutes.help),
              ),
              _Tile(
                icon: Icons.info_outline,
                title: 'Rreth Cava Premium',
                onTap: () => context.push(AppRoutes.about),
              ),
              _Tile(
                icon: Icons.language_outlined,
                title: 'Gjuha',
                onTap: () => context.push(AppRoutes.language),
              ),
              _Tile(
                icon: Icons.euro_outlined,
                title: 'Valuta',
                onTap: () => context.push(AppRoutes.currency),
              ),
              _Tile(
                icon: Icons.description_outlined,
                title: 'Kushtet e përdorimit',
                onTap: () => context.push(AppRoutes.terms),
              ),
              _Tile(
                icon: Icons.privacy_tip_outlined,
                title: 'Politika e privatësisë',
                onTap: () => context.push(AppRoutes.privacy),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.isLoggedIn,
    required this.onLoginTap,
  });

  final bool isLoggedIn;
  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoggedIn ? null : onLoginTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.surfaceMuted,
              child: const Icon(
                Icons.person_outline,
                color: AppColors.burgundy,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                isLoggedIn ? MockAuth.userName : 'Kyçu',
                style: AppTextStyles.h2.copyWith(
                  color: isLoggedIn ? AppColors.textPrimary : AppColors.burgundy,
                ),
              ),
            ),
            if (!isLoggedIn)
              const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: AppColors.burgundy, size: 22),
      ),
      title: Text(title, style: AppTextStyles.body),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
    );
  }
}
