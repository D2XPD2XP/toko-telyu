import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/widgets/cart_item_card.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';
import 'package:toko_telyu/screens/user/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Color primaryRed = const Color(0xFFED1E28);
  final Color bgGrey = const Color(0xFFF5F5F5);

  // State Dummy untuk Slicing
  bool isAllSelected = false;

  // Contoh data item cart
  List<Map<String, dynamic>> cartItems = [
    {
      "id": 1,
      "name": "Seragam Telkom - Merah",
      "image": "assets/seragam_merah_telkom.png",
      "variant": "S",
      "price": 150000.0,
      "quantity": 1,
      "selected": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    double totalPrice = 0;
    int totalSelectedItems = 0;
    for (var item in cartItems) {
      if (item['selected']) {
        totalPrice += (item['price'] * item['quantity']);
        totalSelectedItems += 1;
      }
    }

    return Scaffold(
      backgroundColor: bgGrey,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Cart",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border, color: Colors.grey),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: Column(
        children: [
          // --- HEADER SELEKSI ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: bgGrey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$totalSelectedItems Selected Items",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                InkWell(
                  onTap: () {
                    // Logika Hapus
                  },
                  child: Text(
                    "Remove",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryRed,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return CartItemCard(
                  productName: item['name'],
                  productImage: item['image'],
                  variant: item['variant'],
                  price: item['price'],
                  quantity: item['quantity'],
                  isSelected: item['selected'],
                  onCheckToggle: () {
                    setState(() {
                      item['selected'] = !item['selected'];
                    });
                  },
                  onAdd: () {
                    setState(() {
                      item['quantity']++;
                    });
                  },
                  onRemove: () {
                    setState(() {
                      if (item['quantity'] > 1) {
                        item['quantity']--;
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Checkbox All
            InkWell(
              onTap: () {
                setState(() {
                  isAllSelected = !isAllSelected;
                  for (var item in cartItems) {
                    item['selected'] = isAllSelected;
                  }
                });
              },
              child: Row(
                children: [
                  Icon(
                    isAllSelected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: isAllSelected ? primaryRed : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "All",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Total Price
            FormattedPrice(
              price: totalPrice,
              size: 16,
              fontWeight: FontWeight.bold,
            ),

            const SizedBox(width: 15),

            // Button Buy
            SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  if (totalSelectedItems > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheckoutScreen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Pilih item terlebih dahulu"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: Text(
                  "Buy($totalSelectedItems)",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
