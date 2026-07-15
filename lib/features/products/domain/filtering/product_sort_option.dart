import 'package:cava_ecommerce/l10n/app_localizations.dart';

enum ProductSortOption {
  recommended,
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  newest,
  bestSellers,
}

extension ProductSortOptionLabel on ProductSortOption {
  String labelOf(AppLocalizations l10n) => switch (this) {
        ProductSortOption.recommended => l10n.sortRecommended,
        ProductSortOption.nameAsc => l10n.sortNameAsc,
        ProductSortOption.nameDesc => l10n.sortNameDesc,
        ProductSortOption.priceAsc => l10n.sortPriceAsc,
        ProductSortOption.priceDesc => l10n.sortPriceDesc,
        ProductSortOption.newest => l10n.sortNewest,
        ProductSortOption.bestSellers => l10n.sortBestSellers,
      };
}
