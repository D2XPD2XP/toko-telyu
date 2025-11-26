class ProductCategory {
  String _categoryId;
  String _categoryName;
  bool _isFittable;
  String _iconUrl;

  ProductCategory(
    this._categoryId,
    this._categoryName,
    this._isFittable,
    this._iconUrl,
  );

  factory ProductCategory.fromFirestore(
      Map<String, dynamic> data, String categoryId) {
    return ProductCategory(
      categoryId,
      data['category_name'],
      data['is_fittable'],
      data['icon_url'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category_name': _categoryName,
      'is_fittable': _isFittable,
      'icon_url' : _iconUrl,
    };
  }

  // Getters
  String get categoryId => _categoryId;
  String get categoryName => _categoryName;
  bool get isFittable => _isFittable;
  String get iconUrl => _iconUrl;

  // Setters
  void setCategoryId(String id) => _categoryId = id;
  void setCategoryName(String name) => _categoryName = name;
  void setIsFittable(bool value) => _isFittable = value;
  void setIconUrl(String iconUrl) => _iconUrl = iconUrl;
}



