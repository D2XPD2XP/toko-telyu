import 'package:uuid/uuid.dart';

class ProductCategory {
  String _categoryId;
  String _categoryName;
  bool _isFittable;

  ProductCategory({
    String? categoryId,
    required String categoryName,
    required bool isFittable,
  })  : _categoryId = categoryId ?? const Uuid().v4(),
        _categoryName = categoryName,
        _isFittable = isFittable;

  factory ProductCategory.fromMap(Map<String, dynamic> map, String id) {
    return ProductCategory(
      categoryId: id,
      categoryName: map['categoryName'] ?? '',
      isFittable: map['isFittable'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': _categoryId,
      'categoryName': _categoryName,
      'isFittable': _isFittable,
    };
  }

  String get categoryId => _categoryId;
  String get categoryName => _categoryName;
  bool get isFittable => _isFittable;

  set categoryId(String value) => _categoryId = value;
  set categoryName(String value) => _categoryName = value;
  set isFittable(bool value) => _isFittable = value;
}


