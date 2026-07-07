import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/utils/address_form_validator.dart';
import '../../domain/usecases/address_usecases.dart';
import '../controllers/addresses_controller.dart';

Future<void> showAddAddressBottomSheet({
  required BuildContext context,
  required AddressesController controller,
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
          initialChildSize: 0.88,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: _AddAddressSheetBody(
                  controller: controller,
                  scrollController: scrollController,
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

class _AddAddressSheetBody extends StatefulWidget {
  const _AddAddressSheetBody({
    required this.controller,
    required this.scrollController,
  });

  final AddressesController controller;
  final ScrollController scrollController;

  @override
  State<_AddAddressSheetBody> createState() => _AddAddressSheetBodyState();
}

class _AddAddressSheetBodyState extends State<_AddAddressSheetBody> {
  final _labelController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController(text: 'Kosovë');
  bool _isDefault = false;

  String? _fullNameError;
  String? _phoneError;
  String? _streetError;
  String? _cityError;
  String? _countryError;

  @override
  void dispose() {
    _labelController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _fullNameError = AddressFormValidator.validateFullName(_fullNameController.text);
      _phoneError = AddressFormValidator.validatePhone(_phoneController.text);
      _streetError = AddressFormValidator.validateStreet(_streetController.text);
      _cityError = AddressFormValidator.validateCity(_cityController.text);
      _countryError = AddressFormValidator.validateCountry(_countryController.text);
    });

    if (_fullNameError != null ||
        _phoneError != null ||
        _streetError != null ||
        _cityError != null ||
        _countryError != null) {
      return;
    }

    final result = await widget.controller.addAddress(
      AddAddressParams(
        label: _labelController.text,
        fullName: _fullNameController.text,
        phone: _phoneController.text,
        street: _streetController.text,
        city: _cityController.text,
        country: _countryController.text,
        zip: _zipController.text,
        isDefault: _isDefault,
      ),
    );

    if (!mounted) {
      return;
    }
    if (result.isSuccess) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Text('Shto adresë', style: AppTextStyles.h2),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 22),
                  ),
                ],
              ),
            ),
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
                  _Field(controller: _labelController, label: 'Etiketa'),
                  _Field(controller: _fullNameController, label: 'Emri i plotë', errorText: _fullNameError),
                  _Field(controller: _phoneController, label: 'Telefoni', errorText: _phoneError, keyboardType: TextInputType.phone),
                  _Field(controller: _streetController, label: 'Rruga', errorText: _streetError),
                  _Field(controller: _cityController, label: 'Qyteti', errorText: _cityError),
                  _Field(controller: _zipController, label: 'Kodi postar'),
                  _Field(controller: _countryController, label: 'Shteti', errorText: _countryError),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Vendos si adresë kryesore', style: AppTextStyles.body),
                    value: _isDefault,
                    activeThumbColor: AppColors.burgundy,
                    onChanged: widget.controller.actionLoading
                        ? null
                        : (value) => setState(() => _isDefault = value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SubmitButton(
                    loading: widget.controller.actionLoading,
                    onPressed: _submit,
                  ),
                  if (widget.controller.actionError != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      widget.controller.actionError!,
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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.errorText,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: controller,
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
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.loading,
    required this.onPressed,
  });

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
                : Text('Ruaj adresën', style: AppTextStyles.button),
          ),
        ),
      ),
    );
  }
}
