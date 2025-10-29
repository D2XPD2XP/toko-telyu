import 'Wishlist.dart';
import 'Product.dart';
import 'ProductVariant.dart';

class WishlistItem {
  String? _wishlistItemId;
  Wishlist? _wishlist;
  Product? _product;
  ProductVariant? _variant;

  WishlistItem(
    this._wishlistItemId,
    this._wishlist,
    this._product,
    this._variant,
  );

  // Getters
  String? getWishlistItemId() => _wishlistItemId;
  Wishlist? getWishlist() => _wishlist;
  Product? getProduct() => _product;
  ProductVariant? getVariant() => _variant;

  // Setters
  void setWishlistItemId(String? wishlistItemId) {
    _wishlistItemId = wishlistItemId;
  }

  void setWishlist(Wishlist? wishlist) {
    _wishlist = wishlist;
  }

  void setProduct(Product? product) {
    _product = product;
  }

  void setVariant(ProductVariant? variant) {
    _variant = variant;
  }
}
