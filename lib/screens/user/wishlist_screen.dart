import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/models/user.dart';
import 'package:toko_telyu/models/wishlist.dart';
import 'package:toko_telyu/models/wishlist_item.dart';
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
  User? user;
  Wishlist? wishlist;
  List<WishlistCard> wishlistCard = [];
  List<WishlistItem>? wishlistItem;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    user = await _userService.loadUser();
    wishlist = await _wishlistService.getWishlist(user!.userId);
    wishlistItem = await _wishlistService.getItems(
      user!.userId,
      wishlist!.wishlistId!,
    );
    for (var item in wishlistItem!) {
      final product = await _productService.getProduct(item.productId);
      final images = await _productService.getImages(item.productId);
      final variants = await _productService.getVariants(item.productId);
      final variant = variants.firstWhere((v) => item.variantId == v.variantId);

      wishlistCard.add(
        WishlistCard(
          productId : product.productId,
          productName: product.productName,
          productImage: images[0],
          variant: variant,
          price: product.price,
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
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
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: Color(0xFFED1E28),
        onRefresh: _loadData,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopNavbar(onChanged: () {}, text: "SEARCH PRODUCT"),
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
