import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/firebase/firebase_config.dart';
import '../../../../core/state/auth_state_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../controllers/auth_controller.dart';
import '../controllers/orders_controller.dart';
import '../utils/order_formatters.dart';
import '../widgets/auth_bottom_sheet.dart';
import '../widgets/order_detail_bottom_sheet.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final OrdersController _controller;
  late final AuthController _authController;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _controller = createOrdersController();
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
                  appBar: const CavaAppBar(title: 'Porositë e mia', showBack: true),
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
      return _LoginPrompt(
        onLoginTap: _openLogin,
      );
    }

    if (_controller.orders.isEmpty) {
      return const _EmptyState(message: 'Nuk ke porosi ende.');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screen),
      itemCount: _controller.orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, index) {
        final order = _controller.orders[index];
        return Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onTap: () => showOrderDetailBottomSheet(
              context: context,
              order: order,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          order.displayOrderNumber,
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                      Text(
                        formatOrderStatus(order.status),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.burgundy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    formatPaymentStatus(order.paymentStatus),
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatOrderTotal(order.total),
                    style: AppTextStyles.price.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.itemCount} produkte',
                    style: AppTextStyles.bodySmall,
                  ),
                  if (order.createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      formatOrderDate(order.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
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
              'Kyçu për të parë porositë e tua.',
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
