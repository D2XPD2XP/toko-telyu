import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/enums/transaction_status.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';

class TransactionCard extends StatelessWidget {
  final TransactionStatus status;
  final String date;
  final String productImage;
  final String productName;
  final int itemCount;
  final double orderTotal;
  final VoidCallback? onTrackOrder;
  final VoidCallback? onReorder;
  final VoidCallback onTap;

  const TransactionCard({
    Key? key,
    required this.status,
    required this.date,
    required this.productImage,
    required this.productName,
    required this.itemCount,
    required this.orderTotal,
    this.onTrackOrder,
    this.onReorder,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    String buttonText;
    VoidCallback? buttonAction;

    if (status == TransactionStatus.outForDelivery) {
      statusColor = const Color.fromARGB(255, 235, 212, 5);
      statusText = "Out For Delivery";
      buttonText = "Track Order";
      buttonAction = onTrackOrder;
    } else {
      statusColor = Colors.green.shade600;
      statusText = "Completed";
      buttonText = "Reorder";
      buttonAction = onReorder;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Color(0xFFED1E28).withOpacity(0.1),
        highlightColor: Color(0xFFED1E28).withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
              // --- Header Card ---
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 20,
                    color: Color(0xFFED1E28),
                  ),
                  SizedBox(width: 8),
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
                  Expanded(child: Container()),
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
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Container pembungkus untuk meratakan titik 3 ke kanan
                  Container(
                    width: 30,
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton<String>(
                      color: Colors.white,
                      onSelected: (String value) {
                        print("Pilihan menu: $value");
                        if (value == 'support') {
                          // Navigasi ke halaman support
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
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

              Divider(height: 24, thickness: 1, color: Colors.grey.shade200),

              // --- Detail Produk ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 51,
                    height: 47.17,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15), // Radius 15
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        productImage,
                        width: 38.76,
                        height: 34.92,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "$itemCount Items",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),

              // --- Total Order & Tombol ---
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
                  Expanded(child: Container()),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: buttonAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: status == TransactionStatus.completed
                            ? Colors.white
                            : Color(0xFFED1E28),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Color(0xFFED1E28), width: 1),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Text(
                        buttonText,
                        style: GoogleFonts.poppins(
                          color: status == TransactionStatus.completed
                              ? Color(0xFFED1E28)
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
