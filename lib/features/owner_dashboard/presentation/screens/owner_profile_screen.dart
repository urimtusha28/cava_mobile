import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CavaAppBar(title: 'Profili', showBack: false),
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
                                ? 'Pronari'
                                : _authController.userName,
                            style: AppTextStyles.h3,
                          ),
                          Text(
                            'Roli: Owner / Admin',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                      : Text('Dil', style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                        )),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
