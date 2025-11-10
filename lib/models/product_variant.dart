import 'package:toko_telyu/models/product.dart';

class ProductVariant {
  String? _productVariantId;
  String? _optionName;
  int? _stock;
  double? _additionalPrice;
  Product? _product;

  ProductVariant(
    this._productVariantId,
    this._optionName,
    this._stock,
    this._additionalPrice,
    this._product,
  );

  // Getters
  String? getProductVariantId() => _productVariantId;
  String? getOptionName() => _optionName;
  int? getStock() => _stock;
  double? getAdditionalPrice() => _additionalPrice;
  Product? getProduct() => _product;

  // Setters
  void setProductVariantId(String? productVariantId) {
    _productVariantId = productVariantId;
  }

  void setOptionName(String? optionName) {
    _optionName = optionName;
  }

  void setStock(int? stock) {
    _stock = stock;
  }

  void setAdditionalPrice(double? additionalPrice) {
    _additionalPrice = additionalPrice;
  }

  void setProduct(Product? product) {
    _product = product;
  }
}
