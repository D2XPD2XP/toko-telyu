class ProductCategory {
  String _categoryId;
  String _categoryName;
  bool _isFittable;

  ProductCategory(
    this._categoryId,
    this._categoryName,
    this._isFittable,
  );

  factory ProductCategory.fromFirestore(
      Map<String, dynamic> data, String categoryId) {
    return ProductCategory(
      categoryId,
      data['category_name'],
      data['is_fittable'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category_name': _categoryName,
      'is_fittable': _isFittable,
    };
  }

  // Getters
  String get categoryId => _categoryId;
  String get categoryName => _categoryName;
  bool get isFittable => _isFittable;

  // Setters
  void setCategoryId(String id) => _categoryId = id;
  void setCategoryName(String name) => _categoryName = name;
  void setIsFittable(bool value) => _isFittable = value;
}



