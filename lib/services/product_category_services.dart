import 'dart:io';

import 'package:toko_telyu/repositories/product_category_repositories.dart';
import 'package:toko_telyu/services/cloudinary_service.dart';
import 'package:uuid/uuid.dart';
import '../models/product_category.dart';

class ProductCategoryService {
  final ProductCategoryRepository _repo = ProductCategoryRepository();

  Future<ProductCategory> createCategory(
    String name,
    bool isFittable,
    String imageUrl,
  ) async {
    final id = const Uuid().v4();
    final category = ProductCategory(id, name, isFittable, imageUrl);
    await _repo.createCategory(category);
    return category;
  }

  Future<ProductCategory> createCategoryWithImage(
    String name,
    bool isFittable,
    File imageFile,
  ) async {
    final imageUrl = await CloudinaryService.uploadImage(imageFile);
    return await createCategory(name, isFittable, imageUrl);
  }

  Future<void> updateCategory(
    String categoryId,
    Map<String, dynamic> updates,
  ) async {
    await _repo.updateCategory(categoryId, updates);
  }

  Future<void> updateCategoryWithImage(
    String categoryId,
    Map<String, dynamic> updates,
    File imageFile,
  ) async {
    final imageUrl = await CloudinaryService.uploadImage(imageFile);
    updates['icon_url'] = imageUrl;
    await _repo.updateCategory(categoryId, updates);
  }

  Future<ProductCategory> getCategory(String categoryId) async {
    return await _repo.getCategory(categoryId);
  }

  Future<List<ProductCategory>> getCategories() async {
    return await _repo.getAllCategories();
  }

  Future<void> deleteCategory(String categoryId) async {
    await _repo.deleteCategory(categoryId);
  }

  Future<bool> isCategoryUsed(String categoryId) async {
    return await _repo.isCategoryUsed(categoryId);
  }
}
