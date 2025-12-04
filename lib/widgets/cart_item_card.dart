import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';

class CartItemCard extends StatelessWidget {
  final String productName;
  final String productImage;
  final String variant; // Contoh: "S"
  final double price;
  final int quantity;
  final bool isSelected;
  final VoidCallback onCheckToggle;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const CartItemCard({
    Key? key,
    required this.productName,
    required this.productImage,
    required this.variant,
    required this.price,
    required this.quantity,
    required this.isSelected,
    required this.onCheckToggle,
    required this.onAdd,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- CHECKBOX ---
          InkWell(
            onTap: onCheckToggle,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 12,
                top: 25,
              ), // Align vertical center
              child: Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                color: isSelected ? const Color(0xFFED1E28) : Colors.grey,
                size: 24,
              ),
            ),
          ),

          // --- GAMBAR PRODUK ---
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(productImage, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),

          // --- INFO PRODUK ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Varian (Kotak Kecil)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    variant,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Harga
                FormattedPrice(
                  price: price,
                  size: 13,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),

          // --- QUANTITY SELECTOR (Pojok Kanan Bawah) ---
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 55), // Spacer agar sejajar bawah
              Container(
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tombol Kurang / Hapus
                    InkWell(
                      onTap: onRemove,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          quantity == 1 ? Icons.delete_outline : Icons.remove,
                          size: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),

                    // Angka Jumlah
                    Text(
                      "$quantity",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Tombol Tambah
                    InkWell(
                      onTap: onAdd,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.add, size: 14, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
