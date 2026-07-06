import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_config.dart';
import '../models/product_model.dart';
import 'product_data_source.dart';

/// Firestore implementation for [ProductDataSource].
///
/// Reads web Firebase `products` sales schema only — no CMS/homepage fields.
/// Wired in DI only when [FirebaseConfig.enabled] and
/// [FirebaseConfig.useFirestoreProducts] are both `true`.
class ProductFirestoreDataSource implements ProductDataSource {
  ProductFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirebaseConfig.productsCollection);

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final snapshot = await _collection.get();
    return _mapActiveDocuments(snapshot.docs);
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    final snapshot = await _collection.doc(id).get();
    if (!snapshot.exists) {
      return null;
    }
    final data = snapshot.data()!;
    if (!ProductModel.isActiveProductStatus(
      data['productStatus'] as String?,
    )) {
      return null;
    }
    return mapDocumentToModel(data, snapshot.id);
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    final snapshot =
        await _collection.where('topPick', isEqualTo: true).get();
    return _mapActiveDocuments(snapshot.docs);
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final snapshot = await _collection.get();
    final normalized = category.toLowerCase();
    return _mapActiveDocuments(
      snapshot.docs.where((doc) {
        final docCategory = doc.data()['category'] as String?;
        if (docCategory == null) {
          return false;
        }
        return docCategory == category ||
            ProductModel.categorySlug(docCategory) == normalized;
      }).toList(growable: false),
    );
  }

  List<ProductModel> _mapActiveDocuments(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .where(
          (doc) => ProductModel.isActiveProductStatus(
            doc.data()['productStatus'] as String?,
          ),
        )
        .map((doc) => mapDocumentToModel(doc.data(), doc.id))
        .toList(growable: false);
  }

  /// Maps Firestore document data to [ProductModel].
  ///
  /// Uses document id when `id` is absent from stored fields.
  static ProductModel mapDocumentToModel(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final json = Map<String, dynamic>.from(data);
    json.putIfAbsent('id', () => documentId);
    return ProductModel.fromJson(json);
  }
}
