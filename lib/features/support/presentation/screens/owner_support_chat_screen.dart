import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../domain/entities/support_conversation.dart';
import '../../domain/entities/support_status.dart';
import '../controllers/owner_support_controller.dart';

class OwnerSupportChatScreen extends StatefulWidget {
  const OwnerSupportChatScreen({
    super.key,
    required this.conversationId,
    this.initialConversation,
  });

  final String conversationId;
  final SupportConversation? initialConversation;

  @override
  State<OwnerSupportChatScreen> createState() => _OwnerSupportChatScreenState();
}

class _OwnerSupportChatScreenState extends State<OwnerSupportChatScreen> {
  late final OwnerSupportController _controller;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = createOwnerSupportController();
    final initial = widget.initialConversation;
    if (initial != null) {
      _controller.openConversation(initial);
    } else {
      _controller.load().then((_) {
        final match = _controller.conversations
            .where((c) => c.id == widget.conversationId)
            .firstOrNull;
        if (match != null) {
          _controller.openConversation(match);
        }
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final ok = await _controller.sendReply(_textController.text);
    if (ok) {
      _textController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(
        title: widget.initialConversation?.customerName ??
            l10n.ownerConversationFallback,
        showBack: true,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final selected = _controller.selected;
          return Column(
            children: [
              if (selected != null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screen,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      for (final status in SupportStatus.values)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: OutlinedButton(
                            onPressed: () => _controller.updateStatus(status),
                            child: Text(status.labelOf(l10n)),
                          ),
                        ),
                      OutlinedButton(
                        onPressed: _controller.assignToSelf,
                        child: Text(l10n.ownerAssignToMe),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _controller.messages.isEmpty
                    ? Center(
                        child: Text(
                          l10n.ownerNoMessages,
                          style: AppTextStyles.emptyState,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.screen),
                        itemCount: _controller.messages.length,
                        itemBuilder: (context, index) {
                          final m = _controller.messages[index];
                          final isStaff = m.senderRole.isStaff;
                          return Align(
                            alignment: isStaff
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: isStaff
                                    ? AppColors.burgundy.withValues(alpha: 0.12)
                                    : AppColors.surfaceMuted,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              child: Text(m.text, style: AppTextStyles.bodySmall),
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: l10n.ownerReplyHint,
                            filled: true,
                            fillColor: AppColors.surfaceMuted,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.burgundy,
                        ),
                        onPressed: _textController.text.trim().isEmpty ||
                                _controller.isSending
                            ? null
                            : _send,
                        icon: _controller.isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
