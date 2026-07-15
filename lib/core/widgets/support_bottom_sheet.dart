import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../di/injection.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/account/presentation/controllers/auth_controller.dart';
import '../../features/account/presentation/widgets/auth_bottom_sheet.dart';
import '../../features/support/domain/entities/sender_role.dart';
import '../../features/support/domain/entities/support_message.dart';
import '../../features/support/presentation/controllers/support_controller.dart';
import 'app_bottom_sheet.dart';

Future<void> showSupportBottomSheet(BuildContext context) {
  configureDependencies();
  final controller = createSupportController();
  unawaited(controller.load());
  final l10n = AppLocalizations.of(context);

  return showAppBottomSheet(
    context: context,
    title: l10n.supportTitle,
    subtitle: l10n.supportSubtitle,
    headerIcon: Icons.support_agent_rounded,
    child: _SupportSheetBody(controller: controller),
  ).whenComplete(controller.dispose);
}

void unawaited(Future<void> future) {
  future.ignore();
}

class _SupportSheetBody extends StatefulWidget {
  const _SupportSheetBody({required this.controller});

  final SupportController controller;

  @override
  State<_SupportSheetBody> createState() => _SupportSheetBodyState();
}

class _SupportSheetBodyState extends State<_SupportSheetBody> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _launchEmail() async {
    final email = widget.controller.contact.email;
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone() async {
    final phone = widget.controller.contact.phone.replaceAll(' ', '');
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _onSend() async {
    final l10n = AppLocalizations.of(context);
    final loggedIn = await widget.controller.isLoggedIn;
    if (!loggedIn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.supportLoginRequired,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.burgundy,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: l10n.login,
            textColor: Colors.white,
            onPressed: () {
              showAuthBottomSheet(
                context: context,
                controller: createAuthController(),
              );
            },
          ),
        ),
      );
      return;
    }

    final ok = await widget.controller.sendMessage(_textController.text);
    if (ok && mounted) {
      _textController.clear();
      setState(() {});
    } else if (widget.controller.sendError != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.sendError!,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.burgundy,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final c = widget.controller;
        final hasChat = c.conversation != null || c.messages.isNotEmpty;
        final canSend =
            _textController.text.trim().isNotEmpty && !c.isSending;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.supportHowCanWeHelp, style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.supportIntro,
                    style: AppTextStyles.bodySmall.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _QuickContactChip(
                    icon: Icons.email_outlined,
                    label: l10n.email,
                    onTap: _launchEmail,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _QuickContactChip(
                    icon: Icons.phone_outlined,
                    label: l10n.phone,
                    onTap: _launchPhone,
                  ),
                ),
              ],
            ),
            if (hasChat) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.supportConversation, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: c.messages.length,
                  itemBuilder: (context, index) {
                    return _MessageBubble(message: c.messages[index]);
                  },
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.supportWriteQuestion, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _textController,
              minLines: hasChat ? 2 : 4,
              maxLines: hasChat ? 4 : 6,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.supportQuestionHint,
                hintStyle: AppTextStyles.bodySmall,
                filled: true,
                fillColor: AppColors.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.lg),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Material(
              color: canSend
                  ? AppColors.burgundy
                  : AppColors.burgundy.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: canSend ? _onSend : null,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 52,
                  child: Center(
                    child: c.isSending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.supportSendQuestion, style: AppTextStyles.button),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SheetActionCard(
              icon: Icons.schedule_outlined,
              title: l10n.supportHoursTitle,
              subtitle: l10n.supportHoursValue,
            ),
          ],
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final SupportMessage message;

  @override
  Widget build(BuildContext context) {
    final isCustomer = message.senderRole == SenderRole.customer;
    return Align(
      alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isCustomer
              ? AppColors.burgundy.withValues(alpha: 0.12)
              : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          message.text,
          style: AppTextStyles.bodySmall.copyWith(height: 1.4),
        ),
      ),
    );
  }
}

class _QuickContactChip extends StatelessWidget {
  const _QuickContactChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.burgundy),
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
