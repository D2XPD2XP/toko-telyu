import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/models/cart.dart';
import 'package:toko_telyu/models/cart_item.dart';
import 'package:toko_telyu/models/product_image.dart';
import 'package:toko_telyu/models/user.dart';
import 'package:toko_telyu/screens/user/wishlist_screen.dart';
import 'package:toko_telyu/services/cart_services.dart';
import 'package:toko_telyu/services/product_services.dart';
import 'package:toko_telyu/services/user_services.dart';
import 'package:toko_telyu/widgets/cart_item_card.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';
import 'package:toko_telyu/screens/user/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Color primaryRed = const Color(0xFFED1E28);
  final Color bgGrey = const Color(0xFFF5F5F5);
  final UserService _userService = UserService();
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  User? user;
  Cart? cart;
  List<CartItem>? cartItems;
  List<CartItemCard> cartCard = [];
  Map<String, List<ProductImage>> productImages = {};
  bool loading = true;

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
    cart = await _cartService.getCart(user!.userId);
    cartItems = await _cartService.getItems(user!.userId, cart!.cartId!);
    for (var p in cartItems!) {
      productImages[p.productId] = await _productService.getImages(p.productId);
    }
    cartCard = await _cartService.loadCartCards(
      user!.userId,
      cart!.cartId!,
      cartItems!,
      _productService,
      _loadData,
    );
    setState(() {
      loading = false;
    });
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

    double totalPrice = 0;
    for (var item in cartItems!) {
      totalPrice += item.subtotal;
    }

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Cart",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
            icon: const Icon(Icons.favorite_border, color: Color(0xFFED1E28)),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: Color(0xFFED1E28),
        onRefresh: _loadData,
        child: Column(
          children: [
            // --- HEADER SELEKSI ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: bgGrey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${cartItems!.length} Selected Items",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: cartItems!.length,
                itemBuilder: (context, index) {
                  return cartCard[index];
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: loading == false
            ? Row(
                children: [
                  const Spacer(),

                  FormattedPrice(
                    price: totalPrice,
                    size: 16,
                    fontWeight: FontWeight.bold,
                  ),

                  const SizedBox(width: 15),

                  // Button Buy
                  SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CheckoutScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: Text(
                        "Buy(${cartItems!.length})",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(color: Color(0xFFED1E28)),
              ),
      ),
    );
  }
}
