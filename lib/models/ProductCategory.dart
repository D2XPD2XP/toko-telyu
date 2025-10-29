import 'Product.dart';

class ProductCategory {
  String? categoryId;
  String? categoryName;
  bool? isFitssole;
  List<Product>? products;

  ProductCategory();

  String? getCategoryId() => categoryId;
  String? getCategoryName() => categoryName;
  bool? getIsFitssole() => isFitssole;
  List<Product>? getProducts() => products;

  void setCategoryId(String? categoryId) {
    this.categoryId = categoryId;
  }

  void setCategoryName(String? categoryName) {
    this.categoryName = categoryName;
  }

  void setIsFitssole(bool? isFitssole) {
    this.isFitssole = isFitssole;
  }

  void setProducts(List<Product>? products) {
    this.products = products;
  }
}
