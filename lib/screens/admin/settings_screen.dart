import 'package:flutter/material.dart';
import 'package:toko_telyu/services/auth_services.dart';
import 'shipping_area_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // -----------------------------------
  // COLORS
  // -----------------------------------
  Color get primaryColor => const Color(0xFFED1E28);

  // -----------------------------------
  // MENU ITEM WIDGET
  // -----------------------------------
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
    Color? iconBg,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .02),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildIcon(icon, iconBg),
            const SizedBox(width: 16),
            _buildTitle(title),
            Icon(Icons.chevron_right, size: 22, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  // -----------------------------------
  // ICON WRAPPER
  // -----------------------------------
  Widget _buildIcon(IconData icon, Color? bgColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.grey[100],
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 22, color: primaryColor),
    );
  }

  // -----------------------------------
  // TITLE TEXT
  // -----------------------------------
  Widget _buildTitle(String title) {
    return Expanded(
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }

  // -----------------------------------
  // HEADER TEXT
  // -----------------------------------
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // -----------------------------------
  // BUILD
  // -----------------------------------
  @override
  Widget build(BuildContext context) {
    AuthServices authServices = AuthServices();
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0.6,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("Store Settings"),

          _buildMenuItem(
            icon: Icons.location_on_rounded,
            title: "Shipping Area Management",
            iconBg: primaryColor.withValues(alpha: .12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShippingAreaScreen()),
              );
            },
          ),

          _buildMenuItem(
            icon: Icons.logout_rounded,
            title: "Logout",
            iconBg: Colors.red.withValues(alpha: .12),
            onTap: () {
              authServices.logout(context);
            },
          ),
        ],
      ),
    );
  }
}
