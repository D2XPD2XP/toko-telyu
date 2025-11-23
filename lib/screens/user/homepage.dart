import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_category.dart';
import 'package:toko_telyu/services/product_category_services.dart';
import 'package:toko_telyu/services/product_services.dart';
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
  final ProductService _productService = ProductService();
  final ProductCategoryService _productCategoryService =
      ProductCategoryService();
  List<ProductCategory> categories = [];
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    categories = await _productCategoryService.getCategories();
    products = await _productService.getAllProducts(categories);
    setState(() {});
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
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: Color(0xFFED1E28)),
            onPressed: () {
              print(products.length);
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 18),
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
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      CategoryCircle(categoryIcon: Symbols.apparel),
                      CategoryCircle(categoryIcon: Symbols.steps),
                      CategoryCircle(categoryIcon: Symbols.backpack),
                      CategoryCircle(categoryIcon: Symbols.ink_pen),
                      CategoryCircle(categoryIcon: Symbols.menu_book),
                      CategoryCircle(categoryIcon: Symbols.apparel),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(left: 18, right: 18, bottom: 18),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 25,
                crossAxisSpacing: 25,
                childAspectRatio: 2 / 2.65,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = products[index];
                return ProductCard(product: product);
              }, childCount: products.length),
            ),
          ),
        ],
      ),
    );
  }
}
