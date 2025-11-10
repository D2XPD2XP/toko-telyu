import 'package:toko_telyu/repositories/wishlist_repositories.dart';
import 'package:uuid/uuid.dart';
import '../models/wishlist.dart';
import '../models/wishlist_item.dart';

class WishlistService {
  final WishlistRepository _repo = WishlistRepository();

  Future<Wishlist> createWishlist(String userId) async {
    final wishlistId = const Uuid().v4();
    final wishlist = Wishlist(wishlistId, userId);
    await _repo.createWishlist(userId, wishlist);
    return wishlist;
  }

  Future<void> addItem(String userId, String wishlistId, WishlistItem item) async {
    await _repo.addWishlistItem(userId, wishlistId, item);
  }

  Future<List<WishlistItem>> getItems(String userId, String wishlistId) async {
    return await _repo.getWishlistItems(userId, wishlistId);
  }

  Future<void> deleteItem(String userId, String wishlistId, String itemId) async {
    await _repo.deleteWishlistItem(userId, wishlistId, itemId);
  }

  Future<void> deleteWishlist(String userId, String wishlistId) async {
    await _repo.deleteWishlist(userId, wishlistId);
  }
}
