import 'package:cava_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:cava_ecommerce/features/cart/domain/entities/cart_summary_entity.dart';
import 'package:cava_ecommerce/features/categories/data/models/category_model.dart';
import 'package:cava_ecommerce/features/categories/domain/entities/category_entity.dart';
import 'package:cava_ecommerce/features/categories/domain/entities/subcategory_entity.dart';
import 'package:cava_ecommerce/features/home/data/models/home_section_model.dart';
import 'package:cava_ecommerce/features/home/domain/entities/home_section_entity.dart';
import 'package:cava_ecommerce/features/products/data/models/product_model.dart';
import 'package:cava_ecommerce/features/products/domain/entities/product_entity.dart';

const testProductEntity = ProductEntity(
  id: 'p1',
  name: 'Test Wine',
  brand: 'Test Brand',
  categoryId: 'wines',
  categoryName: 'Wines',
  price: 25.0,
  oldPrice: 30.0,
  description: 'A test wine',
  volume: '750ml',
  alcoholPercentage: 13.5,
  country: 'Albania',
  type: 'Red',
  rating: 4.5,
  reviewCount: 100,
  inStock: true,
  isFeatured: true,
  variants: ['750ml'],
);

const testProductModel = ProductModel(
  id: 'p1',
  name: 'Test Wine',
  brand: 'Test Brand',
  categoryId: 'wines',
  categoryName: 'Wines',
  price: 25.0,
  oldPrice: 30.0,
  description: 'A test wine',
  volume: '750ml',
  alcoholPercentage: 13.5,
  country: 'Albania',
  type: 'Red',
  rating: 4.5,
  reviewCount: 100,
  inStock: true,
  isFeatured: true,
  variants: ['750ml'],
);

const testCategoryEntity = CategoryEntity(
  id: 'wines',
  name: 'Wines',
  label: 'Verërat',
  emoji: '🍷',
);

const testCategoryModel = CategoryModel(
  id: 'wines',
  name: 'Wines',
  label: 'Verërat',
  emoji: '🍷',
);

const testSubcategoryEntity = SubcategoryEntity(
  id: 'red',
  label: 'Red Wine',
  matchTypes: ['Red'],
);

const testHomeSectionModel = HomeSectionModel(
  id: 'sec1',
  title: 'Të rekomanduara',
  type: HomeSectionTypeModel.recommended,
  seeAllRoute: '/category/wines',
);

const testHomeSectionEntity = HomeSectionEntity(
  id: 'sec1',
  title: 'Të rekomanduara',
  type: HomeSectionType.recommended,
  seeAllRoute: '/category/wines',
  products: [testProductEntity],
);

final testCartItem = CartItemEntity(
  product: testProductEntity,
  quantity: 2,
);

const testCartSummary = CartSummaryEntity(
  items: [],
  itemCount: 0,
  subtotal: 0,
  discount: 0,
  vat: 0,
  shipping: 0,
  total: 0,
);

Map<String, dynamic> get testProductJson => testProductModel.toJson();

Map<String, dynamic> get testCategoryJson => testCategoryModel.toJson();

Map<String, dynamic> get testHomeSectionJson => testHomeSectionModel.toJson();
