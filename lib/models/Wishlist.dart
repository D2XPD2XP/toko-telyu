import 'User.dart';
import 'WishlistItem.dart';

class Wishlist {
  String? _wishlistId;
  User? _customer;
  List<WishlistItem>? _items;

  Wishlist(this._wishlistId, this._customer, this._items);

  // Getters
  String? getWishlistId() => _wishlistId;
  User? getCustomer() => _customer;
  List<WishlistItem>? getItems() => _items;

  // Setters
  void setWishlistId(String? wishlistId) {
    _wishlistId = wishlistId;
  }

  void setCustomer(User? customer) {
    _customer = customer;
  }

  void setItems(List<WishlistItem>? items) {
    _items = items;
  }
}
