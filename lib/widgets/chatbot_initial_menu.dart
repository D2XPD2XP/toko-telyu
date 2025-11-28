import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatbotInitialMenu extends StatelessWidget {
  final Function(String) onFaqTap;

  const ChatbotInitialMenu({Key? key, required this.onFaqTap})
    : super(key: key);

  final Color primaryRed = const Color(0xFFED1E28);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bubble Greeting
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            "Halo 'Username', Ada yang bisa TOKTEL bantu?",
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),

        // Card Menu Pilihan
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Silahkan pilih topik yang ingin kamu tanyakan:",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Divider(height: 1),
              _buildFaqItem("Mengapa pesanan saya belum sampai"),
              const Divider(height: 1),
              _buildFaqItem("Status pembayaran saya gagal"),
              const Divider(height: 1),
              _buildFaqItem("Cara membatalkan pesanan saya"),
              const Divider(height: 1),
              _buildFaqItem("Masalah Lainnya"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFaqItem(String text) {
    return ListTile(
      title: Text(
        text,
        style: GoogleFonts.poppins(
          color: primaryRed,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryRed),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      dense: true,
      onTap: () => onFaqTap(text),
    );
  }
}
