import 'package:flutter/material.dart';
import 'package:toko_telyu/models/cart_item.dart';
import 'package:toko_telyu/services/product_services.dart';
import 'package:toko_telyu/widgets/wishlist_card.dart';
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

  Future<List<WishlistCard>> loadWishlistCards(
    String userId,
    String cartId,
    List<WishlistItem> wishlistItems,
    List<CartItem>? cartItems,
    ProductService productService,
    VoidCallback onAdd,
  ) async {
    final List<WishlistCard> wishlistCards = [];

    for (var item in wishlistItems) {
      final product = await productService.getProduct(item.productId);
      final images = await productService.getImages(item.productId);
      final variants = await productService.getVariants(item.productId);
      final variant = variants.firstWhere((v) => item.variantId == v.variantId);

      wishlistCards.add(
        WishlistCard(
          userId: userId,
          cartId: cartId,
          productId: product.productId,
          productName: product.productName,
          productImage: images[0],
          cartItems: cartItems,
          variant: variant,
          price: product.price,
          onAdd: onAdd,
        ),
      );
    }

    return wishlistCards;
  } 

  Future<List<WishlistItem>> searchWishlistItems(
    String query,
    List<WishlistItem> wishlistItems,
    ProductService productService,
  ) async {
    final List<WishlistItem> filteredItems = [];

    for (final item in wishlistItems) {
      final product = await productService.getProduct(item.productId);
      if (product.productName.toLowerCase().contains(query.toLowerCase())) {
        filteredItems.add(item);
      }
    }

    return filteredItems;
  }
}
