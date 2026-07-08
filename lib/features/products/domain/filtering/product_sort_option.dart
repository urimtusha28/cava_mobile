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
  String get labelSq => switch (this) {
        ProductSortOption.recommended => 'Të rekomanduara',
        ProductSortOption.nameAsc => 'Emri A–Z',
        ProductSortOption.nameDesc => 'Emri Z–A',
        ProductSortOption.priceAsc => 'Çmimi: nga i ulët',
        ProductSortOption.priceDesc => 'Çmimi: nga i lartë',
        ProductSortOption.newest => 'Më të rejat',
        ProductSortOption.bestSellers => 'Më të shiturat',
      };
}
