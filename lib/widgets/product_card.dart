import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_image.dart';
import 'package:toko_telyu/screens/user/product_details_screen.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.image});

  final Product product;
  final ProductImage? image;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailsScreen(productId: product.productId,)),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: EdgeInsets.all(8),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Image(
                  image: NetworkImage(  
                    image?.imageUrl ?? '',
                  ),
                  width: 200,
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: InkWell(
                    onTap: () {},
                    child: Icon(Symbols.heart_plus, color: Colors.grey[900]),
                  ),
                ),
              ],
            ),
            Text(
              product.category.categoryName,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              product.productName,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),
            FormattedPrice(
              price: product.price,
              size: 11,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}
