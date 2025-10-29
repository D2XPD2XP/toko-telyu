import 'package:flutter/material.dart';
// Impor widget yang baru saja kita buat
import '../../widgets/profile_menu_item.dart';
import 'package:toko_telyu/screens/user/edit_profile_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _selectedIndex = 3; // 3 = index untuk "Account"

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Tambahkan navigasi di sini jika perlu
    // cth: if (index == 0) Navigator.pushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Warna background abu-abu muda
      // ====== APP BAR ======
      appBar: AppBar(
        title: Text(
          "My Activity",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[100], // Samakan dengan background body
        elevation: 0, // Hilangkan bayangan
        centerTitle: true,
      ),

      // ====== BODY ======
      body: ListView(
        children: [
          SizedBox(height: 20),

          // --- Kartu Profil Merah ---
          Container(
            height: 155,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFED1E28), // Warna merah (sesuaikan dari Figma)
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                // Foto Profil
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white60,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                  // Jika punya gambar:
                  // backgroundImage: NetworkImage('URL_GAMBAR_ANDA'),
                ),
                SizedBox(width: 23),
                // Nama dan Email
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15),
                    Text(
                      "Aiman Ibnu",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Personal",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      "aimanibnu1@gmail.com",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          // --- Menu Item (Menggunakan Widget Kustom) ---
          ProfileMenuItem(
            title: "Edit Profile",
            icon: Icons.person_outline,
            onTap: () {
              // INI ADALAH KODE YANG MEMBUATNYA MUNCUL
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),

          ProfileMenuItem(
            title: "Log Out",
            icon: Icons.logout, // Ikon dari Figma (sesuaikan)
            onTap: () {
              print("Log Out diklik!");
              // Logika untuk Log Out
            },
            textColor: Color(0xFFED1E28), // Teks jadi merah
            iconColor: Color(
              0xFFED1E28,
            ), // Ikon (leading & trailing) jadi merah
          ),
        ],
      ),
    );
  }
}
