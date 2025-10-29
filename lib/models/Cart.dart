import 'User.dart';
import 'CartItem.dart';

class Cart {
  String? _cartId;
  User? _user;
  List<CartItem>? _items;

  Cart(this._cartId, this._user, this._items);

  // Getters
  String? getCartId() => _cartId;
  User? getUser() => _user;
  List<CartItem>? getItems() => _items;

  // Setters
  void setCartId(String? cartId) {
    _cartId = cartId;
  }

  void setUser(User? user) {
    _user = user;
  }

  void setItems(List<CartItem>? items) {
    _items = items;
  }
}
