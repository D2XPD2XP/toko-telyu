import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/models/product_category.dart';

class CategoryCircle extends StatelessWidget {
  const CategoryCircle({super.key, required this.category});

  final ProductCategory category;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 2,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Image.network(category.iconUrl)//Icon(categor, size: 33, color: Color(0xFFED1E28),),
        ),
        SizedBox(
          width: 70,
          child: Text(
            category.categoryName,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w300,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
