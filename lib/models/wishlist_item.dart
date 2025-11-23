class WishlistItem {
  String? _wishlistItemId;
  String _productId;
  String _variantId;

  WishlistItem(
    this._wishlistItemId,
    this._productId,
    this._variantId,
  );

  factory WishlistItem.fromMap(Map<String, dynamic> data, String id) {
    return WishlistItem(
      id,
      data['productId'],
      data['variantId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': _productId,
      'variantId': _variantId,
    };
  }

  // Getters
  String? get wishlistItemId => _wishlistItemId;
  String get productId => _productId;
  String get variantId => _variantId;

  // Setters
  void setWishlistItemId(String? id) => _wishlistItemId = id;
  void setProductId(String id) => _productId = id;
  void setVariantId(String id) => _variantId = id;
}




