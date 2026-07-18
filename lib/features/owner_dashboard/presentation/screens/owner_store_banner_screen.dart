import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../controllers/owner_settings_controller.dart';

class OwnerStoreBannerScreen extends StatefulWidget {
  const OwnerStoreBannerScreen({super.key});

  @override
  State<OwnerStoreBannerScreen> createState() => _OwnerStoreBannerScreenState();
}

class _OwnerStoreBannerScreenState extends State<OwnerStoreBannerScreen> {
  late final OwnerSettingsController _controller;
  late final Future<void> _loadFuture;
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _mapsCtrl = TextEditingController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = createOwnerSettingsController();
    _loadFuture = _controller.loadHomepage().then((_) {
      final h = _controller.homepage;
      _emailCtrl.text = h.contactEmail ?? '';
      _phoneCtrl.text = h.contactPhone ?? '';
      _addressCtrl.text = h.storeAddress ?? '';
      _mapsCtrl.text = h.mapsUrl ?? '';
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _mapsCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    final l10n = AppLocalizations.of(context);
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final name = file.name.toLowerCase();
    final ext = name.contains('.') ? name.split('.').last : 'jpg';
    final contentType = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    final ok = await _controller.uploadBanner(
      bytes: bytes,
      contentType: contentType,
      fileExtension: ext,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? l10n.ownerUploadSuccess : (_controller.sectionError ?? l10n.ownerUploadFailed)),
        backgroundColor: AppColors.burgundy,
      ),
    );
  }

  Future<void> _saveContact() async {
    final l10n = AppLocalizations.of(context);
    final ok = await _controller.saveStoreContact(
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
      storeAddress: _addressCtrl.text,
      mapsUrl: _mapsCtrl.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? l10n.ownerUploadSuccess : (_controller.sectionError ?? l10n.ownerUploadFailed)),
        backgroundColor: AppColors.burgundy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(title: l10n.ownerStoreBannerTitle, showBack: true),
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

              final url = _controller.homepage.storeBannerImageUrl;

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.screen),
                children: [
                  Text(
                    l10n.ownerStoreBannerHint,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: url != null && url.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                color: AppColors.surfaceMuted,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.burgundy,
                                  ),
                                ),
                              ),
                              errorWidget: (_, _, _) => Image.asset(
                                AppAssets.storeLocation,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              AppAssets.storeLocation,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _controller.isSaving ? null : _pickAndUpload,
                      icon: _controller.isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.burgundy,
                              ),
                            )
                          : const Icon(Icons.photo_library_outlined),
                      label: Text(
                        url == null || url.isEmpty
                            ? l10n.ownerUploadPhoto
                            : l10n.ownerChangePhoto,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.burgundy,
                        side: const BorderSide(color: AppColors.burgundy),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    l10n.ownerSettingsStoreContact,
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _addressCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.ownerStoreAddressLabel,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _mapsCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.ownerMapsUrlLabel,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.ownerContactEmailLabel,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _phoneCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.ownerContactPhoneLabel,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _controller.isSaving ? null : _saveContact,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.burgundy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: Text(l10n.ownerSaveContact),
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
