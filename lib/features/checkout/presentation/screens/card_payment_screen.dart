import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/place_order_result_entity.dart';
import '../controllers/card_payment_controller.dart';

/// Quipu HPP handoff + return verification screen.
///
/// The card is entered ONLY on the Quipu hosted payment page (external
/// browser). This screen initiates the session via the backend, opens the
/// redirect URL, and on return verifies the real payment status with the
/// backend — the redirect itself is never treated as proof of payment.
class CardPaymentScreen extends StatefulWidget {
  const CardPaymentScreen({super.key, this.order});

  final PlaceOrderResultEntity? order;

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen>
    with WidgetsBindingObserver {
  late final CardPaymentController _controller;
  bool _launchFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = createCardPaymentController();
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.onAppResumed();
    }
  }

  Future<void> _start() async {
    final order = widget.order;
    if (order == null) {
      // Cold start / deep entry: resume a persisted in-flight payment.
      final restored = await _controller.restorePending();
      if (restored) {
        await _controller.verifyNow();
      }
      return;
    }
    final url = await _controller.start(order);
    if (url != null) {
      await _openPaymentPage(url);
    }
  }

  Future<void> _openPaymentPage(String url) async {
    final uri = Uri.tryParse(url);
    var launched = false;
    if (uri != null) {
      try {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        launched = false;
      }
    }
    if (!launched && mounted) {
      setState(() => _launchFailed = true);
    }
  }

  Future<void> _reopen() async {
    final url = _controller.redirectUrl;
    if (url != null) {
      setState(() => _launchFailed = false);
      await _openPaymentPage(url);
    }
  }

  void _goToOrderSuccess() {
    final order = _controller.order ?? widget.order;
    if (order != null) {
      context.go(AppRoutes.orderSuccess, extra: order);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(title: l10n.cardPaymentTitle),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: _buildBody(l10n),
          );
        },
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    switch (_controller.phase) {
      case CardPaymentPhase.idle:
      case CardPaymentPhase.initiating:
        return _ProgressState(text: l10n.cardPaymentInitiating);
      case CardPaymentPhase.verifying:
        return _ProgressState(
          text: l10n.cardPaymentVerifying,
          subText: l10n.cardPaymentVerifyingText,
        );
      case CardPaymentPhase.awaitingPayment:
        return _ResultState(
          icon: Icons.lock_outline,
          iconColor: AppColors.burgundy,
          title: l10n.cardPaymentAwaitingTitle,
          text: _launchFailed
              ? l10n.cardPaymentLaunchFailed
              : l10n.cardPaymentAwaitingText,
          order: _controller.order,
          actions: [
            PrimaryButton(
              label: l10n.cardPaymentVerifyNow,
              onPressed:
                  _controller.canVerify ? _controller.verifyNow : null,
            ),
            const SizedBox(height: AppSpacing.md),
            _SecondaryAction(
              label: l10n.cardPaymentOpenAgain,
              onPressed: _controller.canReopenPaymentPage ? _reopen : null,
            ),
          ],
        );
      case CardPaymentPhase.paid:
        return _ResultState(
          icon: Icons.check_rounded,
          iconColor: AppColors.burgundy,
          title: l10n.cardPaymentPaidTitle,
          text: l10n.cardPaymentPaidText,
          order: _controller.order,
          actions: [
            PrimaryButton(
              label: l10n.orderSuccessAppBar,
              onPressed: _goToOrderSuccess,
            ),
          ],
        );
      case CardPaymentPhase.pending:
        return _ResultState(
          icon: Icons.hourglass_top_rounded,
          iconColor: AppColors.textSecondary,
          title: l10n.cardPaymentPendingTitle,
          text: l10n.cardPaymentPendingText,
          order: _controller.order,
          actions: [
            PrimaryButton(
              label: l10n.cardPaymentVerifyNow,
              onPressed:
                  _controller.canVerify ? _controller.verifyNow : null,
            ),
            const SizedBox(height: AppSpacing.md),
            _SecondaryAction(
              label: l10n.cardPaymentOpenAgain,
              onPressed: _controller.canReopenPaymentPage ? _reopen : null,
            ),
          ],
        );
      case CardPaymentPhase.failed:
        return _ResultState(
          icon: Icons.close_rounded,
          iconColor: AppColors.burgundy,
          title: l10n.cardPaymentFailedTitle,
          text: l10n.cardPaymentFailedText,
          order: _controller.order,
          actions: [
            PrimaryButton(
              label: l10n.cardPaymentBackToCheckout,
              onPressed: () => context.go(AppRoutes.checkout),
            ),
          ],
        );
      case CardPaymentPhase.cancelled:
        return _ResultState(
          icon: Icons.block_rounded,
          iconColor: AppColors.textSecondary,
          title: l10n.cardPaymentCancelledTitle,
          text: l10n.cardPaymentCancelledText,
          order: _controller.order,
          actions: [
            PrimaryButton(
              label: l10n.cardPaymentBackToCheckout,
              onPressed: () => context.go(AppRoutes.checkout),
            ),
          ],
        );
      case CardPaymentPhase.expired:
        return _ResultState(
          icon: Icons.timer_off_outlined,
          iconColor: AppColors.textSecondary,
          title: l10n.cardPaymentExpiredTitle,
          text: l10n.cardPaymentExpiredText,
          order: _controller.order,
          actions: [
            PrimaryButton(
              label: l10n.cardPaymentBackToCheckout,
              onPressed: () => context.go(AppRoutes.checkout),
            ),
          ],
        );
      case CardPaymentPhase.error:
        return _ResultState(
          icon: Icons.error_outline_rounded,
          iconColor: AppColors.burgundy,
          title: l10n.cardPaymentErrorTitle,
          text: l10n.cardPaymentErrorText,
          order: _controller.order,
          actions: [
            if (_controller.transactionId != null) ...[
              PrimaryButton(
                label: l10n.cardPaymentVerifyNow,
                onPressed:
                    _controller.canVerify ? _controller.verifyNow : null,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            _SecondaryAction(
              label: l10n.cardPaymentBackToCheckout,
              onPressed: () => context.go(AppRoutes.checkout),
            ),
          ],
        );
    }
  }
}

class _ProgressState extends StatelessWidget {
  const _ProgressState({required this.text, this.subText});

  final String text;
  final String? subText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.burgundy),
          const SizedBox(height: AppSpacing.xxl),
          Text(text, style: AppTextStyles.h3, textAlign: TextAlign.center),
          if (subText != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              subText!,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultState extends StatelessWidget {
  const _ResultState({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.text,
    required this.actions,
    this.order,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String text;
  final PlaceOrderResultEntity? order;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        const Spacer(),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 48),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(title, style: AppTextStyles.h1, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.md),
        Text(text, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        if (order != null) ...[
          const SizedBox(height: AppSpacing.xxl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.orderSuccessOrderLabel,
                      style: AppTextStyles.caption,
                    ),
                    Text(
                      order!.displayOrderNumber,
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.total, style: AppTextStyles.caption),
                    Text(
                      Formatters.currency(order!.total),
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const Spacer(),
        ...actions,
      ],
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.burgundy,
          side: const BorderSide(color: AppColors.burgundy),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
