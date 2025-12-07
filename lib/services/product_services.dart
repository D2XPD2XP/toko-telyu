import 'package:toko_telyu/repositories/product_repositories.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/product_image.dart';
import '../models/product_variant.dart';
import '../models/product_category.dart';

class ProductService {
  final ProductRepository _repo = ProductRepository();

  // --------------------------
  // PRODUCT
  // --------------------------

  Future<Product> createProduct(
    String name,
    double price,
    String description,
    ProductCategory category,
  ) async {
    final id = const Uuid().v4();

    final product = Product(id, name, price, description, category);

    await _repo.createProduct(product);
    return product;
  }

  Future<Product> getProduct(String productId) async {
    return await _repo.getProduct(productId);
  }

  Future<List<Product>> getProductByCategory(ProductCategory category) async {
    return await _repo.getProductByCategory(category);
  }

  Future<List<Product>> getAllProducts(List<ProductCategory> categories) async {
    final categoriesMap = {for (var c in categories) c.categoryId: c};

    return await _repo.getAllProducts(categoriesMap);
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> updates,
  ) async {
    await _repo.updateProduct(productId, updates);
  }

  Future<void> deleteProduct(String productId) async {
    await _repo.deleteProduct(productId);
  }

  // --------------------------
  // IMAGES
  // --------------------------

  Future<void> addImage(String productId, String imageUrl) async {
    final image = ProductImage(const Uuid().v4(), imageUrl);
    await _repo.addImage(productId, image);
  }

  Future<List<ProductImage>> getImages(String productId) async {
    return await _repo.getImages(productId);
  }

  Future<void> deleteImage(String productId, String imageId) async {
    await _repo.deleteImage(productId, imageId);
  }

  // --------------------------
  // VARIANTS
  // --------------------------

  Future<void> addVariant(
    String productId,
    String optionName,
    int stock,
    double additionalPrice,
  ) async {
    final variant = ProductVariant(
      const Uuid().v4(),
      optionName,
      stock,
      additionalPrice,
    );

    await _repo.addVariant(productId, variant);
  }

  Future<List<ProductVariant>> getVariants(String productId) async {
    return await _repo.getVariants(productId);
  }

  Future<void> updateVariant(
    String productId,
    String variantId,
    Map<String, dynamic> updates,
  ) async {
    await _repo.updateVariant(productId, variantId, updates);
  }

  Future<void> deleteVariant(String productId, String variantId) async {
    await _repo.deleteVariant(productId, variantId);
  }

  Future<bool> isAvailable(String productId) async {
    final variants = await getVariants(productId);

    return variants.any((v) => v.stock > 0);
  }

  // --------------------------
  // SEARCH
  // --------------------------

  Future<List<Product>> searchProducts(
    String query,
    List<ProductCategory> categories,
  ) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final all = await getAllProducts(categories);
    return all.where((p) {
      final name = (p.productName).toLowerCase();
      return name.contains(q);
    }).toList();
  }

  // --------------------------
  // REPLACE IMAGES
  // --------------------------
  Future<void> replaceImages(
    String productId,
    List<ProductImage> newImages,
  ) async {
    final oldImages = await getImages(productId);
    for (var img in oldImages) {
      await deleteImage(productId, img.imageId);
    }
    for (var img in newImages) {
      await _repo.addImage(productId, img);
    }
  }

  // --------------------------
  // REPLACE VARIANTS
  // --------------------------
  Future<void> replaceVariants(
    String productId,
    List<ProductVariant> newVariants,
  ) async {
    final oldVariants = await getVariants(productId);
    for (var v in oldVariants) {
      await deleteVariant(productId, v.variantId);
    }
    for (var v in newVariants) {
      await _repo.addVariant(productId, v);
    }
  }
}
