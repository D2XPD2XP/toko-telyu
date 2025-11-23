import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class FormattedPrice extends StatelessWidget {
  const FormattedPrice({super.key, required this.price, required this.size, required this.fontWeight});

  final double price;
  final double size;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 2,
    );

    String formattedPrice = currencyFormatter.format(price);

    return Text(
      formattedPrice,
      style: GoogleFonts.poppins(
        fontSize: size,
        fontWeight: fontWeight,
        color: Colors.black,
      ),
    );
  }
}
