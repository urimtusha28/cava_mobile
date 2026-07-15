import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/utils/auth_form_validator.dart';
import '../controllers/auth_controller.dart';

enum AuthBottomSheetMode { login, register }

Future<void> showAuthBottomSheet({
  required BuildContext context,
  required AuthController controller,
  AuthBottomSheetMode initialMode = AuthBottomSheetMode.login,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 24,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: _AuthSheetBody(
                  controller: controller,
                  scrollController: scrollController,
                  initialMode: initialMode,
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

enum _AuthSheetMode { login, register, forgotPassword }

class _AuthSheetBody extends StatefulWidget {
  const _AuthSheetBody({
    required this.controller,
    required this.scrollController,
    required this.initialMode,
  });

  final AuthController controller;
  final ScrollController scrollController;
  final AuthBottomSheetMode initialMode;

  @override
  State<_AuthSheetBody> createState() => _AuthSheetBodyState();
}

class _AuthSheetBodyState extends State<_AuthSheetBody> {
  late _AuthSheetMode _mode = switch (widget.initialMode) {
    AuthBottomSheetMode.login => _AuthSheetMode.login,
    AuthBottomSheetMode.register => _AuthSheetMode.register,
  };

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _forgotEmailController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _nameError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _forgotEmailController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _nameError = null;
      _confirmPasswordError = null;
    });
  }

  Future<void> _submitLogin() async {
    _clearErrors();
    final emailError = AuthFormValidator.validateEmail(_loginEmailController.text);
    final passwordError =
        AuthFormValidator.validatePassword(_loginPasswordController.text);
    if (emailError != null || passwordError != null) {
      setState(() {
        _emailError = emailError;
        _passwordError = passwordError;
      });
      return;
    }

    final result = await widget.controller.signIn(
      email: _loginEmailController.text.trim(),
      password: _loginPasswordController.text,
    );
    if (!mounted) {
      return;
    }
    if (result.isSuccess) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submitRegister() async {
    _clearErrors();
    final nameError = AuthFormValidator.validateName(_registerNameController.text);
    final emailError =
        AuthFormValidator.validateEmail(_registerEmailController.text);
    final passwordError =
        AuthFormValidator.validatePassword(_registerPasswordController.text);
    final confirmError = AuthFormValidator.validateConfirmPassword(
      _registerPasswordController.text,
      _registerConfirmPasswordController.text,
    );
    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmError != null) {
      setState(() {
        _nameError = nameError;
        _emailError = emailError;
        _passwordError = passwordError;
        _confirmPasswordError = confirmError;
      });
      return;
    }

    final result = await widget.controller.signUp(
      email: _registerEmailController.text.trim(),
      password: _registerPasswordController.text,
      name: _registerNameController.text.trim(),
    );
    if (!mounted) {
      return;
    }
    if (result.isSuccess) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submitForgotPassword() async {
    final l10n = AppLocalizations.of(context);
    _clearErrors();
    final emailError =
        AuthFormValidator.validateEmail(_forgotEmailController.text);
    if (emailError != null) {
      setState(() => _emailError = emailError);
      return;
    }

    final result = await widget.controller.resetPassword(
      email: _forgotEmailController.text.trim(),
    );
    if (!mounted) {
      return;
    }
    if (result.isSuccess) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.authResetEmailSent,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.burgundy,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.lg,
                AppSpacing.screen,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _mode == _AuthSheetMode.forgotPassword
                          ? l10n.authResetPasswordTitle
                          : l10n.authWelcome,
                      style: AppTextStyles.h2,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 22),
                  ),
                ],
              ),
            ),
            if (_mode != _AuthSheetMode.forgotPassword)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                child: _AuthModeToggle(
                  isLogin: _mode == _AuthSheetMode.login,
                  onLoginTap: () => setState(() => _mode = _AuthSheetMode.login),
                  onRegisterTap: () =>
                      setState(() => _mode = _AuthSheetMode.register),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView(
                controller: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  0,
                  AppSpacing.screen,
                  AppSpacing.xxl,
                ),
                children: [
                  if (_mode == _AuthSheetMode.login) ...[
                    _AuthTextField(
                      controller: _loginEmailController,
                      label: l10n.email,
                      keyboardType: TextInputType.emailAddress,
                      errorText: _emailError,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _AuthTextField(
                      controller: _loginPasswordController,
                      label: l10n.password,
                      obscureText: true,
                      errorText: _passwordError,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: widget.controller.authActionLoading
                            ? null
                            : () {
                                _forgotEmailController.text =
                                    _loginEmailController.text.trim();
                                setState(() {
                                  _mode = _AuthSheetMode.forgotPassword;
                                  _clearErrors();
                                });
                              },
                        child: Text(
                          l10n.authForgotPassword,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.burgundy,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _AuthSubmitButton(
                      label: l10n.login,
                      loading: widget.controller.authActionLoading,
                      onPressed: _submitLogin,
                    ),
                  ] else if (_mode == _AuthSheetMode.register) ...[
                    _AuthTextField(
                      controller: _registerNameController,
                      label: l10n.name,
                      errorText: _nameError,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _AuthTextField(
                      controller: _registerEmailController,
                      label: l10n.email,
                      keyboardType: TextInputType.emailAddress,
                      errorText: _emailError,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _AuthTextField(
                      controller: _registerPasswordController,
                      label: l10n.password,
                      obscureText: true,
                      errorText: _passwordError,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _AuthTextField(
                      controller: _registerConfirmPasswordController,
                      label: l10n.authConfirmPassword,
                      obscureText: true,
                      errorText: _confirmPasswordError,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _AuthSubmitButton(
                      label: l10n.register,
                      loading: widget.controller.authActionLoading,
                      onPressed: _submitRegister,
                    ),
                  ] else ...[
                    Text(
                      l10n.authForgotPasswordHint,
                      style: AppTextStyles.bodySmall.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _AuthTextField(
                      controller: _forgotEmailController,
                      label: l10n.email,
                      keyboardType: TextInputType.emailAddress,
                      errorText: _emailError,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _AuthSubmitButton(
                      label: l10n.authSendLink,
                      loading: widget.controller.authActionLoading,
                      onPressed: _submitForgotPassword,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: widget.controller.authActionLoading
                          ? null
                          : () => setState(() {
                                _mode = _AuthSheetMode.login;
                                _clearErrors();
                              }),
                      child: Text(
                        l10n.authBackToLogin,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.burgundy,
                        ),
                      ),
                    ),
                  ],
                  if (widget.controller.authActionError != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      widget.controller.authActionError!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFFB00020),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AuthModeToggle extends StatelessWidget {
  const _AuthModeToggle({
    required this.isLogin,
    required this.onLoginTap,
    required this.onRegisterTap,
  });

  final bool isLogin;
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AuthToggleChip(
              label: l10n.login,
              selected: isLogin,
              onTap: onLoginTap,
            ),
          ),
          Expanded(
            child: _AuthToggleChip(
              label: l10n.register,
              selected: !isLogin,
              onTap: onRegisterTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthToggleChip extends StatelessWidget {
  const _AuthToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          height: 44,
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: selected ? AppColors.burgundy : AppColors.textMuted,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            errorText: errorText,
            filled: true,
            fillColor: AppColors.surfaceMuted,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthSubmitButton extends StatelessWidget {
  const _AuthSubmitButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.burgundy,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 52,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(label, style: AppTextStyles.button),
          ),
        ),
      ),
    );
  }
}
