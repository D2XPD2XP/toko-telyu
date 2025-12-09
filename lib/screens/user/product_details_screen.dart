import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/models/cart.dart';
import 'package:toko_telyu/models/cart_item.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_image.dart';
import 'package:toko_telyu/models/product_variant.dart';
import 'package:toko_telyu/models/user.dart';
import 'package:toko_telyu/screens/user/account_screen.dart';
import 'package:toko_telyu/screens/user/cart_screen.dart';
import 'package:toko_telyu/screens/user/checkout_screen.dart';
import 'package:toko_telyu/services/cart_services.dart';
import 'package:toko_telyu/services/product_services.dart';
import 'package:toko_telyu/services/user_services.dart';
import 'package:toko_telyu/widgets/custom_dialog.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';
import 'package:toko_telyu/widgets/product_image_carousel.dart';
import 'package:toko_telyu/widgets/variant_item.dart';
import 'package:uuid/uuid.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailsScreen> createState() {
    return _ProductDetailScreen();
  }
}

class _ProductDetailScreen extends State<ProductDetailsScreen> {
  final UserService _userService = UserService();
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  User? user;
  Cart? cart;
  Product? product;
  List<ProductImage>? images;
  List<ProductVariant>? variants;
  List<CartItem>? cartItems;
  int selectedIndex = 0;
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
    cart = await _cartService.getCart(user!.userId);
    cartItems = await _cartService.getItems(user!.userId, cart!.cartId!);
    product = await _productService.getProduct(widget.productId);
    images = await _productService.getImages(widget.productId);
    variants = await _productService.getVariants(widget.productId);
    setState(() {
      loading = false;
    });
  }

  void handleButton(int index) {
    setState(() {
      selectedIndex = index;
    });
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
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: Color(0xFFED1E28)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          IconButton(
            iconSize: 28,
            icon: Icon(Icons.dehaze, color: Color(0xFFED1E28)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            },
          ),
          SizedBox(width: 10),
        ],
        backgroundColor: Color(0xFFEEEEEE),
      ),
      backgroundColor: Color(0xFFEEEEEE),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: Color(0xFFED1E28),
        onRefresh: _loadData,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 26),
                margin: EdgeInsets.symmetric(vertical: 14, horizontal: 25),
                width: 375,
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
                child: ProductImageCarousel(
                  product: product!,
                  images: images!,
                  variant: variants![selectedIndex],
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  top: 14,
                  bottom: 20,
                  left: 23,
                  right: 11,
                ),
                margin: EdgeInsets.symmetric(horizontal: 25),
                width: 375,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product!.category.categoryName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      product!.productName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6),
                    FormattedPrice(
                      price: product!.price,
                      size: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    Text(
                      'Stok: ${variants![selectedIndex].stock}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Text(
                            product!.category.isFittable
                                ? 'Select Size'
                                : 'Select Variant',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_right),
                        ],
                      ),
                    ),
                    SizedBox(height: 6),
                    SizedBox(
                      height: 25,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: variants!.length,
                        itemBuilder: (context, index) {
                          bool isSelected = index == selectedIndex;
                          ProductVariant variant = variants![index];
                          return VariantItem(
                            variant: variant.optionName,
                            isSelected: isSelected,
                            idx: index,
                            onTap: handleButton,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Product Description',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 19),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                if (variants![selectedIndex].stock < 1) {
                  showDialog(
                    context: context,
                    builder: (context) => CustomDialog(
                      ctx: context,
                      message:
                          'This variant is not available. Please select another variant',
                      title: "SOLD OUT",
                    ),
                  );
                } else {
                  List<CartItem> items = [
                    CartItem(
                      Uuid().v4(),
                      1,
                      product!.price,
                      product!.productId,
                      variants![selectedIndex].variantId,
                    ),
                  ];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(cartItems: items),
                    ),
                  );
                }
              },
              child: Container(
                width: 170,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFED1E28), width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Buy Now',
                  style: GoogleFonts.poppins(
                    color: Color(0xFFED1E28),
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            SizedBox(width: 11),
            InkWell(
              onTap: () async {
                int currentAmount = cartItems!.isNotEmpty
                    ? _cartService.currentItemAmount(
                        cartItems,
                        product!.productId,
                        variants![selectedIndex].variantId,
                      )
                    : 0;
                if (variants![selectedIndex].stock < 1 ||
                    variants![selectedIndex].stock < currentAmount + 1) {
                  showDialog(
                    context: context,
                    builder: (context) => CustomDialog(
                      ctx: context,
                      message:
                          'This variant is not available. Please select another variant',
                      title: "NOT AVAILABLE",
                    ),
                  );
                } else {
                  await _cartService.addItem(
                    userId: user!.userId,
                    cartId: cart!.cartId!,
                    productId: product!.productId,
                    variant: variants![selectedIndex],
                    amount: 1,
                  );
                  await _loadData();
                }
              },
              child: Container(
                width: 170,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFFED1E28),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Add to cart',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
