import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_image.dart';
import 'package:toko_telyu/models/product_variant.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';

class CheckoutProductItem extends StatelessWidget {
  final Product product;
  final ProductVariant variant;
  final ProductImage image;
  final int qty;

  const CheckoutProductItem({
    super.key,
    required this.product,
    required this.variant,
    required this.image,
    required this.qty,
  });

  static const Color _primaryRed = Color(0xFFED1E28);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(children: [_image(), const SizedBox(width: 16), _info()]),
    );
  }

  Widget _image() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: Image.network(image.imageUrl, width: 60)),
    );
  }

  Widget _info() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.productName,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          _variant(),
          const SizedBox(height: 12),
          _priceQty(),
        ],
      ),
    );
  }

  Widget _variant() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(variant.optionName, style: GoogleFonts.poppins(fontSize: 12)),
    );
  }

  Widget _priceQty() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FormattedPrice(
          price: product.price,
          size: 14,
          fontWeight: FontWeight.w500,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: _primaryRed),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            "x$qty",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _primaryRed,
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
