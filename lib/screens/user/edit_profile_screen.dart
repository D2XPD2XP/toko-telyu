import 'package:flutter/material.dart';
import 'package:toko_telyu/models/user.dart';
import 'package:toko_telyu/screens/user/edit_address_screen.dart';
import 'package:toko_telyu/screens/user/personal_info_screen.dart';
import 'package:toko_telyu/services/user_services.dart';
import 'package:toko_telyu/widgets/edit_profile_row.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserService _userService = UserService();
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

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      color: Colors.grey[100],
      padding: const EdgeInsets.only(left: 16, top: 20, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arrowIcon = Icon(
      Icons.arrow_forward_ios,
      size: 16,
      color: Colors.grey,
    );

    return Scaffold(
      backgroundColor: Colors.white, // Background utama
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      body: ListView(
        children: [
          SizedBox(height: 30),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade200,
              child: Icon(Icons.person, size: 60, color: Colors.grey.shade400),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                "Change Profile Photo",
                style: TextStyle(
                  color: Color(0xFFED1E28), // Warna merah Anda
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),

          _buildSectionHeader("Profile Info"),

          EditProfileRow(
            label: "Username",
            value: user!.name,
            trailingIcon: arrowIcon,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonalInfo(
                    userId: user!.userId,
                    title: "Username",
                    value: user!.name,
                    onTap: _userService.handleUsername,
                  ),
                ),
              );
              setState(() {
                _loadUser();
              });
            },
          ),

          _buildSectionHeader("Personal Info"),

          EditProfileRow(label: "E-mail", value: user!.email, onTap: () {}),

          EditProfileRow(
            label: "Phone Number",
            value: user?.pnumber ?? " ",
            trailingIcon: arrowIcon,
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonalInfo(
                    userId: user!.userId,
                    title: "Phone Number",
                    value: user?.pnumber,
                    onTap: _userService.handlePnumber,
                  ),
                ),
              );
              setState(() {
                _loadUser();
              });
            },
          ),

          EditProfileRow(
            label: "Address",
            value: user?.address != null
                ? "${user?.address?['street'] ?? ''}, ${user?.address?['postal_code'] ?? ''}"
                : " ",
            trailingIcon: arrowIcon,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditAddressScreen(
                    userId: user!.userId,
                    value: user?.address,
                    onTap: _userService.handleAddress,
                  ),
                ),
              );
              setState(() {
                _loadUser();
              });
            },
          ),
        ],
      ),
    );
  }
}
