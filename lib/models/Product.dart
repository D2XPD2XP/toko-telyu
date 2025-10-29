import 'ProductCategory.dart';
import 'ProductVariant.dart';
import 'ProductImage.dart';

class Product {
  String? _productId;
  String? _productName;
  double? _price;
  int? _stock;
  String? _description;
  ProductCategory? _category;
  List<ProductVariant>? _variants;
  List<ProductImage>? _images;

  Product(
    this._productId,
    this._productName,
    this._price,
    this._stock,
    this._description,
    this._category,
    this._variants,
    this._images,
  );

  // Getters
  String? getProductId() => _productId;
  String? getProductName() => _productName;
  double? getPrice() => _price;
  int? getStock() => _stock;
  String? getDescription() => _description;
  ProductCategory? getCategory() => _category;
  List<ProductVariant>? getVariants() => _variants;
  List<ProductImage>? getImages() => _images;

  // Setters
  void setProductId(String? productId) {
    _productId = productId;
  }

  void setProductName(String? productName) {
    _productName = productName;
  }

  void setPrice(double? price) {
    _price = price;
  }

  void setStock(int? stock) {
    _stock = stock;
  }

  void setDescription(String? description) {
    _description = description;
  }

  void setCategory(ProductCategory? category) {
    _category = category;
  }

  void setVariants(List<ProductVariant>? variants) {
    _variants = variants;
  }

  void setImages(List<ProductImage>? images) {
    _images = images;
  }
}
