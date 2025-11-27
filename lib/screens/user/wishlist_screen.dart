import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/widgets/wishlist_card.dart';
import 'package:toko_telyu/widgets/top_navbar.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Wishlist",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xFFED1E28),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TopNavbar(onChanged: () {}, text: "Cari Produk"),
          const SizedBox(height: 20),

          // Header Jumlah Item
          Text(
            "2 Item",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),

          // Kartu Produk 1
          const WishlistCard(
            productName: "Seragam Telkom - Merah",
            productImage: "assets/seragam_merah_telkom.png",
            variant: "S",
            price: 150000,
          ),

          // Kartu Produk 2
          const WishlistCard(
            productName: "Seragam Telkom - Merah",
            productImage: "assets/seragam_merah_telkom.png",
            variant: "M",
            price: 150000,
          ),
        ],
      ),
    );
  }
}
