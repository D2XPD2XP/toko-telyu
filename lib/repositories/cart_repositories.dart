import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _cartCollection(String userId) {
    return _firestore.collection('user').doc(userId).collection('cart');
  }

  CollectionReference<Map<String, dynamic>> _cartItemsCollection(
    String userId,
    String cartId,
  ) {
    return _cartCollection(userId).doc(cartId).collection('cartItems');
  }

  // Create empty cart
  Future<void> createCart(String userId, Cart cart) async {
    await _cartCollection(userId).doc(cart.cartId).set(cart.toFirestore());
  }

  Future<Cart> getCart(String userId) async {
    final snapshot = await _cartCollection(userId).get();

    final doc = snapshot.docs.first;

    return Cart.fromFirestore(doc.data(), doc.id);
  }

  // Add new cart item
  Future<void> addCartItem(String userId, String cartId, CartItem item) async {
    await _cartItemsCollection(
      userId,
      cartId,
    ).doc(item.cartItemId).set(item.toMap());
  }

  // Get all cart items
  Future<List<CartItem>> getCartItems(String userId, String cartId) async {
    final snapshot = await _cartItemsCollection(userId, cartId).get();

    return snapshot.docs
        .map((doc) => CartItem.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Update cart item
  Future<void> updateCartItem(
    String userId,
    String cartId,
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    await _cartItemsCollection(userId, cartId).doc(itemId).update(updates);
  }

  // Delete one item
  Future<void> deleteCartItem(
    String userId,
    String cartId,
    String itemId,
  ) async {
    await _cartItemsCollection(userId, cartId).doc(itemId).delete();
  }

  // Delete the entire cart (including items)
  Future<void> deleteCart(String userId, String cartId) async {
    final items = await _cartItemsCollection(userId, cartId).get();

    for (final doc in items.docs) {
      await doc.reference.delete();
    }

    await _cartCollection(userId).doc(cartId).delete();
  }
}
