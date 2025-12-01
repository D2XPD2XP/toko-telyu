import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:toko_telyu/repositories/cart_repositories.dart';
import 'package:toko_telyu/repositories/user_repositories.dart';
import 'package:toko_telyu/repositories/wishlist_repositories.dart';
import 'package:toko_telyu/widgets/custom_dialog.dart';
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

    return user;
  }

  Future<User?> loadUser() async {
    final storage = const FlutterSecureStorage();
    String? userId = await storage.read(key: 'user_id');

    if (userId == null) {
      return null;
    }

    return await getUser(userId);
  }

  Future<User?> getUser(String userId) async {
    return await _userRepo.getUserById(userId);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    await _userRepo.updateUser(userId, updates);
  }

  Future<void> handleUsername(
    BuildContext context,
    String userId,
    String username,
  ) async {
    if (username.isEmpty) {
      return showDialog(
        context: context,
        builder: (ctx) => CustomDialog(
          ctx: ctx,
          message: 'Please make sure a valid username',
        ),
      );
    }

    Map<String, dynamic> data = {"name": username};
    await updateUser(userId, data);

    if (!context.mounted) return;
    Navigator.pop(context);
  }

  Future<void> handlePnumber(
    BuildContext context,
    String userId,
    String number,
  ) async {
    if (num.tryParse(number.trim()) == null || number.length < 11) {
      return showDialog(
        context: context,
        builder: (ctx) => CustomDialog(
          ctx: ctx,
          message: 'Please make sure a valid phone number',
        ),
      );
    }

    Map<String, dynamic> data = {"pnumber": number};
    await updateUser(userId, data);

    if (!context.mounted) return;
    Navigator.pop(context);
  }

  Future<void> handleAddress(
    String userId,
    BuildContext context,
    Map<String, dynamic> address,
  ) async {
    if ((address["province"]?.trim().isEmpty ?? true) ||
        (address["city"]?.trim().isEmpty ?? true) ||
        (address["district"]?.trim().isEmpty ?? true) ||
        (address["postal_code"]?.trim().isEmpty ?? true) ||
        (address["street"]?.trim().isEmpty ?? true)) {
      return showDialog(
        context: context,
        builder: (ctx) =>
            CustomDialog(ctx: ctx, message: 'Please make sure a valid address'),
      );
    }

    Map<String, dynamic> data = {"address": address};
    await updateUser(userId, data);

    if (!context.mounted) return;
    Navigator.pop(context);
  }

  Future<void> deleteUser(String userId) async {
    await _userRepo.deleteUser(userId);
  }

  Future<List<User>> getAllUsers() async {
    return await _userRepo.getAllUsers();
  }
}
