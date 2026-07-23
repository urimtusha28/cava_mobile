import 'dart:async';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/filtering/product_filter_engine.dart';
import '../../../products/domain/filtering/product_filter_state.dart';
import '../../../products/domain/usecases/get_all_products.dart';
import '../../data/local/recent_search_storage.dart';

class SearchController extends BaseController {
  SearchController(this._getAllProducts, this._recentStorage);

  final GetAllProductsUseCase _getAllProducts;
  final RecentSearchStorage _recentStorage;

  static const Duration debounceDuration = Duration(milliseconds: 300);

  final List<ProductEntity> _allProducts = [];
  final List<ProductEntity> _rawResults = [];
  final List<ProductEntity> results = [];
  String query = '';
  bool hasLoadedProducts = false;
  bool isSearching = false;
  List<String> recentSearches = const [];
  ProductFilterState filter = ProductFilterState.empty;

  Timer? _debounceTimer;
  Future<void>? _loadProductsFuture;

  /// Unfiltered search matches — used to build filter facet options.
  List<ProductEntity> get rawSearchResults =>
      List<ProductEntity>.unmodifiable(_rawResults);

  /// Facet source for the filter sheet: current search hits, or the full
  /// catalog when the query is empty / too short.
  List<ProductEntity> get productsForFilterOptions {
    if (_rawResults.isNotEmpty) {
      return List<ProductEntity>.unmodifiable(_rawResults);
    }
    return List<ProductEntity>.unmodifiable(_allProducts);
  }

  Future<void> loadInitial() async {
    await _loadRecentSearches();
  }

  /// Loads the catalog if needed so the filter sheet can open even before
  /// the user has typed a search query.
  Future<void> ensureProductsLoaded() => _ensureProductsLoaded();

  Future<void> _ensureProductsLoaded() async {
    if (hasLoadedProducts) {
      return;
    }
    _loadProductsFuture ??= _fetchProducts();
    await _loadProductsFuture;
  }

  Future<void> _fetchProducts() async {
    isSearching = true;
    notifyListeners();

    final products = await unwrapFutureResult(
      _getAllProducts(),
      fallback: const <ProductEntity>[],
    );

    _allProducts
      ..clear()
      ..addAll(products.where((p) => p.inStock));
    hasLoadedProducts = true;
    isSearching = false;
    notifyListeners();
    _applySearch();
  }

  void updateQuery(String value) {
    query = value.trim();
    _debounceTimer?.cancel();

    if (query.length < 2) {
      _rawResults.clear();
      results.clear();
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(debounceDuration, () async {
      await _ensureProductsLoaded();
      _applySearch();
    });
  }

  void applyFilter(ProductFilterState next) {
    filter = next;
    _applyFiltersToResults();
  }

  void clearFilter() {
    filter = ProductFilterState.empty;
    _applyFiltersToResults();
  }

  void _applySearch() {
    if (query.length < 2) {
      _rawResults.clear();
      results.clear();
      notifyListeners();
      return;
    }

    final lower = query.toLowerCase();
    final scored = <(ProductEntity, int)>[];

    for (final product in _allProducts) {
      final score = _scoreProduct(product, lower);
      if (score > 0) {
        scored.add((product, score));
      }
    }

    scored.sort((a, b) => b.$2.compareTo(a.$2));
    _rawResults
      ..clear()
      ..addAll(scored.map((tuple) => tuple.$1));
    _applyFiltersToResults();
  }

  void _applyFiltersToResults() {
    final filtered = ProductFilterEngine.apply(
      products: _rawResults,
      filter: filter,
    );
    results
      ..clear()
      ..addAll(filtered);
    notifyListeners();
  }

  int _scoreProduct(ProductEntity product, String lowerQuery) {
    int score = 0;

    bool contains(String? value, {int weight = 1}) {
      if (value == null || value.isEmpty) return false;
      if (value.toLowerCase().contains(lowerQuery)) {
        score += weight;
        return true;
      }
      return false;
    }

    // Name has highest weight.
    contains(product.name, weight: 6);
    // Brand / category medium.
    contains(product.brand, weight: 4);
    contains(product.categoryName, weight: 3);
    // Country / origin / type / volume with smaller weight.
    contains(product.country, weight: 2);
    contains(product.type, weight: 2);
    contains(product.volume, weight: 2);
    // Description lowest.
    contains(product.description, weight: 1);

    return score;
  }

  Future<void> submitQuery() async {
    if (query.length < 2) {
      return;
    }
    await _ensureProductsLoaded();
    _applySearch();
    await _saveRecentQuery(query);
  }

  Future<void> _saveRecentQuery(String value) async {
    final sanitized = value.trim();
    if (sanitized.length < 2) {
      return;
    }
    await _recentStorage.addQuery(sanitized);
    await _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    recentSearches = await _recentStorage.readQueries();
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    await _recentStorage.clear();
    recentSearches = const [];
    notifyListeners();
  }

  void selectRecentQuery(String value) {
    query = value;
    _debounceTimer?.cancel();
    _ensureProductsLoaded().then((_) => _applySearch());
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

SearchController createSearchController() {
  configureDependencies();
  return sl<SearchController>();
}

