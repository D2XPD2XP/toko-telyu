import 'package:flutter/material.dart';
import 'nav_item.dart';
import 'nav_item_model.dart';

class AdminNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  AdminNavBar({super.key, required this.selectedIndex, required this.onTap});

  final Color primaryColor = const Color(0xFFED1E28);

  // Hapus const di sini
  final List<NavItemModel> items = [
    NavItemModel(icon: Icons.receipt_long, label: "Orders"),
    NavItemModel(icon: Icons.inventory, label: "Products"),
    NavItemModel(icon: Icons.category, label: "Categories"),
    NavItemModel(icon: Icons.settings, label: "Settings"),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          return NavItem(
            isActive: selectedIndex == index,
            item: items[index],
            onTap: () => onTap(index),
            activeColor: primaryColor,
          );
        }),
      ),
    );
  }
}
