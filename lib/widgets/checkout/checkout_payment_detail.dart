import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';
import 'package:toko_telyu/enums/shipping_method.dart';

class CheckoutPaymentDetail extends StatelessWidget {
  final double subtotal;
  final double shippingCost;
  final double serviceFee;
  final double grandTotal;
  final ShippingMethod shippingMethod;

  const CheckoutPaymentDetail({
    super.key,
    required this.subtotal,
    required this.shippingCost,
    required this.serviceFee,
    required this.grandTotal,
    required this.shippingMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Details",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          _row("Item Subtotal", subtotal),
          if (shippingMethod != ShippingMethod.pickup)
            _row("Total Shipping Cost", shippingCost),
          _row("Service Fee", serviceFee),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order Total",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              FormattedPrice(
                price: grandTotal,
                size: 16,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
          FormattedPrice(price: value, size: 12, fontWeight: FontWeight.w700),
        ],
      ),
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
