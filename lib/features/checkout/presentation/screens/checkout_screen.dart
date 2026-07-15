import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/router/post_auth_navigator.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/cava_checkbox.dart';
import '../../../../core/widgets/checkout_screen_header.dart';
import '../../../../core/widgets/footer_action_button.dart';
import '../../../account/presentation/controllers/auth_controller.dart';
import '../../../account/presentation/widgets/auth_bottom_sheet.dart';
import '../controllers/checkout_controller.dart';
import '../models/checkout_session_state.dart';
import '../widgets/checkout_address_selector_bottom_sheet.dart';
import '../widgets/guest_checkout_info_bottom_sheet.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final CheckoutController _controller;
  late final AuthController _authController;
  late final Future<void> _loadFuture;

  String _payment = 'cash';
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _controller = createCheckoutController();
    _authController = createAuthController();
    _loadFuture = _controller.load();
  }

  Future<void> _handlePlaceOrder() async {
    final result = await _controller.submitOrder(
      paymentMethod: _payment,
      termsAccepted: _acceptedTerms,
    );

    if (!mounted) {
      return;
    }

    switch (result.status) {
      case CheckoutSubmitStatus.success:
        context.go(AppRoutes.orderSuccess, extra: result.order);
      case CheckoutSubmitStatus.validationError:
      case CheckoutSubmitStatus.requestError:
        _showMessage(result.message ?? AppLocalizations.of(context).orderCreateFailed);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.burgundy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openAddressSelector() async {
    await showCheckoutAddressSelectorBottomSheet(
      context: context,
      checkoutController: _controller,
    );
  }

  Future<void> _openGuestInfoSheet() async {
    await showGuestCheckoutInfoBottomSheet(
      context: context,
      checkoutController: _controller,
    );
  }

  Future<void> _openAuth(AuthBottomSheetMode mode) async {
    await showAuthBottomSheet(
      context: context,
      controller: _authController,
      initialMode: mode,
    );
    if (!mounted) {
      return;
    }
    await _controller.load();
    if (!mounted) {
      return;
    }
    PostAuthNavigator.navigateIfOwner(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckoutScreenHeader(
                      scriptTitle: AppLocalizations.of(context).checkoutScriptTitle,
                      boldTitle: AppLocalizations.of(context).checkoutBoldTitle,
                      showBack: true,
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screen,
                        ),
                        children: [
                          _UserInfoCard(
                            isLoggedIn: _controller.isLoggedIn,
                            email: _controller.customerInfo.email,
                            hasAddresses: _controller.hasAddresses,
                            hasSelectedAddress: _controller.hasSelectedAddress,
                            hasGuestCustomer: _controller.hasGuestCustomer,
                            fullName: _controller.customerInfo.fullName,
                            phone: _controller.customerInfo.phone,
                            address: _controller.customerInfo.addressLine,
                            city: _controller.customerInfo.city,
                            country: _controller.customerInfo.country,
                            zip: _controller.customerInfo.zip,
                            onChangeAddress: () => _openAddressSelector(),
                            onAddAddress: () => _openAddressSelector(),
                            onGuestCheckout: () => _openGuestInfoSheet(),
                            onEditGuestInfo: () => _openGuestInfoSheet(),
                            onLogin: () => _openAuth(AuthBottomSheetMode.login),
                            onRegister: () =>
                                _openAuth(AuthBottomSheetMode.register),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _PaymentMethodsCard(
                            selected: _payment,
                            onChanged: (value) =>
                                setState(() => _payment = value),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                    _CheckoutFooter(
                      total: _controller.total,
                      termsAccepted: _acceptedTerms,
                      onTermsChanged: _controller.isSubmitting
                          ? null
                          : (value) =>
                              setState(() => _acceptedTerms = value ?? false),
                      enabled: _acceptedTerms && !_controller.isSubmitting,
                      isLoading: _controller.isSubmitting,
                      onBuy: _handlePlaceOrder,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({
    required this.isLoggedIn,
    required this.email,
    required this.hasAddresses,
    required this.hasSelectedAddress,
    required this.hasGuestCustomer,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    required this.zip,
    required this.onChangeAddress,
    required this.onAddAddress,
    required this.onGuestCheckout,
    required this.onEditGuestInfo,
    required this.onLogin,
    required this.onRegister,
  });

  final bool isLoggedIn;
  final String email;
  final bool hasAddresses;
  final bool hasSelectedAddress;
  final bool hasGuestCustomer;
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String zip;
  final VoidCallback onChangeAddress;
  final VoidCallback onAddAddress;
  final VoidCallback onGuestCheckout;
  final VoidCallback onEditGuestInfo;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final trimmedName = fullName.trim();
    final trimmedEmail = email.trim();
    final trimmedPhone = phone.trim();
    final trimmedAddress = address.trim();
    final trimmedCity = city.trim();
    final trimmedCountry = country.trim();
    final trimmedZip = zip.trim();

    final showGuestActions = !isLoggedIn && !hasGuestCustomer;
    final showDeliveryDetails = isLoggedIn
        ? (hasAddresses && hasSelectedAddress)
        : hasGuestCustomer;

    return _BorderedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context).deliveryAddressTitle,
                  style: AppTextStyles.h3,
                ),
              ),
              if (isLoggedIn && hasAddresses)
                TextButton(
                  onPressed: onChangeAddress,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.burgundy,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppLocalizations.of(context).change,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.burgundy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else if (!isLoggedIn && hasGuestCustomer)
                TextButton(
                  onPressed: onEditGuestInfo,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.burgundy,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppLocalizations.of(context).change,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.burgundy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (showGuestActions)
            _GuestAuthActions(
              onGuestCheckout: onGuestCheckout,
              onLogin: onLogin,
              onRegister: onRegister,
            )
          else if (isLoggedIn && !hasAddresses)
            _DeliveryEmptyState(onAddAddress: onAddAddress)
          else if (isLoggedIn && !hasSelectedAddress)
            Text(
              AppLocalizations.of(context).selectDeliveryAddress,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else if (showDeliveryDetails) ...[
            if (trimmedName.isNotEmpty) ...[
              _InfoLine(AppLocalizations.of(context).infoName, trimmedName),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (trimmedEmail.isNotEmpty) ...[
              _InfoLine(AppLocalizations.of(context).infoEmail, trimmedEmail),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (trimmedAddress.isNotEmpty) ...[
              _InfoLine(AppLocalizations.of(context).infoAddress, trimmedAddress),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (trimmedCity.isNotEmpty) ...[
              _InfoLine(AppLocalizations.of(context).infoCity, trimmedCity),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (trimmedCountry.isNotEmpty) ...[
              _InfoLine(AppLocalizations.of(context).infoCountry, trimmedCountry),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (trimmedPhone.isNotEmpty) ...[
              _InfoLine(AppLocalizations.of(context).infoPhone, trimmedPhone),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (trimmedZip.isNotEmpty) _InfoLine(AppLocalizations.of(context).infoPostalCode, trimmedZip),
          ],
        ],
      ),
    );
  }
}

class _GuestAuthActions extends StatelessWidget {
  const _GuestAuthActions({
    required this.onGuestCheckout,
    required this.onLogin,
    required this.onRegister,
  });

  final VoidCallback onGuestCheckout;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context).notLoggedIn,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        _CheckoutActionButton(
          label: AppLocalizations.of(context).buyAsGuest,
          filled: true,
          onPressed: onGuestCheckout,
        ),
        const SizedBox(height: AppSpacing.md),
        _CheckoutActionButton(
          label: AppLocalizations.of(context).signIn,
          onPressed: onLogin,
        ),
        const SizedBox(height: AppSpacing.md),
        _CheckoutActionButton(
          label: AppLocalizations.of(context).register,
          onPressed: onRegister,
        ),
      ],
    );
  }
}

class _CheckoutActionButton extends StatelessWidget {
  const _CheckoutActionButton({
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    if (filled) {
      return SizedBox(
        height: 48,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.burgundy,
            foregroundColor: Colors.white,
            shape: shape,
          ),
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.burgundy,
          side: const BorderSide(color: AppColors.burgundy),
          shape: shape,
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.burgundy,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DeliveryEmptyState extends StatelessWidget {
  const _DeliveryEmptyState({required this.onAddAddress});

  final VoidCallback onAddAddress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 40,
          color: AppColors.textPrimary.withValues(alpha: 0.35),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppLocalizations.of(context).noAddressYet,
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: onAddAddress,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.burgundy,
            side: const BorderSide(color: AppColors.burgundy),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(AppLocalizations.of(context).addAddress, style: AppTextStyles.bodySmall),
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: AppTextStyles.body,
        children: [
          TextSpan(text: label, style: AppTextStyles.bodySmall),
          const TextSpan(text: ' '),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _PaymentMethodsCard extends StatelessWidget {
  const _PaymentMethodsCard({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _BorderedCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        children: [
          _PaymentOption(
            value: 'cash',
            groupValue: selected,
            icon: Icons.payments_outlined,
            title: AppLocalizations.of(context).payCash,
            onChanged: onChanged,
          ),
          const SizedBox(height: AppSpacing.xl),
          _PaymentOption(
            value: 'card',
            groupValue: selected,
            icon: Icons.credit_card_outlined,
            title: AppLocalizations.of(context).payCard,
            onChanged: onChanged,
          ),
          const SizedBox(height: AppSpacing.xl),
          _PaymentOption(
            value: 'bank',
            groupValue: selected,
            icon: Icons.account_balance_outlined,
            title: AppLocalizations.of(context).payBank,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.title,
    required this.onChanged,
  });

  final String value;
  final String groupValue;
  final IconData icon;
  final String title;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CavaCheckbox(
              value: selected,
              onChanged: (_) => onChanged(value),
            ),
            const SizedBox(width: AppSpacing.md),
            Icon(icon, size: 22, color: AppColors.textPrimary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(title, style: AppTextStyles.body)),
          ],
        ),
      ),
    );
  }
}

class _BorderedCard extends StatelessWidget {
  const _BorderedCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.25)),
      ),
      child: child,
    );
  }
}

class _CheckoutFooter extends StatelessWidget {
  const _CheckoutFooter({
    required this.total,
    required this.termsAccepted,
    required this.onTermsChanged,
    required this.enabled,
    required this.isLoading,
    required this.onBuy,
  });

  final double total;
  final bool termsAccepted;
  final ValueChanged<bool?>? onTermsChanged;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CavaCheckbox(
                value: termsAccepted,
                onChanged: onTermsChanged,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: AppTextStyles.bodySmall.copyWith(height: 1.5),
                    children: [
                      TextSpan(text: AppLocalizations.of(context).termsAgreePrefix),
                      TextSpan(
                        text: AppLocalizations.of(context).termsAndRules,
                        style: const TextStyle(
                          color: AppColors.burgundy,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: AppLocalizations.of(context).termsAgreeAnd),
                      TextSpan(
                        text: AppLocalizations.of(context).returnPolicy,
                        style: const TextStyle(
                          color: AppColors.burgundy,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text.rich(
                TextSpan(
                  text: '${AppLocalizations.of(context).totalColon} ',
                  style: AppTextStyles.body,
                  children: [
                    TextSpan(
                      text: Formatters.currency(total),
                      style: AppTextStyles.h3,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FooterActionButton(
                label: AppLocalizations.of(context).buy,
                onTap: onBuy,
                enabled: enabled,
                isLoading: isLoading,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
