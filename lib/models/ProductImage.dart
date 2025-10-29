import 'Product.dart';

class ProductImage {
  String? _imageUrl;
  Product? _product;

  ProductImage(this._imageUrl, this._product);

  // Getters
  String? getImageUrl() => _imageUrl;
  Product? getProduct() => _product;

  // Setters
  void setImageUrl(String? imageUrl) {
    _imageUrl = imageUrl;
  }

  void setProduct(Product? product) {
    _product = product;
  }
}
