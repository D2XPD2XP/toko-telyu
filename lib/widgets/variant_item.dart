import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VariantItem extends StatelessWidget {
  const VariantItem({super.key, required this.variant});

  final String variant;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      width: 47,
      height: 25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Color(0xFF959597)),
      ),
      child: Text(
        variant,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500,),
        textAlign: TextAlign.center,
      ),
    );
  }
}
