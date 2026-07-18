import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../domain/entities/owner_settings_entities.dart';
import '../controllers/owner_settings_controller.dart';

class OwnerUsersScreen extends StatefulWidget {
  const OwnerUsersScreen({super.key});

  @override
  State<OwnerUsersScreen> createState() => _OwnerUsersScreenState();
}

class _OwnerUsersScreenState extends State<OwnerUsersScreen> {
  late final OwnerSettingsController _controller;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _controller = createOwnerSettingsController();
    _loadFuture = _controller.loadUsers();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(title: l10n.ownerUsersTitle, showBack: true),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, _) {
          return ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.status == OwnerSettingsViewStatus.loading ||
                  _controller.status == OwnerSettingsViewStatus.initial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.burgundy),
                );
              }
              if (_controller.status == OwnerSettingsViewStatus.error) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.screen),
                    child: Text(
                      _controller.sectionError ?? l10n.ownerUsersLoadFailed,
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              final users = _controller.users;
              if (users.isEmpty) {
                return Center(
                  child: Text(
                    l10n.ownerNoUsers,
                    style: AppTextStyles.emptyState,
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.screen),
                itemCount: users.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => _UserTile(user: users[index]),
              );
            },
          );
        },
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});

  final OwnerListedUser user;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = user.createdAt == null
        ? '—'
        : DateFormat.yMMMd(locale).format(user.createdAt!);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.burgundy,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(user.email, style: AppTextStyles.bodySmall),
                Text(
                  '${user.role} · $dateLabel',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
