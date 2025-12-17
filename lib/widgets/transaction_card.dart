import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/enums/payment_status.dart';
import 'package:toko_telyu/enums/transaction_status.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';

class TransactionCard extends StatelessWidget {
  final TransactionStatus status;
  final String date;
  final Widget productImage;
  final String productName;
  final int itemCount;
  final double orderTotal;
  final PaymentStatus paymentStatus;
  final VoidCallback? onTrackOrder;
  final VoidCallback? onReorder;
  final VoidCallback? onPayNow;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.status,
    required this.date,
    required this.productImage,
    required this.productName,
    required this.itemCount,
    required this.orderTotal,
    this.onTrackOrder,
    this.onReorder,
    this.onPayNow,
    required this.onTap,
    required this.paymentStatus,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    String buttonText;
    VoidCallback? buttonAction;

    if (paymentStatus == PaymentStatus.pending) {
      statusColor = const Color(0xFFF57C00);
      statusText = "Awaiting Payment";
      buttonText = "Pay Now";
      buttonAction = onPayNow;
    } else {
      switch (status) {
        case TransactionStatus.pending:
          statusColor = const Color(0xFF3F51B5);
          statusText = "Order Received";
          buttonText = "View Details";
          buttonAction = null;
          break;

        case TransactionStatus.preparingForDelivery:
          statusColor = const Color(0xFF5E35B1);
          statusText = "Preparing Order";
          buttonText = "View Details";
          buttonAction = null;
          break;

        case TransactionStatus.readyForPickup:
          statusColor = const Color(0xFF00897B);
          statusText = "Ready for Pickup";
          buttonText = "View Details";
          buttonAction = null;
          break;

        case TransactionStatus.outForDelivery:
          statusColor = const Color(0xFFFF9800);
          statusText = "Out for Delivery";
          buttonText = "Track Order";
          buttonAction = onTrackOrder;
          break;

        case TransactionStatus.completed:
          statusColor = const Color(0xFF2E7D32);
          statusText = "Completed";
          buttonText = "Reorder";
          buttonAction = onReorder;
          break;

        case TransactionStatus.cancelled:
          statusColor = const Color(0xFFD32F2F);
          statusText = "Cancelled";
          buttonText = "";
          buttonAction = null;
          break;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0xFFED1E28).withValues(alpha: 0.1),
        highlightColor: const Color(0xFFED1E28).withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 20,
                    color: Color(0xFFED1E28),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Purchase",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(date, style: GoogleFonts.poppins(fontSize: 11)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: 30,
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton<String>(
                      color: Colors.white,
                      onSelected: (value) {
                        if (value == 'support') {
                          // Navigate to support page
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'support',
                          child: Text('Customer Support'),
                        ),
                      ],
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              const Divider(height: 24, thickness: 1, color: Colors.grey),

              // PRODUCT DETAIL
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 51,
                    height: 47.17,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(child: productImage),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$itemCount Items",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ORDER TOTAL & BUTTON
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order Total",
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      FormattedPrice(
                        price: orderTotal,
                        size: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (buttonAction != null)
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: buttonAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: status == TransactionStatus.completed
                              ? Colors.white
                              : const Color(0xFFED1E28),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(
                            color: Color(0xFFED1E28),
                            width: 1,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: Text(
                          buttonText,
                          style: GoogleFonts.poppins(
                            color: status == TransactionStatus.completed
                                ? const Color(0xFFED1E28)
                                : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
