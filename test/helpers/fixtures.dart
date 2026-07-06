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

/// Sample web Firebase `products` document (sales schema only).
Map<String, dynamic> get testWebProductJson => {
      'id': 'web-p1',
      'name': 'Stone Castle Merlot',
      'description': 'Merlot i butë dhe elegant.',
      'price': 18.90,
      'originalPrice': 21.00,
      'stock': 12,
      'status': 'published',
      'productStatus': 'active',
      'category': 'Wines',
      'subCategory': 'Merlot',
      'imageUrl': 'https://cdn.example.com/p1.jpg',
      'images': {
        'thumb': 'https://cdn.example.com/p1-thumb.jpg',
        'medium': 'https://cdn.example.com/p1-medium.jpg',
        'original': 'https://cdn.example.com/p1-original.jpg',
      },
      'brandProducer': 'Stone Castle',
      'origin': 'North Macedonia',
      'originCode': 'MK',
      'details': {
        'abv': 13.5,
        'volume': '750ml',
        'region': 'Tikves',
        'vintageYear': 2022,
      },
      'topPick': true,
    };

Map<String, dynamic> get testWebDraftProductJson => {
      ...testWebProductJson,
      'id': 'web-draft',
      'name': 'Draft Wine',
      'productStatus': 'draft',
      'topPick': false,
    };

Map<String, dynamic> get testWebHiddenProductJson => {
      ...testWebProductJson,
      'id': 'web-hidden',
      'name': 'Hidden Wine',
      'productStatus': 'hidden',
      'topPick': false,
    };

Map<String, dynamic> get testCategoryJson => testCategoryModel.toJson();

Map<String, dynamic> get testHomeSectionJson => testHomeSectionModel.toJson();
