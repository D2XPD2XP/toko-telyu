import 'package:toko_telyu/repositories/cart_repositories.dart';
import 'package:toko_telyu/repositories/user_repositories.dart';
import 'package:toko_telyu/repositories/wishlist_repositories.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/cart.dart';
import '../models/wishlist.dart';

class UserService {
  final UserRepository _userRepo = UserRepository();
  final CartRepository _cartRepo = CartRepository();
  final WishlistRepository _wishlistRepo = WishlistRepository();
  final _uuid = const Uuid();

  Future<User> createUser({
    required String email,
    required String name,
    required String password,
  }) async {
    final userId = _uuid.v4();

    final user = User(
      userId,
      email,
      name,
      password,
      pnumber: null,
      address: null,
    );

    await _userRepo.createUser(user);

    final cartId = _uuid.v4();
    final cart = Cart(cartId, userId);
    await _cartRepo.createCart(userId, cart);

    final wishlistId = _uuid.v4();
    final wishlist = Wishlist(wishlistId, userId);
    await _wishlistRepo.createWishlist(userId, wishlist);

    user.setCart(cart);
    user.setWishlist(wishlist);

    return user;
  }

  Future<User?> getUser(String userId) async {
    return await _userRepo.getUserById(userId);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    await _userRepo.updateUser(userId, updates);
  }

  Future<void> deleteUser(String userId) async {
    await _userRepo.deleteUser(userId);
  }

  Future<List<User>> getAllUsers() async {
    return await _userRepo.getAllUsers();
  }
}
