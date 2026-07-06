import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_config.dart';
import '../models/product_model.dart';
import 'product_data_source.dart';

/// Firestore implementation for [ProductDataSource].
///
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
    return _mapDocuments(snapshot.docs);
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    final snapshot = await _collection.doc(id).get();
    if (!snapshot.exists) {
      return null;
    }
    return mapDocumentToModel(snapshot.data()!, snapshot.id);
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    final snapshot =
        await _collection.where('isFeatured', isEqualTo: true).get();
    return _mapDocuments(snapshot.docs);
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    final snapshot =
        await _collection.where('categoryId', isEqualTo: categoryId).get();
    return _mapDocuments(snapshot.docs);
  }

  List<ProductModel> _mapDocuments(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
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
