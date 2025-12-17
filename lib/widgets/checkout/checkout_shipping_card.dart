import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/enums/shipping_method.dart';
import 'package:toko_telyu/models/delivery_area.dart';

class CheckoutShippingCard extends StatelessWidget {
  final ShippingMethod method;
  final DeliveryArea? area;
  final Map<String, dynamic>? address;
  final VoidCallback onTap;

  const CheckoutShippingCard({
    super.key,
    required this.method,
    required this.area,
    required this.address,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Expanded(child: _text()),
            const Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }

  Widget _text() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Shipping Option",
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _title(),
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          _subtitle(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _title() {
    switch (method) {
      case ShippingMethod.pickup:
        return "Pickup at Store";
      case ShippingMethod.directDelivery:
        return "Direct Delivery";
      case ShippingMethod.delivery:
        return "Standard Delivery";
    }
  }

  String _subtitle() {
    switch (method) {
      case ShippingMethod.pickup:
        return "Collect your order at store";
      case ShippingMethod.directDelivery:
        return area?.getAreaname() ?? "No area selected";
      case ShippingMethod.delivery:
        return address?["street"] ?? "No address selected";
    }
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
