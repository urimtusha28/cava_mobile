import 'package:flutter/material.dart';
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

  return showAppBottomSheet(
    context: context,
    title: 'Support',
    subtitle: 'Jemi këtu për t\'ju ndihmuar',
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
    final loggedIn = await widget.controller.isLoggedIn;
    if (!loggedIn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kyçu për të kontaktuar support-in.',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.burgundy,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Kyçu',
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
                  Text('Si mund t\'ju ndihmojmë?', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Pyet për produkte, porosi, dërgesa ose çdo gjë tjetër rreth Cava Premium.',
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
                    label: 'Email',
                    onTap: _launchEmail,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _QuickContactChip(
                    icon: Icons.phone_outlined,
                    label: 'Telefon',
                    onTap: _launchPhone,
                  ),
                ),
              ],
            ),
            if (hasChat) ...[
              const SizedBox(height: AppSpacing.lg),
              Text('Biseda', style: AppTextStyles.h3),
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
            Text('Shkruaj pyetjen tënde', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _textController,
              minLines: hasChat ? 2 : 4,
              maxLines: hasChat ? 4 : 6,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'P.sh. A e keni këtë verë në stok?',
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
                        : Text('Dërgo pyetjen', style: AppTextStyles.button),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const SheetActionCard(
              icon: Icons.schedule_outlined,
              title: 'Orari i supportit',
              subtitle: 'E Hënë – E Shtunë, 09:00 – 20:00',
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
