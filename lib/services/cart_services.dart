import 'package:toko_telyu/repositories/cart_repositories.dart';
import 'package:uuid/uuid.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';

class CartService {
  final CartRepository _repo = CartRepository();

  Future<Cart> createCart(String userId) async {
    final cartId = const Uuid().v4();
    final cart = Cart(cartId, userId);
    await _repo.createCart(userId, cart);
    return cart;
  }

  Future<void> addItem(String userId, String cartId, CartItem item) async {
    await _repo.addCartItem(userId, cartId, item);
  }

  Future<List<CartItem>> getItems(String userId, String cartId) async {
    return await _repo.getCartItems(userId, cartId);
  }

  Future<void> updateItem(String userId, String cartId, String itemId, Map<String, dynamic> updates) async {
    await _repo.updateCartItem(userId, cartId, itemId, updates);
  }

  Future<void> deleteItem(String userId, String cartId, String itemId) async {
    await _repo.deleteCartItem(userId, cartId, itemId);
  }

  Future<void> deleteCart(String userId, String cartId) async {
    await _repo.deleteCart(userId, cartId);
  }
}
