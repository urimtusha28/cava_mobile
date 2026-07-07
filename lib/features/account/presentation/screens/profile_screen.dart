import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/firebase/firebase_config.dart';
import '../../../../core/state/auth_state_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/router/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_bottom_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthController _controller;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _controller = createAuthController();
    _loadFuture = _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        return ValueListenableBuilder<bool>(
          valueListenable: AuthStateNotifier.isLoggedIn,
          builder: (context, isLoggedIn, child) {
            return ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return Scaffold(
                  backgroundColor: AppColors.background,
                  appBar: const CavaAppBar(title: 'Profili'),
                  body: ListView(
                    padding: const EdgeInsets.all(AppSpacing.screen),
                    children: [
                      _ProfileHeader(
                        isLoggedIn: isLoggedIn,
                        userName: _controller.userName,
                        onLoginTap: () {
                          if (FirebaseConfig.enabled &&
                              FirebaseConfig.useFirebaseAuth) {
                            showAuthBottomSheet(
                              context: context,
                              controller: _controller,
                            );
                          } else {
                            _controller.login();
                          }
                        },
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
                        icon: Icons.description_outlined,
                        title: 'Kushtet e përdorimit',
                        onTap: () => context.push(AppRoutes.terms),
                      ),
                      _Tile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Politika e privatësisë',
                        onTap: () => context.push(AppRoutes.privacy),
                      ),
                      if (isLoggedIn)
                        _Tile(
                          icon: Icons.logout,
                          title: 'Dil',
                          onTap: () => _controller.logout(),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.isLoggedIn,
    required this.userName,
    required this.onLoginTap,
  });

  final bool isLoggedIn;
  final String userName;
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
                isLoggedIn ? userName : 'Kyçu',
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
