import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  List<_Conversation> _conversations(AppLocalizations l10n) => [
        _Conversation(
          name: l10n.messagesSupportName,
          preview: l10n.messagesSupportPreview,
          time: '10:32',
          unread: 1,
        ),
        _Conversation(
          name: l10n.messagesOffersName,
          preview: l10n.messagesOffersPreview,
          time: l10n.relativeYesterday,
          unread: 0,
        ),
        _Conversation(
          name: l10n.messagesCartName,
          preview: l10n.messagesCartPreview,
          time: l10n.weekdayTue,
          unread: 0,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final conversations = _conversations(l10n);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(title: l10n.messagesTitle),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screen),
        itemCount: conversations.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, index) => _MessageTile(conversation: conversations[index]),
      ),
    );
  }
}

class _Conversation {
  const _Conversation({
    required this.name,
    required this.preview,
    required this.time,
    required this.unread,
  });

  final String name;
  final String preview;
  final String time;
  final int unread;
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.conversation});

  final _Conversation conversation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.burgundy.withValues(alpha: 0.1),
            child: const Icon(Icons.storefront_outlined, color: AppColors.burgundy),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        conversation.name,
                        style: AppTextStyles.body,
                      ),
                    ),
                    Text(conversation.time, style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  conversation.preview,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (conversation.unread > 0) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.burgundy,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${conversation.unread}',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
