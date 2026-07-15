import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/utils/profile_form_validator.dart';
import '../controllers/profile_controller.dart';

Future<bool> openEditProfileSheet({
  required BuildContext context,
  required ProfileController controller,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: _EditProfileSheetBody(controller: controller),
      );
    },
  );
  return result ?? false;
}

class _EditProfileSheetBody extends StatefulWidget {
  const _EditProfileSheetBody({required this.controller});

  final ProfileController controller;

  @override
  State<_EditProfileSheetBody> createState() => _EditProfileSheetBodyState();
}

class _EditProfileSheetBodyState extends State<_EditProfileSheetBody> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  String? _firstNameError;
  String? _phoneError;
  bool _saving = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    final profile = widget.controller.profile;
    _firstNameController = TextEditingController(
      text: profile?.firstName ?? '',
    );
    _lastNameController = TextEditingController(text: profile?.lastName ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _emailController = TextEditingController(
      text: profile?.email.isNotEmpty == true
          ? profile!.email
          : widget.controller.email,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _firstNameError =
          ProfileFormValidator.validateFirstName(_firstNameController.text);
      _phoneError = ProfileFormValidator.validatePhone(_phoneController.text);
      _localError = null;
    });

    if (_firstNameError != null || _phoneError != null) {
      return;
    }

    setState(() => _saving = true);
    final result = await widget.controller.saveProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (result.isSuccess) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _localError = widget.controller.saveError ?? l10n.profileUpdateFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.md,
            AppSpacing.screen,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.editProfileTitle, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xl),
              _field(
                label: l10n.name,
                controller: _firstNameController,
                error: _firstNameError,
                enabled: !_saving,
              ),
              const SizedBox(height: AppSpacing.md),
              _field(
                label: l10n.lastName,
                controller: _lastNameController,
                enabled: !_saving,
              ),
              const SizedBox(height: AppSpacing.md),
              _field(
                label: l10n.phoneLabel,
                controller: _phoneController,
                error: _phoneError,
                keyboardType: TextInputType.phone,
                enabled: !_saving,
              ),
              const SizedBox(height: AppSpacing.md),
              _field(
                label: l10n.email,
                controller: _emailController,
                enabled: false,
              ),
              if (_localError != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _localError!,
                  style: AppTextStyles.caption.copyWith(color: Colors.red),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.burgundy,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? error,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: AppTextStyles.body.copyWith(
            color: enabled ? AppColors.textPrimary : AppColors.textMuted,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? AppColors.surfaceMuted : AppColors.border,
            errorText: error,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
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
