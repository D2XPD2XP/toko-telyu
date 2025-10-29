import 'Cart.dart';
import 'Product.dart';
import 'ProductVariant.dart';

class CartItem {
  String? _cartItemId;
  int? _amount;
  double? _subtotal;
  Cart? _cart;
  Product? _product;
  ProductVariant? _variant;

  CartItem(
    this._cartItemId,
    this._amount,
    this._subtotal,
    this._cart,
    this._product,
    this._variant,
  );

  // Getters
  String? getCartItemId() => _cartItemId;
  int? getAmount() => _amount;
  double? getSubtotal() => _subtotal;
  Cart? getCart() => _cart;
  Product? getProduct() => _product;
  ProductVariant? getVariant() => _variant;

  // Setters
  void setCartItemId(String? cartItemId) {
    _cartItemId = cartItemId;
  }

  void setAmount(int? amount) {
    _amount = amount;
  }

  void setSubtotal(double? subtotal) {
    _subtotal = subtotal;
  }

  void setCart(Cart? cart) {
    _cart = cart;
  }

  void setProduct(Product? product) {
    _product = product;
  }

  void setVariant(ProductVariant? variant) {
    _variant = variant;
  }
}
