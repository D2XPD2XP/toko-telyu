import 'package:uuid/uuid.dart';
import 'product_category.dart';

class Product {
  String _productId;
  String _productName;
  double _price;
  int _stock;
  String _description;
  ProductCategory _category;

  Product({
    String? productId,
    required String productName,
    required double price,
    required int stock,
    required String description,
    required ProductCategory category,
  })  : _productId = productId ?? const Uuid().v4(),
        _productName = productName,
        _price = price,
        _stock = stock,
        _description = description,
        _category = category;

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      productId: id,
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),
      description: map['description'] ?? '',
      category: ProductCategory.fromMap(
        map['category'] ?? {},
        map['category']?['categoryId'] ?? '',
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': _productName,
      'price': _price,
      'stock': _stock,
      'description': _description,
      'category': _category.toMap(),
    };
  }

  String get productId => _productId;
  String get productName => _productName;
  double get price => _price;
  int get stock => _stock;
  String get description => _description;
  ProductCategory get category => _category;

  set productId(String value) => _productId = value;
  set productName(String value) => _productName = value;
  set price(double value) => _price = value;
  set stock(int value) => _stock = value;
  set description(String value) => _description = value;
  set category(ProductCategory value) => _category = value;
}



