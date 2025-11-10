import 'package:cloud_firestore/cloud_firestore.dart';

class Cart {
  String? _cartId;
  String? _userId;

  Cart(this._cartId, this._userId);

  factory Cart.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Cart(doc.id, data['userId']);
  }

  Map<String, dynamic> toFirestore() {
    return {'userId': _userId};
  }

  String? get cartId => _cartId;
  String? get userId => _userId;
  void setCartId(String? id) => _cartId = id;
  void setUserId(String? id) => _userId = id;
}
