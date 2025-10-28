class ProductCategory {
  String _categoryId;
  String _categoryName;
  bool _isFittable;

  ProductCategory(this._categoryId, this._categoryName, this._isFittable);

  // Getters
  String getCategoryId() => _categoryId;
  String getCategoryName() => _categoryName;
  bool isFittable() => _isFittable;

  // Setters
  void setCategoryId(String categoryId) {
    _categoryId = categoryId;
  }

  void setCategoryName(String categoryName) {
    _categoryName = categoryName;
  }

  void setFittable(bool isFittable) {
    _isFittable = isFittable;
  }
}
