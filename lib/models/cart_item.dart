class CartItem {
  String? _cartItemId;
  int _amount;
  double _subtotal;
  String _productId;
  String _variantId;

  CartItem(
    this._cartItemId,
    this._amount,
    this._subtotal,
    this._productId,
    this._variantId,
  );

  factory CartItem.fromMap(Map<String, dynamic> data, String id) {
    return CartItem(
      id,
      data['amount'],
      (data['subtotal'] as num).toDouble(),
      data['productId'],
      data['variantId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': _amount,
      'subtotal': _subtotal,
      'productId': _productId,
      'variantId': _variantId,
    };
  }

  // Getters
  String? get cartItemId => _cartItemId;
  int get amount => _amount;
  double get subtotal => _subtotal;
  String get productId => _productId;
  String get variantId => _variantId;

  // Setters
  void setCartItemId(String? id) => _cartItemId = id;
  void setAmount(int value) => _amount = value;
  void setSubtotal(double value) => _subtotal = value;
  void setProductId(String id) => _productId = id;
  void setVariantId(String id) => _variantId = id;
}

