import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color borderColor;

  // Bagian ini (constructor) adalah yang paling penting
  const ProfileMenuItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    // Kita tambahkan parameter baru di sini:
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black, // <-- Parameter ini harus ada
    this.iconColor = Colors.black54, // <-- Parameter ini harus ada
    this.borderColor = const Color(0xFFE0E0E0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor, // Gunakan variabelnya
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor), // Gunakan variabelnya
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor), // Gunakan variabelnya
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor, // Gunakan variabelnya
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: iconColor, // Gunakan variabelnya
        ),
        onTap: onTap,
      ),
    );
  }
}
