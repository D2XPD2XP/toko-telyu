import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:toko_telyu/models/Product.dart';
import 'package:toko_telyu/screens/user/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(),));
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
                  image: AssetImage('assets/seragam_merah_telkom.png'),
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
              'Apparel',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              'Seragam Telkom - Merah',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Rp150.000,00',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
