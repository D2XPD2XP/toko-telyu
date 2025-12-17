import 'dart:io';

import 'package:flutter/material.dart';
import 'package:toko_telyu/repositories/product_repositories.dart';
import 'package:toko_telyu/services/cloudinary_service.dart';
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

  Future<String?> getFirstImageUrl(String productId) async {
    final images = await _repo.getImages(productId);
    if (images.isEmpty) return null;
    return images.first.imageUrl;
  }

  Future<ProductImage> addImage(String productId, String imageUrl) async {
    final image = ProductImage(const Uuid().v4(), imageUrl);
    await _repo.addImage(productId, image);
    return image;
  }

  Future<void> addImageFile(String productId, File file) async {
    final imageUrl = await CloudinaryService.uploadImage(file);
    final image = ProductImage(const Uuid().v4(), imageUrl);
    await _repo.addImage(productId, image);
  }

  Future<List<ProductImage>> getImages(String productId) async {
    return await _repo.getImages(productId);
  }

  Future<void> deleteImage(String productId, String imageId) async {
    final images = await _repo.getImages(productId);
    final img = images.firstWhere((e) => e.imageId == imageId);

    try {
      await CloudinaryService.deleteImage(img.imageUrl);
    } catch (e) {
      debugPrint("Cloudinary delete failed: $e");
    }
    await _repo.deleteImage(productId, imageId);
  }

  Future<void> syncImages(
    String productId,
    List<ProductImage> newImages,
  ) async {
    final oldImages = await getImages(productId);

    final toAdd = newImages.where(
      (img) => !oldImages.any((old) => old.imageId == img.imageId),
    );
    for (var img in toAdd) {
      await addImage(productId, img.imageUrl);
    }

    final toDelete = oldImages.where(
      (old) => !newImages.any((img) => img.imageId == old.imageId),
    );
    for (var img in toDelete) {
      await deleteImage(productId, img.imageId);
    }
  }

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
  // VARIANTS
  // --------------------------

  Future<ProductVariant?> getVariantById(
    String productId,
    String variantId,
  ) async {
    final variants = await _repo.getVariants(productId);
    try {
      return variants.firstWhere((v) => v.variantId == variantId);
    } catch (_) {
      return null;
    }
  }

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

  Future<void> syncVariants(
    String productId,
    List<ProductVariant> newVariants,
  ) async {
    final oldVariants = await getVariants(productId);

    final toAdd = newVariants.where(
      (v) => !oldVariants.any((old) => old.variantId == v.variantId),
    );
    for (var v in toAdd) {
      await addVariant(productId, v.optionName, v.stock, v.additionalPrice);
    }

    final toDelete = oldVariants.where(
      (old) => !newVariants.any((v) => v.variantId == old.variantId),
    );
    for (var v in toDelete) {
      await deleteVariant(productId, v.variantId);
    }
  }

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
}
