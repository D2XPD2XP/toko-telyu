class ProductVariant {
  String _variantId;
  String _optionName;
  int _stock;
  double _additionalPrice;

  ProductVariant(
    this._variantId,
    this._optionName,
    this._stock,
    this._additionalPrice,
  );

  factory ProductVariant.fromFirestore(
      Map<String, dynamic> data, String variantId) {
    return ProductVariant(
      variantId,
      data['optionName'],
      data['stock'],
      (data['additionalPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'optionName': _optionName,
      'stock': _stock,
      'additionalPrice': _additionalPrice,
    };
  }

  // Getters
  String get variantId => _variantId;
  String get optionName => _optionName;
  int get stock => _stock;
  double get additionalPrice => _additionalPrice;

  // Setters
  void setVariantId(String id) => _variantId = id;
  void setOptionName(String name) => _optionName = name;
  void setStock(int value) => _stock = value;
  void setAdditionalPrice(double value) => _additionalPrice = value;
}




