import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({
    super.key,
    required this.userId,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final Future<void> Function(BuildContext, String, String) onTap;
  final String userId;
  final String title;
  final String? value;

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.value ?? "");
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Warna utama sesuai desain
    const Color primaryRed = Color(0xFFED1E28);

    return Scaffold(
      backgroundColor: Colors.white, // Background putih bersih
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Tanpa bayangan di AppBar sesuai gambar referensi
        titleSpacing: 0,
        leading: IconButton(
          // Gunakan arrow_back (panah standar) atau arrow_back_ios sesuai selera konsistensi
          // Berdasarkan gambar referensi WhatsApp Image, terlihat seperti arrow_back biasa
          // Tapi untuk konsistensi dengan Checkout, kita bisa pakai arrow_back_ios
          // Mari kita pakai arrow_back untuk mirip persis gambar referensi,
          // ATAU ganti ke arrow_back_ios jika ingin konsisten dengan Checkout.
          // Sesuai request "arrow back konsisten", saya pakai arrow_back_ios.
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title, // "Username" atau "Phone Number"
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // --- INPUT FIELD ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _textController,
                keyboardType: widget.title == "Phone Number"
                    ? TextInputType.phone
                    : TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.title, // Placeholder
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
              ),
            ),

            const SizedBox(height: 24), // Jarak antara input dan tombol
            // --- TOMBOL SAVE ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onTap(context, widget.userId, _textController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed, // Warna Merah Penuh
                  foregroundColor: Colors.white, // Warna Teks Putih
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Sudut melengkung
                  ),
                ),
                child: Text(
                  'Save',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
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
