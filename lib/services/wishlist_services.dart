import 'package:uuid/uuid.dart';
import '../models/wishlist.dart';
import '../models/wishlist_item.dart';
import '../repositories/wishlist_repositories.dart';

class WishlistService {
  final WishlistRepository _repo = WishlistRepository();

  Future<Wishlist> createWishlist(String userId) async {
    final wishlistId = const Uuid().v4();
    final wishlist = Wishlist(wishlistId, userId);
    await _repo.createWishlist(userId, wishlist);
    return wishlist;
  }

  Future<Wishlist> getWishlist(String userId) async {
    final wishlist = await _repo.getWishlist(userId);
    return wishlist;
  }

  Future<void> addItem({
    required String userId,
    required String wishlistId,
    required String productId,
    required String? variantId,
  }) async {
    final existingItems = await _repo.getWishlistItems(userId, wishlistId);

    final exists = existingItems.any(
      (item) => item.productId == productId && item.variantId == variantId,
    );

    if (exists) {
      return;
    }

    final item = WishlistItem(const Uuid().v4(), productId, variantId);

    await _repo.addWishlistItem(userId, wishlistId, item);
  }

  Future<List<WishlistItem>> getItems(String userId, String wishlistId) async {
    return await _repo.getWishlistItems(userId, wishlistId);
  }

  Future<void> deleteItem(
    String userId,
    String wishlistId,
    String itemId,
  ) async {
    await _repo.deleteWishlistItem(userId, wishlistId, itemId);
  }

  Future<void> deleteWishlist(String userId, String wishlistId) async {
    await _repo.deleteWishlist(userId, wishlistId);
  }

  bool isWishlisted(
    String productId,
    String? variantId,
    List<WishlistItem> wishlistItems,
  ) {
    if (variantId == null) {
      return wishlistItems.any(
      (w) => w.productId == productId
    );
    }
    return wishlistItems.any(
      (w) => w.productId == productId && w.variantId == variantId,
    );
  }
}
