import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/firebase/firebase_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../owner_dashboard/domain/repositories/owner_settings_repository.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  String? _pdfUrl;

  @override
  void initState() {
    super.initState();
    _loadPdfUrl();
  }

  Future<void> _loadPdfUrl() async {
    if (!FirebaseConfig.enabled) return;
    try {
      configureDependencies();
      if (!sl.isRegistered<OwnerSettingsRepository>()) return;
      final result = await sl<OwnerSettingsRepository>().getLegalSettings();
      if (!mounted) return;
      setState(() => _pdfUrl = result.dataOrNull?.privacyPdfUrl);
    } catch (_) {}
  }

  Future<void> _openPdf() async {
    final url = _pdfUrl?.trim();
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasPdf = _pdfUrl?.trim().isNotEmpty == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(title: l10n.privacyPolicy, showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          if (hasPdf) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(l10n.ownerOpenPdf),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.burgundy,
                  side: const BorderSide(color: AppColors.burgundy),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(
            l10n.privacyIntro,
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.privacyDataTitle, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.privacyDataBody,
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.privacyUseTitle, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.privacyUseBody,
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.privacySecurityTitle, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.privacySecurityBody,
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
