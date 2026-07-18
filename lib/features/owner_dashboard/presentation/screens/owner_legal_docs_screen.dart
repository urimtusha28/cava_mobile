import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../domain/entities/owner_settings_entities.dart';
import '../controllers/owner_settings_controller.dart';

class OwnerLegalDocsScreen extends StatefulWidget {
  const OwnerLegalDocsScreen({super.key});

  @override
  State<OwnerLegalDocsScreen> createState() => _OwnerLegalDocsScreenState();
}

class _OwnerLegalDocsScreenState extends State<OwnerLegalDocsScreen> {
  late final OwnerSettingsController _controller;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _controller = createOwnerSettingsController();
    _loadFuture = _controller.loadLegal();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _upload(LegalDocumentType type) async {
    final l10n = AppLocalizations.of(context);
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ownerNoPdfSelected),
          backgroundColor: AppColors.burgundy,
        ),
      );
      return;
    }

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ownerUploadFailed),
          backgroundColor: AppColors.burgundy,
        ),
      );
      return;
    }

    final ok = await _controller.uploadLegalPdf(type: type, bytes: bytes);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? l10n.ownerUploadSuccess
              : (_controller.sectionError ?? l10n.ownerUploadFailed),
        ),
        backgroundColor: AppColors.burgundy,
      ),
    );
  }

  Future<void> _openPdf(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(title: l10n.ownerLegalDocsTitle, showBack: true),
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
                      _controller.sectionError ?? l10n.errorGeneric,
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final legal = _controller.legal;
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.screen),
                children: [
                  _LegalCard(
                    title: l10n.ownerLegalTermsPdf,
                    hasPdf: legal.termsPdfUrl?.isNotEmpty == true,
                    isSaving: _controller.isSaving,
                    uploadedLabel: l10n.ownerPdfUploaded,
                    missingLabel: l10n.ownerPdfMissing,
                    uploadLabel: legal.termsPdfUrl?.isNotEmpty == true
                        ? l10n.ownerReplacePdf
                        : l10n.ownerUploadPdf,
                    openLabel: l10n.ownerOpenPdf,
                    onUpload: () => _upload(LegalDocumentType.terms),
                    onOpen: () => _openPdf(legal.termsPdfUrl),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _LegalCard(
                    title: l10n.ownerLegalPrivacyPdf,
                    hasPdf: legal.privacyPdfUrl?.isNotEmpty == true,
                    isSaving: _controller.isSaving,
                    uploadedLabel: l10n.ownerPdfUploaded,
                    missingLabel: l10n.ownerPdfMissing,
                    uploadLabel: legal.privacyPdfUrl?.isNotEmpty == true
                        ? l10n.ownerReplacePdf
                        : l10n.ownerUploadPdf,
                    openLabel: l10n.ownerOpenPdf,
                    onUpload: () => _upload(LegalDocumentType.privacy),
                    onOpen: () => _openPdf(legal.privacyPdfUrl),
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

class _LegalCard extends StatelessWidget {
  const _LegalCard({
    required this.title,
    required this.hasPdf,
    required this.isSaving,
    required this.uploadedLabel,
    required this.missingLabel,
    required this.uploadLabel,
    required this.openLabel,
    required this.onUpload,
    required this.onOpen,
  });

  final String title;
  final bool hasPdf;
  final bool isSaving;
  final String uploadedLabel;
  final String missingLabel;
  final String uploadLabel;
  final String openLabel;
  final VoidCallback onUpload;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.picture_as_pdf_outlined,
                color: AppColors.burgundy,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(title, style: AppTextStyles.body)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasPdf ? uploadedLabel : missingLabel,
            style: AppTextStyles.bodySmall.copyWith(
              color: hasPdf ? AppColors.success : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSaving ? null : onUpload,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.burgundy,
                    side: const BorderSide(color: AppColors.burgundy),
                  ),
                  child: Text(uploadLabel),
                ),
              ),
              if (hasPdf) ...[
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextButton(
                    onPressed: onOpen,
                    child: Text(
                      openLabel,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.burgundy,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
