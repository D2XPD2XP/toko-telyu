import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/models/cart.dart';
import 'package:toko_telyu/models/cart_item.dart';
import 'package:toko_telyu/models/user.dart';
import 'package:toko_telyu/models/wishlist.dart';
import 'package:toko_telyu/models/wishlist_item.dart';
import 'package:toko_telyu/screens/user/cart_screen.dart';
import 'package:toko_telyu/services/cart_services.dart';
import 'package:toko_telyu/services/product_services.dart';
import 'package:toko_telyu/services/user_services.dart';
import 'package:toko_telyu/services/wishlist_services.dart';
import 'package:toko_telyu/widgets/top_navbar.dart';
import 'package:toko_telyu/widgets/wishlist_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() {
    return _FavoriteScreenState();
  }
}

class _FavoriteScreenState extends State<FavoritesScreen> {
  final UserService _userService = UserService();
  final ProductService _productService = ProductService();
  final WishlistService _wishlistService = WishlistService();
  final CartService _cartService = CartService();
  User? user;
  Wishlist? wishlist;
  Cart? cart;
  List<CartItem>? cartItems;
  List<WishlistCard> wishlistCard = [];
  List<WishlistItem>? wishlistItem;
  String query = "";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      loading = true;
    });
    user = await _userService.loadUser();
    wishlist = await _wishlistService.getWishlist(user!.userId);
    wishlistItem = query.isEmpty
        ? await _wishlistService.getItems(user!.userId, wishlist!.wishlistId!)
        : await _wishlistService.searchWishlistItems(
            query,
            wishlistItem!,
            _productService,
          );
    cart = await _cartService.getCart(user!.userId);
    cartItems = await _cartService.getItems(user!.userId, cart!.cartId!);
    wishlistCard = await _wishlistService.loadWishlistCards(
      user!.userId,
      cart!.cartId!,
      wishlistItem!,
      cartItems,
      _productService,
      _loadData,
    );
    setState(() {
      loading = false;
    });
  }

  void _updateQuery(String newQuery) {
    query = newQuery;
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFED1E28)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Wishlist",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xFFED1E28),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: Color(0xFFED1E28),
        onRefresh: () {
          query = "";
          return _loadData();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopNavbar(
                onSubmitted: _updateQuery,
                text: query.isEmpty ? "SEARCH PRODUCT" : query.toUpperCase(),
                onchanged: true,
              ),
              const SizedBox(height: 20),
              // Header Jumlah Item
              Text(
                wishlistItem!.isNotEmpty ? "${wishlistItem!.length} Item" : "",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              wishlistItem!.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return wishlistCard[index];
                        },
                        itemCount: wishlistItem!.length,
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 150,
                        horizontal: 15,
                      ),
                      child: Text(
                        "Oops, there's no wishlisted product!",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFED1E28),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
