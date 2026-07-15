import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/place_order_result_entity.dart';
import '../controllers/order_success_controller.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key, this.initialResult});

  final PlaceOrderResultEntity? initialResult;

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  late final OrderSuccessController _controller;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _controller = createOrderSuccessController();
    _loadFuture = _controller.load(widget.initialResult);
  }

  String _paymentLabel(AppLocalizations l10n, String method) {
    return switch (method) {
      'cash' => l10n.paymentMethodCash,
      'card' => l10n.paymentMethodCard,
      'bank' => l10n.paymentMethodBank,
      _ => method,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final result = _controller.result;

            return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(title: l10n.orderSuccessAppBar),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.burgundy.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.burgundy, size: 48),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(l10n.orderSuccessTitle, style: AppTextStyles.h1, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.orderSuccessThanks,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
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
                  _Row(l10n.orderSuccessOrderLabel, result?.displayOrderNumber ?? l10n.emDash),
                  const SizedBox(height: 10),
                  _Row(
                    l10n.total,
                    result != null ? Formatters.currency(result.total) : l10n.emDash,
                  ),
                  if (result != null) ...[
                    const SizedBox(height: 10),
                    _Row(
                      l10n.orderSuccessPaymentLabel,
                      _paymentLabel(l10n, result.paymentMethod),
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: l10n.backToHome,
              onPressed: () => context.go(AppRoutes.home),
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

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(value, style: AppTextStyles.body),
      ],
    );
  }
}
