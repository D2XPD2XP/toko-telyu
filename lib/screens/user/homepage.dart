import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_category.dart';
import 'package:toko_telyu/models/product_image.dart';
import 'package:toko_telyu/models/user.dart';
import 'package:toko_telyu/screens/user/chatbot_screen.dart';
import 'package:toko_telyu/services/product_category_services.dart';
import 'package:toko_telyu/services/product_services.dart';
import 'package:toko_telyu/services/user_services.dart';
import 'package:toko_telyu/widgets/category_circle.dart';
import 'package:toko_telyu/widgets/product_card.dart';
import 'package:toko_telyu/widgets/top_navbar.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Homepage();
  }
}

class _Homepage extends State<Homepage> {
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

  Future<void> _loadData({bool isCategory = false, int idx = 0}) async {
    user = await _userService.loadUser();
    categories = await _productCategoryService.getCategories();
    products = isCategory == false
        ? await _productService.getAllProducts(categories!)
        : await _productService.getProductByCategory(categories![idx]);
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

  void handleCategorySelected(int index) {
    _loadData(isCategory: true, idx: index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: Color(0xFFEEEEEE),
        title: TopNavbar(onChanged: () {}, text: 'SEARCH PRODUCT'),
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
            onPressed: () {},
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
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 18,
                          ),
                          padding: EdgeInsets.all(8),
                          width: 385,
                          height: 155,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 2,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Image(
                            image: AssetImage('assets/promo_toktel.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories!.length,
                            itemBuilder: (context, index) {
                              return CategoryCircle(
                                idx: index,
                                category: categories![index],
                                onTap: handleCategorySelected,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  products!.isNotEmpty
                      ? SliverPadding(
                          padding: EdgeInsets.only(
                            left: 18,
                            right: 18,
                            bottom: 18,
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
                                "Oops, there's no product with this category!",
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
