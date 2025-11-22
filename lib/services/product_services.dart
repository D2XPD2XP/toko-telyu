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
      int stock,
      String description,
      ProductCategory category) async {

    final id = const Uuid().v4();

    final product = Product(
      id,
      name,
      price,
      stock,
      description,
      category,
    );

    await _repo.createProduct(product);
    return product;
  }

  Future<Product> getProduct(String productId) async {
    return await _repo.getProduct(productId);
  }

  Future<List<Product>> getProducts() async {
    return await _repo.getAllProducts();
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
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
      double additionalPrice) async {

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
      String productId, String variantId, Map<String, dynamic> updates) async {
    await _repo.updateVariant(productId, variantId, updates);
  }

  Future<void> deleteVariant(String productId, String variantId) async {
    await _repo.deleteVariant(productId, variantId);
  }
}

