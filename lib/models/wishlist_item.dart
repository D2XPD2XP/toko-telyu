import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_variant.dart';

class WishlistItem {
  String? _wishlistItemId;
  Product? _product;
  ProductVariant? _variant;

  WishlistItem(this._wishlistItemId, this._product, this._variant);

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      map['wishlistItemId'],
      map['product'], //!= null ? Product.fromMap(map['product']) : null,
      map['variant'] //!= null ? ProductVariant.fromMap(map['variant']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'wishlistItemId': _wishlistItemId,
      'product': _product,//?.toMap(),
      'variant': _variant//?.toMap(),
    };
  }

  String? getWishlistItemId() => _wishlistItemId;
  Product? getProduct() => _product;
  ProductVariant? getVariant() => _variant;

  void setWishlistItemId(String? id) => _wishlistItemId = id;
  void setProduct(Product? product) => _product = product;
  void setVariant(ProductVariant? variant) => _variant = variant;
}


