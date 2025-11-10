import 'package:flutter/material.dart';
import 'package:toko_telyu/services/auth_services.dart';
import 'package:toko_telyu/services/user_services.dart';
// Impor widget yang baru saja kita buat
import '../../widgets/profile_menu_item.dart';
import 'package:toko_telyu/screens/user/edit_profile_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthServices _authServices = AuthServices();
  int _selectedIndex = 3; 

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        title: Text(
          "My Activity",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[100], 
        elevation: 0, 
        centerTitle: true,
      ),

      body: ListView(
        children: [
          SizedBox(height: 20),

          Container(
            height: 155,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFED1E28), 
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white60,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                SizedBox(width: 23),
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

          ProfileMenuItem(
            title: "Edit Profile",
            icon: Icons.person_outline,
            onTap: () {
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
            icon: Icons.logout,
            onTap: () {
              _authServices.logout(context);
            },
            textColor: Color(0xFFED1E28),
            iconColor: Color(
              0xFFED1E28,
            ), 
          ),
        ],
      ),
    );
  }
}
