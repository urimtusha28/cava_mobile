import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/app_session_notifier.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../account/presentation/controllers/auth_controller.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  late final AuthController _authController;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    configureDependencies();
    _authController = sl<AuthController>();
    _authController.load();
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    await _authController.logout();
    AppSessionNotifier.instance.clear();
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(title: l10n.ownerProfileTitle, showBack: false),
      body: ListenableBuilder(
        listenable: _authController,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        color: AppColors.burgundy,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _authController.userName.isEmpty
                                ? l10n.ownerFallbackName
                                : _authController.userName,
                            style: AppTextStyles.h3,
                          ),
                          Text(
                            l10n.ownerRoleLabel,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(l10n.ownerSettingsSection, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              _SettingsTile(
                icon: Icons.people_outline,
                title: l10n.ownerSettingsUsers,
                subtitle: l10n.ownerSettingsUsersSubtitle,
                onTap: () => context.push(AppRoutes.ownerSettingsUsers),
              ),
              _SettingsTile(
                icon: Icons.image_outlined,
                title: l10n.ownerSettingsStoreBanner,
                subtitle: l10n.ownerSettingsStoreBannerSubtitle,
                onTap: () => context.push(AppRoutes.ownerSettingsStoreBanner),
              ),
              _SettingsTile(
                icon: Icons.picture_as_pdf_outlined,
                title: l10n.ownerSettingsLegal,
                subtitle: l10n.ownerSettingsLegalSubtitle,
                onTap: () => context.push(AppRoutes.ownerSettingsLegal),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loggingOut ? null : _logout,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.burgundy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: _loggingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.logout,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(icon, color: AppColors.burgundy, size: 22),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.body),
                      Text(subtitle, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
