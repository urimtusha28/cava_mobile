import 'package:cava_ecommerce/features/account/data/datasources/auth_data_source.dart';
import 'package:cava_ecommerce/features/account/domain/repositories/addresses_repository.dart';
import 'package:cava_ecommerce/features/account/domain/repositories/auth_repository.dart';
import 'package:cava_ecommerce/features/account/domain/repositories/orders_repository.dart';
import 'package:cava_ecommerce/features/cart/data/datasources/cart_data_source.dart';
import 'package:cava_ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:cava_ecommerce/features/categories/data/datasources/category_data_source.dart';
import 'package:cava_ecommerce/features/categories/domain/repositories/category_repository.dart';
import 'package:cava_ecommerce/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:cava_ecommerce/features/home/data/datasources/home_data_source.dart';
import 'package:cava_ecommerce/features/home/domain/repositories/home_repository.dart';
import 'package:cava_ecommerce/features/products/data/datasources/product_data_source.dart';
import 'package:cava_ecommerce/features/products/domain/repositories/product_repository.dart';
import 'package:cava_ecommerce/features/wishlist/data/datasources/wishlist_data_source.dart';
import 'package:cava_ecommerce/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockProductDataSource extends Mock implements ProductDataSource {}

class MockCategoryDataSource extends Mock implements CategoryDataSource {}

class MockHomeDataSource extends Mock implements HomeDataSource {}

class MockCartDataSource extends Mock implements CartDataSource {}

class MockWishlistDataSource extends Mock implements WishlistDataSource {}

class MockAuthDataSource extends Mock implements AuthDataSource {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockHomeRepository extends Mock implements HomeRepository {}

class MockCartRepository extends Mock implements CartRepository {}

class MockWishlistRepository extends Mock implements WishlistRepository {}

class MockAddressesRepository extends Mock implements AddressesRepository {}

class MockCheckoutRepository extends Mock implements CheckoutRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockOrdersRepository extends Mock implements OrdersRepository {}
