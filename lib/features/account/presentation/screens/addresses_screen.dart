import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/firebase/firebase_config.dart';
import '../../../../core/state/auth_state_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../controllers/addresses_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/add_address_bottom_sheet.dart';
import '../widgets/auth_bottom_sheet.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  late final AddressesController _controller;
  late final AuthController _authController;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _controller = createAddressesController();
    _authController = createAuthController();
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
                  appBar: CavaAppBar(
                    title: 'Adresat',
                    showBack: true,
                    actions: isLoggedIn
                        ? [
                            TextButton(
                              onPressed: _openAddAddress,
                              child: Text(
                                'Shto',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.burgundy,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ]
                        : null,
                  ),
                  body: _buildBody(isLoggedIn),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBody(bool isLoggedIn) {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!isLoggedIn || _controller.requiresLogin) {
      return _LoginPrompt(onLoginTap: _openLogin);
    }

    if (_controller.addresses.isEmpty) {
      return const _EmptyState(message: 'Nuk ke adresa të ruajtura.');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screen),
      itemCount: _controller.addresses.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, index) {
        final address = _controller.addresses[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: address.isDefault ? AppColors.burgundy : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      address.label.isNotEmpty ? address.label : 'Adresë',
                      style: AppTextStyles.h3,
                    ),
                  ),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.burgundy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'Kryesore',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.burgundy,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(address.fullName, style: AppTextStyles.body),
              const SizedBox(height: 4),
              Text(address.displayLine, style: AppTextStyles.body),
              const SizedBox(height: 4),
              Text(address.phone, style: AppTextStyles.bodySmall),
              if (address.zip != null && address.zip!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Kodi postar: ${address.zip}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
              if (!address.isDefault) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => _controller.setDefault(address.id),
                  child: Text(
                    'Vendos si kryesore',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.burgundy,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _openLogin() {
    if (FirebaseConfig.enabled && FirebaseConfig.useFirebaseAuth) {
      showAuthBottomSheet(context: context, controller: _authController).then((_) {
        _controller.load();
      });
    } else {
      _authController.login().then((_) => _controller.load());
    }
  }

  void _openAddAddress() {
    showAddAddressBottomSheet(
      context: context,
      controller: _controller,
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kyçu për të menaxhuar adresat e tua.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Material(
              color: AppColors.burgundy,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onLoginTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: Text('Kyçu', style: AppTextStyles.button),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: AppTextStyles.body,
        textAlign: TextAlign.center,
      ),
    );
  }
}
