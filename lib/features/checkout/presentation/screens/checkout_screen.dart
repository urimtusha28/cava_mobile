import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/checkout_screen_header.dart';
import '../controllers/checkout_controller.dart';
import '../models/checkout_session_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final CheckoutController _controller;
  late final Future<void> _loadFuture;

  String _payment = 'cash';
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _controller = createCheckoutController();
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
        _showMessage(result.message ?? 'Porosia nuk u krijua. Provo përsëri.');
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
            const CheckoutScreenHeader(
              scriptTitle: 'Finalizo',
              boldTitle: 'Porosinë',
              showBack: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                children: [
                  _UserInfoCard(
                    email: _controller.customerInfo.email,
                    address: _controller.customerInfo.addressLine,
                    city: _controller.customerInfo.city,
                    country: _controller.customerInfo.country,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PaymentMethodsCard(
                    selected: _payment,
                    onChanged: (value) => setState(() => _payment = value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PaymentDetailsCard(payment: _payment),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _acceptedTerms,
                          onChanged: _controller.isSubmitting
                              ? null
                              : (value) =>
                                  setState(() => _acceptedTerms = value ?? false),
                          activeColor: AppColors.burgundy,
                          side: const BorderSide(color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: AppTextStyles.bodySmall.copyWith(height: 1.5),
                            children: const [
                              TextSpan(text: 'Pajtohem me '),
                              TextSpan(
                                text: 'Kushtet & Rregullat',
                                style: TextStyle(
                                  color: AppColors.burgundy,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ' dhe '),
                              TextSpan(
                                text: 'Politikën e Kthimit',
                                style: TextStyle(
                                  color: AppColors.burgundy,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            _CheckoutFooter(
              total: _controller.total,
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
    required this.email,
    required this.address,
    required this.city,
    required this.country,
  });

  final String email;
  final String address;
  final String city;
  final String country;

  @override
  Widget build(BuildContext context) {
    return _BorderedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLine('Email:', email),
          const SizedBox(height: AppSpacing.sm),
          _InfoLine('Adresa:', address),
          const SizedBox(height: AppSpacing.sm),
          _InfoLine('Qyteti:', city),
          const SizedBox(height: AppSpacing.sm),
          _InfoLine('Shteti:', country),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                backgroundColor: AppColors.surfaceMuted,
                side: BorderSide(color: AppColors.textPrimary.withValues(alpha: 0.25)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text('Ndrysho', style: AppTextStyles.bodySmall),
            ),
          ),
        ],
      ),
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
          TextSpan(text: value.isEmpty ? ' ' : value),
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
      child: Column(
        children: [
          _PaymentOption(
            value: 'cash',
            groupValue: selected,
            icon: Icons.payments_outlined,
            title: 'Paguaj me para në dorë',
            onChanged: onChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          _PaymentOption(
            value: 'card',
            groupValue: selected,
            icon: Icons.credit_card_outlined,
            title: 'VISA / MasterCard',
            onChanged: onChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          _PaymentOption(
            value: 'bank',
            groupValue: selected,
            icon: Icons.account_balance_outlined,
            title: 'Transfer bankar',
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
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: selected ? AppColors.burgundy : Colors.transparent,
              border: Border.all(
                color: selected ? AppColors.burgundy : AppColors.textPrimary,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: selected
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Icon(icon, size: 22, color: AppColors.textPrimary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(title, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

class _PaymentDetailsCard extends StatelessWidget {
  const _PaymentDetailsCard({required this.payment});

  final String payment;

  @override
  Widget build(BuildContext context) {
    final details = switch (payment) {
      'cash' => (
        title: 'Pagesa me para në dorë',
        body: 'Pagesa kryhet kur ta pranoni porosinë.',
      ),
      'card' => (
        title: 'Pagesa me kartë',
        body: 'Do të ridrejtoheni në pagesën e sigurt online.',
      ),
      _ => (
        title: 'Transfer bankar',
        body: 'Detajet e llogarisë bankare do t\'ju dërgohen me email.',
      ),
    };

    return _BorderedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(details.title, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            details.body,
            style: AppTextStyles.bodySmall.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _BorderedCard extends StatelessWidget {
  const _BorderedCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
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
    required this.enabled,
    required this.isLoading,
    required this.onBuy,
  });

  final double total;
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
        border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.6))),
      ),
      child: Row(
        children: [
          Text.rich(
            TextSpan(
              text: 'Totali: ',
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
          Material(
            color: enabled ? AppColors.burgundy : AppColors.textMuted,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: enabled ? onBuy : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Bli', style: AppTextStyles.button),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
