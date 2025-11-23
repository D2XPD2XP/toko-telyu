import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_category.dart';

class ProductCategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _categoryCollection =>
      _firestore.collection('product_category');

  Future<void> createCategory(ProductCategory category) async {
    await _categoryCollection
        .doc(category.categoryId)
        .set(category.toFirestore());
  }

  Future<ProductCategory> getCategory(String categoryId) async {
    final doc = await _categoryCollection.doc(categoryId).get();
    return ProductCategory.fromFirestore(doc.data()!, doc.id);
  }

  Future<List<ProductCategory>> getAllCategories() async {
    final snapshot = await _categoryCollection.get();

    print("Docs found: ${snapshot.docs.length}");
    for (var d in snapshot.docs) {
      print("docId = ${d.id}, data = ${d.data()}");
    }

    return snapshot.docs
        .map((d) => ProductCategory.fromFirestore(d.data(), d.id))
        .toList();
  }

  Future<void> updateCategory(
    String categoryId,
    Map<String, dynamic> updates,
  ) async {
    await _categoryCollection.doc(categoryId).update(updates);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoryCollection.doc(categoryId).delete();
  }
}
