import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_variant.dart';

class CartItem {
  String? _cartItemId;
  int? _amount;
  double? _subtotal;
  Product? _product;
  ProductVariant? _variant;

  CartItem(
    this._cartItemId,
    this._amount,
    this._subtotal,
    this._product,
    this._variant,
  );

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      map['cartItemId'],
      map['amount'],
      (map['subtotal'] as num?)?.toDouble(),
      map['product'], //!= null //? Product.fromMap(map['product']) : null,
      map['variant'] //!= null //? ProductVariant.fromMap(map['variant']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cartItemId': _cartItemId,
      'amount': _amount,
      'subtotal': _subtotal,
      'product': _product,//toMap(),
      'variant': _variant,//.toMap(),
    };
  }

  String? getCartItemId() => _cartItemId;
  int? getAmount() => _amount;
  double? getSubtotal() => _subtotal;
  Product? getProduct() => _product;
  ProductVariant? getVariant() => _variant;

  void setCartItemId(String? id) => _cartItemId = id;
  void setAmount(int? amount) => _amount = amount;
  void setSubtotal(double? subtotal) => _subtotal = subtotal;
  void setProduct(Product? product) => _product = product;
  void setVariant(ProductVariant? variant) => _variant = variant;
}
