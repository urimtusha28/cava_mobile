import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_assets.dart';
import '../di/injection.dart';
import '../firebase/firebase_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../../features/owner_dashboard/domain/entities/owner_settings_entities.dart';
import '../../features/owner_dashboard/domain/repositories/owner_settings_repository.dart';

class VisitStoreBanner extends StatefulWidget {
  const VisitStoreBanner({super.key});

  static const defaultMapsUrl =
      'https://www.google.com/maps/search/?api=1&query=The%20Village%20Shopping%20Fun%201%20Ahmet%20Kaciku%20Ferizaj%2070000';

  /// Kept for tests that reference the constant name.
  static const mapsUrl = defaultMapsUrl;

  @override
  State<VisitStoreBanner> createState() => _VisitStoreBannerState();
}

class _VisitStoreBannerState extends State<VisitStoreBanner> {
  HomepageSettings _settings = HomepageSettings.empty;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (!FirebaseConfig.enabled) {
      return;
    }
    try {
      configureDependencies();
      if (!sl.isRegistered<OwnerSettingsRepository>()) {
        return;
      }
      final result = await sl<OwnerSettingsRepository>().getHomepageSettings();
      if (!mounted) return;
      setState(() {
        _settings = result.dataOrNull ?? HomepageSettings.empty;
      });
    } catch (_) {}
  }

  String get _mapsUrl {
    final url = _settings.mapsUrl?.trim();
    if (url != null && url.isNotEmpty) return url;
    return VisitStoreBanner.defaultMapsUrl;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final address = _settings.storeAddress?.trim().isNotEmpty == true
        ? _settings.storeAddress!.trim()
        : l10n.visitStoreAddress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: GestureDetector(
        onTap: () => _showMapsDialog(context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 148,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _StoreLocationPreview(
                      imageUrl: _settings.storeBannerImageUrl,
                    ),
                    Positioned(
                      left: AppSpacing.md,
                      bottom: AppSpacing.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.storefront_outlined,
                              size: 16,
                              color: AppColors.burgundy,
                            ),
                            const SizedBox(width: 6),
                            Text(l10n.brandName, style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.visitStoreTitle,
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.visitStoreSubtitle,
                      style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        const Icon(
                          Icons.near_me_outlined,
                          size: 18,
                          color: AppColors.burgundy,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            address,
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMapsDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Text(l10n.openMapsTitle, style: AppTextStyles.h3),
          content: Text(
            l10n.openMapsMessage,
            style: AppTextStyles.bodySmall.copyWith(height: 1.45),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                l10n.openMapsCancel,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                l10n.openMapsConfirm,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.burgundy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldOpen == true && context.mounted) {
      await openStoreInMaps(context, mapsUrl: _mapsUrl);
    }
  }
}

/// Opens the store location in Google Maps (app or browser).
Future<void> openStoreInMaps(
  BuildContext context, {
  String mapsUrl = VisitStoreBanner.defaultMapsUrl,
}) async {
  final uri = Uri.parse(mapsUrl);

  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      _showMapsErrorSnackBar(context);
    }
  } catch (_) {
    if (context.mounted) {
      _showMapsErrorSnackBar(context);
    }
  }
}

void _showMapsErrorSnackBar(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        l10n.openMapsError,
        style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      ),
      backgroundColor: AppColors.burgundy,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    ),
  );
}

class _StoreLocationPreview extends StatelessWidget {
  const _StoreLocationPreview({
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, _) => Container(color: AppColors.surfaceMuted),
        errorWidget: (_, _, _) => Image.asset(
          AppAssets.storeLocation,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, _, _) => const _MapIllustrationFallback(),
        ),
      );
    }

    return Image.asset(
      AppAssets.storeLocation,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => const _MapIllustrationFallback(),
    );
  }
}

class _MapIllustrationFallback extends StatelessWidget {
  const _MapIllustrationFallback();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColors.surfaceMuted),
        CustomPaint(painter: const _MapGridPainter()),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  const _MapGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    for (var i = 1; i < 6; i++) {
      final x = size.width * i / 6;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.55),
      Offset(size.width * 0.9, size.height * 0.42),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.1),
      Offset(size.width * 0.55, size.height * 0.9),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
