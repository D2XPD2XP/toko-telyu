import 'package:toko_telyu/models/product_variant.dart';
import 'package:toko_telyu/repositories/cart_repositories.dart';
import 'package:toko_telyu/repositories/product_repositories.dart';
import 'package:uuid/uuid.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';

class CartService {
  final CartRepository _repo = CartRepository();
  final ProductRepository _productRepo = ProductRepository();
  final _uuid = const Uuid();

  Future<Cart> createCart(String userId) async {
    final cartId = _uuid.v4();
    final cart = Cart(cartId, userId);
    await _repo.createCart(userId, cart);
    return cart;
  }

  Future<Cart?> getCart(String userId) async {
    final cart = await _repo.getCart(userId);
    return cart;
  }

  Future<void> addItem({
    required String userId,
    required String cartId,
    required String productId,
    required ProductVariant variant,
    required int amount,
  }) async {
    final product = await _productRepo.getProduct(productId);

    if (variant.stock < amount) {
      throw Exception("Stock tidak cukup");
    }

    final existingItems = await _repo.getCartItems(userId, cartId);
    CartItem? existing = existingItems.cast<CartItem?>().firstWhere(
      (item) => item!.productId == productId && item.variantId == variant.variantId,
      orElse: () => null,
    );

    if (existing != null) {
      // Update jumlah
      final newAmount = existing.amount + amount;
      final newSubtotal = (product.price) * newAmount;

      await _repo.updateCartItem(userId, cartId, existing.cartItemId!, {
        "amount": newAmount,
        "subtotal": newSubtotal,
      });

      return;
    }

    final subtotal = (product.price) * amount;

    final item = CartItem(
      const Uuid().v4(),
      amount,
      subtotal,
      productId,
      variant.variantId,
    );

    await _repo.addCartItem(userId, cartId, item);
  }

  Future<List<CartItem>> getItems(String userId, String cartId) async {
    return await _repo.getCartItems(userId, cartId);
  }

  Future<void> updateItem(
    String userId,
    String cartId,
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    await _repo.updateCartItem(userId, cartId, itemId, updates);
  }

  Future<void> deleteItem(String userId, String cartId, String itemId) async {
    await _repo.deleteCartItem(userId, cartId, itemId);
  }

  Future<void> deleteCart(String userId, String cartId) async {
    await _repo.deleteCart(userId, cartId);
  }
}
