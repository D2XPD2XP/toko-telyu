import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatbotInitialMenu extends StatelessWidget {
  final String username;
  final Function(String) onFaqTap;

  const ChatbotInitialMenu({
    Key? key,
    required this.username,
    required this.onFaqTap,
  }) : super(key: key);

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
            "Halo $username, Ada yang bisa TOKTEL bantu?",
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
