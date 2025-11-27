import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_image.dart';
import 'package:toko_telyu/models/product_variant.dart';
import 'package:toko_telyu/services/product_services.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';
import 'package:toko_telyu/widgets/product_image_carousel.dart';
import 'package:toko_telyu/widgets/variant_item.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailsScreen> createState() {
    return _ProductDetailScreen();
  }
}

class _ProductDetailScreen extends State<ProductDetailsScreen> {
  final ProductService _productService = ProductService();
  Product? product;
  List<ProductImage>? images;
  List<ProductVariant>? variants;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    product = await _productService.getProduct(widget.productId);
    images = await _productService.getImages(widget.productId);
    if (product!.category.isFittable) {
      variants = await _productService.getVariants(widget.productId);
    }
    setState(() {});
  }

  void handleButton(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
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
            onPressed: () {},
          ),
          IconButton(
            iconSize: 28,
            icon: Icon(Icons.dehaze, color: Color(0xFFED1E28)),
            onPressed: () {},
          ),
          SizedBox(width: 10),
        ],
        backgroundColor: Color(0xFFEEEEEE),
      ),
      backgroundColor: Color(0xFFEEEEEE),
      body: SingleChildScrollView(
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
              child: ProductImageCarousel(images: images!),
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
                    product!.category.isFittable && variants!.isNotEmpty
                        ? 'Stok: ${variants![selectedIndex].stock}'
                        : 'Stok: ${product!.stock}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  if (product!.category.isFittable && variants!.isNotEmpty) ...[
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Text(
                            'Select Size',
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
                  ],
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
              onTap: () {},
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
              onTap: () {},
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
