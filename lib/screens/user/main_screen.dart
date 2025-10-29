import 'package:flutter/material.dart';
import 'package:toko_telyu/screens/user/account_screen.dart';
import 'package:toko_telyu/screens/user/homepage.dart';
import 'package:toko_telyu/screens/user/transaction_screen.dart';
// Ganti nama_project_anda dengan nama project Anda (toko_telyu)

// Kita buat widget placeholder untuk tab yang belum ada
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Halaman Favorites"));
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Mulai dari tab Home (index 0)

  // Daftar semua halaman utama Anda
  static const List<Widget> _widgetOptions = <Widget>[
    Homepage(), // Index 0
    FavoritesScreen(), // Index 1
    TransactionScreen(), // Index 2
    AccountScreen(), // Index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body-nya akan berganti sesuai tab yang dipilih
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),

      // Bottom Navigation Bar-nya kita taruh di sini
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transaction',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFE53935), // Warna merah saat aktif
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
