import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../notifications/domain/entities/notification_type.dart';
import '../../domain/entities/support_conversation.dart';
import '../../domain/entities/support_status.dart';
import '../controllers/owner_support_controller.dart';

class OwnerSupportScreen extends StatefulWidget {
  const OwnerSupportScreen({super.key});

  @override
  State<OwnerSupportScreen> createState() => _OwnerSupportScreenState();
}

class _OwnerSupportScreenState extends State<OwnerSupportScreen> {
  late final OwnerSupportController _controller;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _controller = createOwnerSupportController();
    _loadFuture = _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openSendNotification() async {
    final l10n = AppLocalizations.of(context);
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final uidCtrl = TextEditingController();
    var type = NotificationType.general;

    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (ctx) {
        final sheetL10n = AppLocalizations.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.screen,
            right: AppSpacing.screen,
            top: AppSpacing.lg,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + AppSpacing.lg,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(sheetL10n.ownerSendNotification, style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: uidCtrl,
                    decoration: InputDecoration(
                      labelText: sheetL10n.ownerRecipientUid,
                    ),
                  ),
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: sheetL10n.ownerNotificationTitle,
                    ),
                  ),
                  TextField(
                    controller: bodyCtrl,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: sheetL10n.ownerNotificationBody,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButton<NotificationType>(
                    value: type,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                        value: NotificationType.general,
                        child: Text(sheetL10n.ownerNotificationTypeGeneral),
                      ),
                      DropdownMenuItem(
                        value: NotificationType.promotion,
                        child: Text(sheetL10n.ownerNotificationTypePromotion),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setModalState(() => type = v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.burgundy,
                    ),
                    onPressed: () async {
                      final ok = await _controller.sendNotification(
                        recipientUid: uidCtrl.text,
                        title: titleCtrl.text,
                        body: bodyCtrl.text,
                        type: type,
                      );
                      if (ctx.mounted) Navigator.pop(ctx, ok);
                    },
                    child: Text(sheetL10n.send),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    titleCtrl.dispose();
    bodyCtrl.dispose();
    uidCtrl.dispose();

    if (!mounted) return;
    if (sent == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.ownerNotificationSent,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.burgundy,
        ),
      );
    } else if (_controller.actionError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.actionError!,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.burgundy,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(
        title: l10n.ownerSupportTitle,
        showBack: false,
        actions: [
          TextButton(
            onPressed: _openSendNotification,
            child: Text(
              l10n.ownerSendNotification,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.burgundy),
            ),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, _) {
          return ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.isLoading && !_controller.isInitialized) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.burgundy),
                );
              }
              if (_controller.errorMessage != null &&
                  _controller.conversations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_controller.errorMessage!, style: AppTextStyles.body),
                      TextButton(
                        onPressed: () => _controller.load(),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screen,
                      ),
                      children: [
                        _FilterChip(
                          label: l10n.ownerFilterAll,
                          selected: _controller.statusFilter == null,
                          onTap: () => _controller.setFilter(null),
                        ),
                        for (final status in SupportStatus.values)
                          _FilterChip(
                            label: status.labelOf(l10n),
                            selected: _controller.statusFilter == status,
                            onTap: () => _controller.setFilter(status),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _controller.conversations.isEmpty
                        ? Center(
                            child: Text(
                              l10n.ownerNoConversations,
                              style: AppTextStyles.emptyState,
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.screen),
                            itemCount: _controller.conversations.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final c = _controller.conversations[index];
                              return _ConversationTile(
                                conversation: c,
                                onTap: () {
                                  context.push(
                                    AppRoutes.ownerSupportChat(c.id),
                                    extra: c,
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.burgundy.withValues(alpha: 0.15),
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: selected ? AppColors.burgundy : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  final SupportConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.customerName.isNotEmpty
                          ? conversation.customerName
                          : conversation.customerEmail,
                      style: AppTextStyles.body,
                    ),
                    Text(
                      conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      conversation.status.labelOf(l10n),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.burgundy,
                      ),
                    ),
                  ],
                ),
              ),
              if (conversation.unreadByAdmin > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.burgundy,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${conversation.unreadByAdmin}',
                    style: AppTextStyles.caption.copyWith(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
