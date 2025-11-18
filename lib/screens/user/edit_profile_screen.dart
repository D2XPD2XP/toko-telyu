import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:toko_telyu/models/user.dart';
import 'package:toko_telyu/screens/user/edit_address_screen.dart';
import 'package:toko_telyu/screens/user/personal_info_screen.dart';
import 'package:toko_telyu/services/user_services.dart';
import 'package:toko_telyu/widgets/custom_dialog.dart';
import 'package:toko_telyu/widgets/edit_profile_row.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserService _userService = UserService();
  String? userId;
  User? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final storage = const FlutterSecureStorage();
    userId = await storage.read(key: 'user_id');

    if (userId != null) {
      user = await _userService.getUser(userId!);
      setState(() {});
    }
  }

  Future<void> _handleUsername(BuildContext context, String username) async {
    if (username.isEmpty) {
      return showDialog(
        context: context,
        builder: (ctx) => CustomDialog(
          ctx: ctx,
          message: 'Please make sure a valid username',
        ),
      );
    }

    Map<String, dynamic> data = {"username": username};
    await _userService.updateUser(userId!, data);

    if (!context.mounted) return;
    Navigator.pop(context);

    setState(() {
      _loadUser();
    });
  }

  Future<void> _handlePnumber(BuildContext context, String number) async {
    if (num.tryParse(number.trim()) == null || number.length < 11) {
      return showDialog(
        context: context,
        builder: (ctx) => CustomDialog(
          ctx: ctx,
          message: 'Please make sure a valid phone number',
        ),
      );
    }

    Map<String, dynamic> data = {"pnumber": number};
    await _userService.updateUser(userId!, data);

    if (!context.mounted) return;
    Navigator.pop(context);

    setState(() {
      _loadUser();
    });
  }

  Future<void> _handleAddress(
    BuildContext context,
    Map<String, dynamic> address,
  ) async {
    if ((address["province"]?.trim().isEmpty ?? true) ||
        (address["city"]?.trim().isEmpty ?? true) ||
        (address["district"]?.trim().isEmpty ?? true) ||
        (address["postal_code"]?.trim().isEmpty ?? true) || 
        (address["street"]?.trim().isEmpty ?? true)) {
      return showDialog(
        context: context,
        builder: (ctx) =>
            CustomDialog(ctx: ctx, message: 'Please make sure a valid address'),
      );
    }

    Map<String, dynamic> data = {"address": address};
    await _userService.updateUser(userId!, data);

    if (!context.mounted) return;
    Navigator.pop(context);

    setState(() {
      _loadUser();
    });
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
    final copyIcon = Icon(Icons.copy_outlined, size: 20, color: Colors.grey);

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
              onPressed: () {
                print("Ganti foto profil");
              },
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
            valueColor: Colors.grey,
            trailingIcon: arrowIcon,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonalInfo(
                    title: "Username",
                    value: user!.name,
                    onTap: _handleUsername,
                  ),
                ),
              );
            },
          ),

          _buildSectionHeader("Personal Info"),

          EditProfileRow(label: "E-mail", value: user!.email, onTap: () {}),

          EditProfileRow(
            label: "Phone Number",
            value: user?.pnumber ?? " ",
            trailingIcon: arrowIcon,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonalInfo(
                    title: "Phone Number",
                    value: user?.pnumber,
                    onTap: _handlePnumber,
                  ),
                ),
              );
            },
          ),

          EditProfileRow(
            label: "Address",
            value: user?.address != null
                ? "${user?.address?['street'] ?? ''}, ${user?.address?['postal_code'] ?? ''}"
                : " ",
            trailingIcon: arrowIcon,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditAddressScreen(
                    value: user?.address,
                    onTap: _handleAddress,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
