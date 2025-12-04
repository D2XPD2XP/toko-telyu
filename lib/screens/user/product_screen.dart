import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_category.dart';
import 'package:toko_telyu/models/product_image.dart';
import 'package:toko_telyu/models/user.dart';
import 'package:toko_telyu/screens/user/cart_screen.dart';
import 'package:toko_telyu/screens/user/chatbot_screen.dart';
import 'package:toko_telyu/services/product_category_services.dart';
import 'package:toko_telyu/services/product_services.dart';
import 'package:toko_telyu/services/user_services.dart';
import 'package:toko_telyu/widgets/product_card.dart';
import 'package:toko_telyu/widgets/top_navbar.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, required this.query});

  final String query;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final UserService _userService = UserService();
  final ProductService _productService = ProductService();
  final ProductCategoryService _productCategoryService =
      ProductCategoryService();
  User? user;
  List<ProductCategory>? categories;
  List<Product>? products;
  Map<String, List<ProductImage>> productImages = {};
  Map<String, bool> availability = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    user = await _userService.loadUser();
    categories = await _productCategoryService.getCategories();
    products = await _productService.searchProducts(widget.query, categories!);
    for (var p in products!) {
      productImages[p.productId] = await _productService.getImages(p.productId);
    }
    for (final v in products!) {
      availability[v.productId] = await _productService.isAvailable(
        v.productId,
      );
    }
    setState(() {});
  }

  void handleSearchSubmitted(String value) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductScreen(query: value)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: Color(0xFFEEEEEE),
        title: TopNavbar(
          onSubmitted: handleSearchSubmitted,
          text: widget.query.toUpperCase(),
          onchanged: false,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: Color(0xFFED1E28)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatbotScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: Color(0xFFED1E28)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: user != null
          ? RefreshIndicator(
              backgroundColor: Colors.white,
              color: Color(0xFFED1E28),
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  products!.isNotEmpty
                      ? SliverPadding(
                          padding: EdgeInsets.only(
                            left: 18,
                            right: 18,
                            bottom: 18,
                            top : 20
                          ),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 25,
                                  crossAxisSpacing: 25,
                                  childAspectRatio: 2 / 2.65,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final product = products![index];
                              final available =
                                  availability[product.productId] ?? false;
                              if (available) {
                                final firstImage =
                                    productImages[product.productId]!.isNotEmpty
                                    ? productImages[product.productId]![0]
                                    : null;
                                return ProductCard(
                                  user: user!,
                                  product: product,
                                  image: firstImage,
                                );
                              }
                              return null;
                            }, childCount: products!.length),
                          ),
                        )
                      : SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25.0,
                                vertical: 100.0,
                              ),
                              child: Text(
                                "Oops, there's no product with this keyword!",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFED1E28),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator(color: Color(0xFFED1E28))),
    );
  }
}
