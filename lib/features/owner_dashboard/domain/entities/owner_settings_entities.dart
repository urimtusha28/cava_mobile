class OwnerListedUser {
  const OwnerListedUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final String role;
  final DateTime? createdAt;
}

class HomepageSettings {
  const HomepageSettings({
    this.storeBannerImageUrl,
    this.storeAddress,
    this.mapsUrl,
    this.contactEmail,
    this.contactPhone,
  });

  final String? storeBannerImageUrl;
  final String? storeAddress;
  final String? mapsUrl;
  final String? contactEmail;
  final String? contactPhone;

  static const empty = HomepageSettings();

  HomepageSettings copyWith({
    String? storeBannerImageUrl,
    String? storeAddress,
    String? mapsUrl,
    String? contactEmail,
    String? contactPhone,
    bool clearBannerUrl = false,
  }) {
    return HomepageSettings(
      storeBannerImageUrl: clearBannerUrl
          ? null
          : (storeBannerImageUrl ?? this.storeBannerImageUrl),
      storeAddress: storeAddress ?? this.storeAddress,
      mapsUrl: mapsUrl ?? this.mapsUrl,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }
}

enum LegalDocumentType { terms, privacy }

class LegalSettings {
  const LegalSettings({
    this.termsPdfUrl,
    this.privacyPdfUrl,
    this.updatedAt,
  });

  final String? termsPdfUrl;
  final String? privacyPdfUrl;
  final DateTime? updatedAt;

  static const empty = LegalSettings();

  String? urlFor(LegalDocumentType type) => switch (type) {
        LegalDocumentType.terms => termsPdfUrl,
        LegalDocumentType.privacy => privacyPdfUrl,
      };
}
