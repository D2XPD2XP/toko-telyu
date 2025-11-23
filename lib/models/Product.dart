import 'package:toko_telyu/models/product_category.dart';

class Product {
  String _productId;
  String _productName;
  double _price;
  int _stock;
  String _description;
  ProductCategory _category;

  Product(
    this._productId,
    this._productName,
    this._price,
    this._stock,
    this._description,
    this._category,
  );

  factory Product.fromFirestore(
      Map<String, dynamic> data,
      String productId,
      ProductCategory category,
      ) {
    return Product(
      productId,
      data['product_name'],
      (data['price'] as num).toDouble(),
      data['stock'],
      data['description'],
      category,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'product_name': _productName,
      'price': _price,
      'stock': _stock,
      'description': _description,
      'category_id': _category.categoryId,
    };
  }

  // Getters
  String get productId => _productId;
  String get productName => _productName;
  double get price => _price;
  int get stock => _stock;
  String get description => _description;
  ProductCategory get category => _category;

  // Setters
  void setProductId(String id) => _productId = id;
  void setProductName(String name) => _productName = name;
  void setPrice(double price) => _price = price;
  void setStock(int stock) => _stock = stock;
  void setDescription(String desc) => _description = desc;
  void setCategory(ProductCategory cat) => _category = cat;
}




