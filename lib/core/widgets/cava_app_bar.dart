import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_assets.dart';
import '../di/injection.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/notifications/presentation/controllers/notifications_unread_notifier.dart';
import 'notifications_bottom_sheet.dart';
import 'support_bottom_sheet.dart';

class CavaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CavaAppBar({
    super.key,
    this.title,
    this.showBack = false,
    this.isLogo = false,
    this.centerTitle = true,
    this.titleStyle,
    this.backgroundColor,
    this.actions,
  });

  final String? title;
  final bool showBack;
  final bool isLogo;
  final bool centerTitle;
  final TextStyle? titleStyle;
  final Color? backgroundColor;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      surfaceTintColor: backgroundColor,
      centerTitle: isLogo ? false : centerTitle,
      automaticallyImplyLeading: false,
      titleSpacing: isLogo ? 16 : null,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => context.pop(),
            )
          : null,
      title: isLogo ? const _BrandTitle() : _buildTitle(),
      actions: actions ?? (isLogo ? const [_RingingAction(), _ChatAction()] : null),
    );
  }

  Widget? _buildTitle() {
    if (title == null) return null;
    return Text(title!, style: titleStyle ?? AppTextStyles.h2);
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _CavaLogo(),
        const SizedBox(width: 10),
        Text(
          'Cava Premium',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.burgundy,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CavaLogo extends StatelessWidget {
  const _CavaLogo();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.logo,
      width: 36,
      height: 36,
      fit: BoxFit.contain,
      colorFilter: const ColorFilter.mode(AppColors.burgundy, BlendMode.srcIn),
      placeholderBuilder: (_) => const _LogoFallback(),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.wine_bar_rounded,
      color: AppColors.burgundy,
      size: 28,
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({
    required this.asset,
    required this.onPressed,
    this.badgeCount = 0,
  });

  final String asset;
  final VoidCallback onPressed;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Badge(
        isLabelVisible: badgeCount > 0,
        backgroundColor: AppColors.burgundy,
        smallSize: 8,
        label: Text(
          badgeCount > 99 ? '99+' : '$badgeCount',
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
        child: Image.asset(
          asset,
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          color: AppColors.textPrimary,
          colorBlendMode: BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _RingingAction extends StatelessWidget {
  const _RingingAction();

  @override
  Widget build(BuildContext context) {
    ensureNotificationsBadgeListening();
    if (!sl.isRegistered<NotificationsUnreadNotifier>()) {
      return _AppBarIconButton(
        asset: AppAssets.ringing,
        onPressed: () => showNotificationsBottomSheet(context),
      );
    }
    final notifier = sl<NotificationsUnreadNotifier>();
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        return _AppBarIconButton(
          asset: AppAssets.ringing,
          badgeCount: notifier.unreadCount,
          onPressed: () => showNotificationsBottomSheet(context),
        );
      },
    );
  }
}

class _ChatAction extends StatelessWidget {
  const _ChatAction();

  @override
  Widget build(BuildContext context) {
    return _AppBarIconButton(
      asset: AppAssets.chat,
      onPressed: () => showSupportBottomSheet(context),
    );
  }
}
