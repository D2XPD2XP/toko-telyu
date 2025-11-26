import 'package:toko_telyu/repositories/product_category_repositories.dart';
import 'package:uuid/uuid.dart';
import '../models/product_category.dart';

class ProductCategoryService {
  final ProductCategoryRepository _repo = ProductCategoryRepository();

  Future<ProductCategory> createCategory(String name, bool isFittable, String iconUrl) async {
    final id = const Uuid().v4();

    final category = ProductCategory(
      id,
      name,
      isFittable,
      iconUrl,
    );

    await _repo.createCategory(category);
    return category;
  }

  Future<ProductCategory> getCategory(String categoryId) async {
    return await _repo.getCategory(categoryId);
  }

  Future<List<ProductCategory>> getCategories() async {
    return await _repo.getAllCategories();
  }

  Future<void> updateCategory(String categoryId, Map<String, dynamic> updates) async {
    await _repo.updateCategory(categoryId, updates);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _repo.deleteCategory(categoryId);
  }
}

