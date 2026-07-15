import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_spacing.dart';
import '../di/injection.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/notifications/domain/entities/app_notification.dart';
import '../../features/notifications/presentation/controllers/notifications_controller.dart';
import '../../features/notifications/presentation/utils/notification_presentation.dart';
import 'app_bottom_sheet.dart';
import 'support_bottom_sheet.dart';

Future<void> showNotificationsBottomSheet(BuildContext context) {
  configureDependencies();
  final controller = createNotificationsController();
  unawaited(controller.startListening());

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _NotificationsSheetScaffold(controller: controller);
    },
  ).whenComplete(controller.dispose);
}

void unawaited(Future<void> future) {
  future.ignore();
}

class _NotificationsSheetScaffold extends StatelessWidget {
  const _NotificationsSheetScaffold({required this.controller});

  final NotificationsController controller;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final subtitle = controller.unreadTodayCount > 0
                  ? '${controller.unreadTodayCount} të reja sot'
                  : 'Nuk ka njoftime të reja';

              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 24,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
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
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.burgundyDark,
                                  AppColors.burgundy,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Njoftimet', style: AppTextStyles.h2),
                                const SizedBox(height: 2),
                                Text(subtitle, style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, size: 22),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    Expanded(
                      child: _NotificationsBody(
                        controller: controller,
                        scrollController: scrollController,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody({
    required this.controller,
    required this.scrollController,
  });

  final NotificationsController controller;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && !controller.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.burgundy),
      );
    }

    if (controller.errorMessage != null && controller.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Njoftimet nuk u ngarkuan.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: controller.startListening,
                child: const Text('Provo përsëri'),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.items.isEmpty) {
      return ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Center(
            child: Text('Nuk keni njoftime.', style: AppTextStyles.body),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.lg,
        AppSpacing.screen,
        AppSpacing.xxl,
      ),
      itemCount: controller.items.length,
      itemBuilder: (context, index) {
        final item = controller.items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: SheetActionCard(
            icon: NotificationPresentation.iconForType(item.type),
            title: item.title,
            subtitle: item.body,
            highlighted: !item.isRead,
            trailing: !item.isRead
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.burgundy,
                      shape: BoxShape.circle,
                    ),
                  )
                : Text(
                    NotificationPresentation.formatRelativeDate(item.createdAt),
                    style: AppTextStyles.caption,
                  ),
            onTap: () => _onTap(context, item),
          ),
        );
      },
    );
  }

  Future<void> _onTap(BuildContext context, AppNotification item) async {
    if (!item.isRead) {
      await controller.markRead(item.id);
    }

    if (!context.mounted) return;

    if (item.orderId != null && item.orderId!.isNotEmpty) {
      Navigator.pop(context);
      context.push(AppRoutes.orders);
      return;
    }
    if (item.productId != null && item.productId!.isNotEmpty) {
      Navigator.pop(context);
      context.push(AppRoutes.product(item.productId!));
      return;
    }
    if (item.conversationId != null && item.conversationId!.isNotEmpty) {
      Navigator.pop(context);
      await showSupportBottomSheet(context);
    }
  }
}
