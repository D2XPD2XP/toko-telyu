import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wishlist.dart';
import '../models/wishlist_item.dart';

class WishlistRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _wishlistCollection(String userId) {
    return _firestore.collection('user').doc(userId).collection('wishlist');
  }

  CollectionReference<Map<String, dynamic>> _wishlistItemsCollection(String userId, String wishlistId) {
    return _wishlistCollection(userId).doc(wishlistId).collection('wishlistItems');
  }

  Future<void> createWishlist(String userId, Wishlist wishlist) async {
    await _wishlistCollection(userId).doc(wishlist.wishlistId).set(wishlist.toFirestore());
  }

  Future<void> addWishlistItem(String userId, String wishlistId, WishlistItem item) async {
    await _wishlistItemsCollection(userId, wishlistId)
        .doc(item.getWishlistItemId())
        .set(item.toMap());
  }

  Future<List<WishlistItem>> getWishlistItems(String userId, String wishlistId) async {
    final snapshot = await _wishlistItemsCollection(userId, wishlistId).get();
    return snapshot.docs.map((doc) => WishlistItem.fromMap(doc.data())).toList();
  }

  Future<void> deleteWishlistItem(String userId, String wishlistId, String itemId) async {
    await _wishlistItemsCollection(userId, wishlistId).doc(itemId).delete();
  }

  Future<void> deleteWishlist(String userId, String wishlistId) async {
    final items = await _wishlistItemsCollection(userId, wishlistId).get();
    for (final doc in items.docs) {
      await doc.reference.delete();
    }
    await _wishlistCollection(userId).doc(wishlistId).delete();
  }
}
