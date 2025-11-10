import 'package:flutter/material.dart';
import 'package:toko_telyu/widgets/edit_profile_row.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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
            label: "Name",
            value: "Aiman Ibnu",
            trailingIcon: arrowIcon,
            onTap: () {
              print("Pindah ke halaman ganti nama");
            },
          ),

          EditProfileRow(
            label: "Username",
            value: "Buat Username yang unik",
            valueColor: Colors.grey,
            trailingIcon: arrowIcon,
            onTap: () {
              print("Pindah ke halaman ganti username");
            },
          ),

          _buildSectionHeader("Personal Info"),

          EditProfileRow(
            label: "User ID",
            value: "12345678",
            trailingIcon: copyIcon, // Ikon copy
            onTap: () {
              print("User ID disalin!");
              // Logika copy ke clipboard di sini
            },
          ),

          EditProfileRow(
            label: "E-mail",
            value: "Aimanibnu1@gmail.com",
            trailingIcon: arrowIcon,
            onTap: () {
              print("Pindah ke halaman ganti email");
            },
          ),

          EditProfileRow(
            label: "Phone Number",
            value: "6282238222281",
            trailingIcon: arrowIcon,
            onTap: () {
              print("Pindah ke halaman ganti no. HP");
            },
          ),

          EditProfileRow(
            label: "Gender",
            value: "Pria",
            trailingIcon: arrowIcon,
            onTap: () {
              print("Pindah ke halaman ganti gender");
            },
          ),

          EditProfileRow(
            label: "Date of Birth",
            value: "05 Oktober 2004",
            trailingIcon: arrowIcon,
            onTap: () {
              print("Pindah ke halaman ganti tgl lahir");
            },
          ),

          EditProfileRow(
            label: "Address",
            value: "Permata Buah Batu Blok i",
            trailingIcon: arrowIcon,
            onTap: () {
              print("Pindah ke halaman ganti alamat");
            },
          ),
        ],
      ),
    );
  }
}
