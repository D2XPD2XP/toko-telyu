import 'package:flutter/material.dart';
import 'package:toko_telyu/screens/admin/category_screen.dart';
import 'package:toko_telyu/screens/admin/chat_screen.dart';
import 'package:toko_telyu/screens/admin/orders_screen.dart';
import 'package:toko_telyu/screens/admin/product_screen.dart';
import 'package:toko_telyu/screens/admin/settings_screen.dart';
import 'package:toko_telyu/widgets/admin/navigation/admin_nav_bar.dart';

class MainAdminScreen extends StatefulWidget {
  const MainAdminScreen({super.key});

  @override
  State<MainAdminScreen> createState() => _MainAdminScreenState();
}

class _MainAdminScreenState extends State<MainAdminScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    OrdersScreen(),
    ProductScreen(),
    CategoryScreen(),
    ChatScreen(),
    SettingsScreen(),
  ];

  void _handleNavTap(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          _pages[_selectedIndex],

          // Floating Navbar
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: AdminNavBar(
                selectedIndex: _selectedIndex,
                onTap: _handleNavTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
