import 'package:cloud_firestore/cloud_firestore.dart';

class Wishlist {
  String? _wishlistId;
  String? _userId;

  Wishlist(this._wishlistId, this._userId);

  factory Wishlist.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Wishlist(doc.id, data['userId']);
  }

  Map<String, dynamic> toFirestore() {
    return {'userId': _userId};
  }

  String? get wishlistId => _wishlistId;
  String? get userId => _userId;
  void setWishlistId(String? id) => _wishlistId = id;
  void setUserId(String? id) => _userId = id;
}

