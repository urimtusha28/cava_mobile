import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/guest_checkout_customer.dart';
import '../../domain/utils/guest_checkout_form_validator.dart';
import '../controllers/checkout_controller.dart';

Future<void> showGuestCheckoutInfoBottomSheet({
  required BuildContext context,
  required CheckoutController checkoutController,
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
          initialChildSize: 0.9,
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
                child: _GuestCheckoutInfoSheetBody(
                  checkoutController: checkoutController,
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

class _GuestCheckoutInfoSheetBody extends StatefulWidget {
  const _GuestCheckoutInfoSheetBody({
    required this.checkoutController,
    required this.scrollController,
  });

  final CheckoutController checkoutController;
  final ScrollController scrollController;

  @override
  State<_GuestCheckoutInfoSheetBody> createState() =>
      _GuestCheckoutInfoSheetBodyState();
}

class _GuestCheckoutInfoSheetBodyState
    extends State<_GuestCheckoutInfoSheetBody> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _zipController;

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _addressError;
  String? _cityError;
  String? _countryError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.checkoutController.guestCustomer;
    _firstNameController =
        TextEditingController(text: existing?.firstName ?? '');
    _lastNameController = TextEditingController(text: existing?.lastName ?? '');
    _emailController = TextEditingController(text: existing?.email ?? '');
    _phoneController = TextEditingController(text: existing?.phone ?? '');
    _addressController = TextEditingController(text: existing?.address ?? '');
    _cityController = TextEditingController(text: existing?.city ?? '');
    _countryController =
        TextEditingController(text: existing?.country.isNotEmpty == true
            ? existing!.country
            : 'Kosovë');
    _zipController = TextEditingController(text: existing?.zip ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _firstNameError =
          GuestCheckoutFormValidator.validateFirstName(_firstNameController.text);
      _lastNameError =
          GuestCheckoutFormValidator.validateLastName(_lastNameController.text);
      _emailError =
          GuestCheckoutFormValidator.validateEmail(_emailController.text);
      _phoneError =
          GuestCheckoutFormValidator.validatePhone(_phoneController.text);
      _addressError =
          GuestCheckoutFormValidator.validateAddress(_addressController.text);
      _cityError =
          GuestCheckoutFormValidator.validateCity(_cityController.text);
      _countryError =
          GuestCheckoutFormValidator.validateCountry(_countryController.text);
    });

    if (_firstNameError != null ||
        _lastNameError != null ||
        _emailError != null ||
        _phoneError != null ||
        _addressError != null ||
        _cityError != null ||
        _countryError != null) {
      return;
    }

    setState(() => _saving = true);
    await widget.checkoutController.saveGuestCustomer(
      GuestCheckoutCustomer(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        country: _countryController.text.trim(),
        zip: _zipController.text.trim(),
      ),
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.lg,
            AppSpacing.screen,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Të dhënat e dorëzimit',
                  style: AppTextStyles.h3,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
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
              AppSpacing.xl,
            ),
            children: [
              _Field(
                controller: _firstNameController,
                label: 'Emri',
                errorText: _firstNameError,
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                controller: _lastNameController,
                label: 'Mbiemri',
                errorText: _lastNameError,
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                controller: _phoneController,
                label: 'Telefoni',
                keyboardType: TextInputType.phone,
                errorText: _phoneError,
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                controller: _addressController,
                label: 'Adresa',
                errorText: _addressError,
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                controller: _cityController,
                label: 'Qyteti',
                errorText: _cityError,
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                controller: _countryController,
                label: 'Shteti',
                errorText: _countryError,
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                controller: _zipController,
                label: 'Kodi postar',
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.burgundy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Ruaj',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
