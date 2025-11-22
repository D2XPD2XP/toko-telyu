import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/product_image.dart';
import '../models/product_variant.dart';
import '../models/product_category.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Main product collection
  CollectionReference<Map<String, dynamic>> get _productCollection =>
      _firestore.collection('product');

  // Category collection
  CollectionReference<Map<String, dynamic>> get _categoryCollection =>
      _firestore.collection('product_categories');

  // Subcollections
  CollectionReference<Map<String, dynamic>> _imageCollection(String productId) =>
      _productCollection.doc(productId).collection('productImages');

  CollectionReference<Map<String, dynamic>> _variantCollection(String productId) =>
      _productCollection.doc(productId).collection('productVariants');

  // --------------------------
  // CATEGORY
  // --------------------------

  Future<ProductCategory> getCategory(String categoryId) async {
    final doc = await _categoryCollection.doc(categoryId).get();
    return ProductCategory.fromFirestore(doc.data()!, doc.id);
  }

  Future<List<ProductCategory>> getAllCategories() async {
    final snapshot = await _categoryCollection.get();
    return snapshot.docs
        .map((doc) => ProductCategory.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // --------------------------
  // PRODUCT
  // --------------------------

  Future<void> createProduct(Product product) async {
    await _productCollection.doc(product.productId).set(product.toFirestore());
  }

  Future<Product> getProduct(String productId) async {
    final doc = await _productCollection.doc(productId).get();

    final category =
        await getCategory(doc.data()!['categoryId']); 

    final product = Product.fromFirestore(doc.data()!, doc.id, category);

    return product;
  }

  Future<List<Product>> getAllProducts() async {
    final snapshot = await _productCollection.get();

    List<Product> products = [];

    for (var doc in snapshot.docs) {
      final category =
          await getCategory(doc.data()['categoryId']);

      products.add(Product.fromFirestore(doc.data(), doc.id, category));
    }

    return products;
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    await _productCollection.doc(productId).update(updates);
  }

  Future<void> deleteProduct(String productId) async {
    final images = await _imageCollection(productId).get();
    for (final img in images.docs) {
      await img.reference.delete();
    }

    final variants = await _variantCollection(productId).get();
    for (final varDoc in variants.docs) {
      await varDoc.reference.delete();
    }

    await _productCollection.doc(productId).delete();
  }

  // --------------------------
  // PRODUCT IMAGES
  // --------------------------

  Future<void> addImage(String productId, ProductImage image) async {
    await _imageCollection(productId)
        .doc(image.imageId)
        .set(image.toFirestore());
  }

  Future<List<ProductImage>> getImages(String productId) async {
    final snapshot = await _imageCollection(productId).get();
    return snapshot.docs
        .map((d) => ProductImage.fromFirestore(d.data(), d.id))
        .toList();
  }

  Future<void> deleteImage(String productId, String imageId) async {
    await _imageCollection(productId).doc(imageId).delete();
  }

  // --------------------------
  // PRODUCT VARIANTS
  // --------------------------

  Future<void> addVariant(String productId, ProductVariant variant) async {
    await _variantCollection(productId)
        .doc(variant.variantId)
        .set(variant.toFirestore());
  }

  Future<List<ProductVariant>> getVariants(String productId) async {
    final snapshot = await _variantCollection(productId).get();
    return snapshot.docs
        .map((d) => ProductVariant.fromFirestore(d.data(), d.id))
        .toList();
  }

  Future<void> updateVariant(
      String productId, String variantId, Map<String, dynamic> updates) async {
    await _variantCollection(productId).doc(variantId).update(updates);
  }

  Future<void> deleteVariant(String productId, String variantId) async {
    await _variantCollection(productId).doc(variantId).delete();
  }
}

