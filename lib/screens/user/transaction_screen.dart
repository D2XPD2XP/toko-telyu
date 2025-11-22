import 'package:flutter/material.dart';
import 'package:toko_telyu/enums/shipping_status.dart';
// Ganti toko_telyu dengan nama project Anda
import 'package:toko_telyu/widgets/transaction_card.dart';
import 'package:toko_telyu/screens/user/order_detail_screen.dart';
import 'package:toko_telyu/screens/user/track_order_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String? _selectedProduct = "All Products";
  String? _selectedDate = "All Dates";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Background abu-abu muda
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Tinggi AppBar
        child: AppBar(
          backgroundColor: Colors.grey[100],
          elevation: 0,
          automaticallyImplyLeading: false, // Menghilangkan tombol back
          titleSpacing: 16,
          title: _buildSearchBar(),
          actions: [
            IconButton(
              icon: Icon(Icons.chat_bubble_outline, color: Color(0xFFED1E28)),
              onPressed: () {
                /* Aksi chat */
              },
            ),
            IconButton(
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: Color(0xFFED1E28),
              ),
              onPressed: () {
                /* Aksi keranjang */
              },
            ),
            SizedBox(width: 8),
          ],
        ),
      ),

      body: ListView(
        children: [
          _buildFilterBar(),

          TransactionCard(
            status: TransactionStatus.outForDelivery,
            date: "04 October 2025",
            productImage: "assets/seragam_merah_telkom.png",
            productName: "Seragam Telkom - Merah",
            itemCount: 2,
            orderTotal: 300000.00,
            onTrackOrder: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrackOrderScreen(),
                ),
              );
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderDetailScreen(),
                ),
              );
            },
          ),

          TransactionCard(
            status: TransactionStatus.completed,
            date: "03 October 2025",
            productImage: "assets/seragam_merah_telkom.png",
            productName: "Seragam Telkom - Merah",
            itemCount: 1,
            orderTotal: 150000.00,
            onReorder: () {
              print("Reorder 1");
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderDetailScreen(),
                ),
              );
            },
          ),

          TransactionCard(
            status: TransactionStatus.completed,
            date: "01 October 2025",
            productImage: "assets/seragam_merah_telkom.png",
            productName: "Seragam Telkom - Merah",
            itemCount: 3,
            orderTotal: 450000.00,
            onReorder: () {
              print("Reorder 2");
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderDetailScreen(),
                ),
              );
            },
          ),

          SizedBox(height: 20), 
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "SEARCH TRANSACTION",
          hintStyle: TextStyle(color: Colors.black, fontSize: 10),
          prefixIcon: Icon(Icons.search, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 2),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _buildDropdownButton(_selectedProduct, [
            "All Products",
            "Completed",
            "Pending",
          ]),
          SizedBox(width: 10),
          _buildDropdownButton(_selectedDate, [
            "All Dates",
            "Last 30 Days",
            "Last 90 Days",
          ]),
        ],
      ),
    );
  }

  Widget _buildDropdownButton(String? value, List<String> items) {
    return Expanded(
      child: Container(
        height: 35,
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, size: 20),
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                if (items.contains("All Products")) {
                  _selectedProduct = newValue;
                } else {
                  _selectedDate = newValue;
                }
              });
            },
          ),
        ),
      ),
    );
  }
}
