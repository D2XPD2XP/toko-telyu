import 'package:flutter/material.dart';
import 'package:toko_telyu/models/user.dart';
import 'package:toko_telyu/services/auth_services.dart';
import 'package:toko_telyu/services/user_services.dart';
import '../../widgets/profile_menu_item.dart';
import 'package:toko_telyu/screens/user/edit_profile_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthServices _authServices = AuthServices();
  final UserService _userService = UserService();
  String? userId;
  User? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    user = await _userService.loadUser();
    setState(() {});
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 2,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color.fromARGB(255, 180, 180, 180),
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                SizedBox(width: 23),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15),
                    Text(
                      user!.name,
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
                      user!.email,
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
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
              _userService.loadUser();
            },
          ),

          ProfileMenuItem(
            title: "Log Out",
            icon: Icons.logout,
            onTap: () {
              _authServices.logout(context);
            },
            textColor: Color(0xFFED1E28),
            iconColor: Color(0xFFED1E28),
          ),
        ],
      ),
    );
  }
}
