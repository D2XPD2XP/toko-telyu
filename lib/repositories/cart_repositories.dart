import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _cartCollection(String userId) {
    return _firestore.collection('user').doc(userId).collection('cart');
  }

  CollectionReference<Map<String, dynamic>> _cartItemsCollection(String userId, String cartId) {
    return _cartCollection(userId).doc(cartId).collection('cartItems');
  }

  Future<void> createCart(String userId, Cart cart) async {
    await _cartCollection(userId).doc(cart.cartId).set(cart.toFirestore());
  }

  Future<void> addCartItem(String userId, String cartId, CartItem item) async {
    await _cartItemsCollection(userId, cartId)
        .doc(item.getCartItemId())
        .set(item.toMap());
  }

  Future<List<CartItem>> getCartItems(String userId, String cartId) async {
    final snapshot = await _cartItemsCollection(userId, cartId).get();
    return snapshot.docs.map((doc) => CartItem.fromMap(doc.data())).toList();
  }

  Future<void> updateCartItem(String userId, String cartId, String itemId, Map<String, dynamic> updates) async {
    await _cartItemsCollection(userId, cartId).doc(itemId).update(updates);
  }

  Future<void> deleteCartItem(String userId, String cartId, String itemId) async {
    await _cartItemsCollection(userId, cartId).doc(itemId).delete();
  }

  Future<void> deleteCart(String userId, String cartId) async {
    final items = await _cartItemsCollection(userId, cartId).get();
    for (final doc in items.docs) {
      await doc.reference.delete();
    }
    await _cartCollection(userId).doc(cartId).delete();
  }
}
