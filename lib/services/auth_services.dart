import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:toko_telyu/enums/role.dart';
import 'package:toko_telyu/screens/admin/main_admin_screen.dart';
import 'package:toko_telyu/screens/authentication.dart';
import 'package:toko_telyu/screens/user/main_screen.dart';
import 'package:toko_telyu/services/fcm_service.dart';
import 'package:toko_telyu/services/notification_permission.dart';
import 'package:toko_telyu/services/user_services.dart';
import 'package:uuid/uuid.dart';

class AuthServices {
  final _uuid = Uuid();
  final _secureStorage = FlutterSecureStorage();
  final _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  String hashPassword(String pass) {
    return sha256.convert(utf8.encode(pass)).toString();
  }

  Future<void> login(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) async {
    final users = await _userService.getAllUsers();
    final hashed = hashPassword(passwordController.text);

    try {
      final user = users.firstWhere(
        (u) => u.email == emailController.text.trim() && u.password == hashed,
      );

      final token = _uuid.v4();

      await _secureStorage.write(key: 'session_token', value: token);
      await _secureStorage.write(key: 'user_id', value: user.userId);

      await NotificationPermission.request();
      await FcmService.setup(user.userId);

      if (user.role == RoleEnum.USER) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainAdminScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Invalid Input!",
            style: TextStyle(
              color: Color(0xFFED1E28),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "Please make sure a valid email and password",
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(
                    const Color(0xFFED1E28),
                  ),
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                child: Text("OK"),
              ),
            ),
          ],
        ),
      ); // user tidak ditemukan atau password salah
    }
  }

  Future<void> register(
    BuildContext context,
    TextEditingController usernameController,
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController confirmController,
  ) async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final emailIsValid = checkEmail(emailController.text.trim());
    final password = passwordController.text;
    final confirm = password == confirmController.text;

    final existing = await _firestore
        .collection('user')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (username.isEmpty ||
        !emailIsValid ||
        !confirm ||
        existing.docs.isNotEmpty) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Invalid Input!",
            style: TextStyle(
              color: Color(0xFFED1E28),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "Please make sure a valid username, email, and password",
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(
                    const Color(0xFFED1E28),
                  ),
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                child: Text("OK"),
              ),
            ),
          ],
        ),
      );
    }

    final hashed = hashPassword(password);

    await _userService.createUser(
      email: email,
      name: username,
      password: hashed,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Signup Success!",
          style: TextStyle(
            color: Colors.lightGreen,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          "Your account has been created",
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Authentication()),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.white),
                foregroundColor: WidgetStateProperty.all(Colors.lightGreen),
              ),
              child: Text(
                "LOGIN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await _secureStorage.deleteAll();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Authentication()),
        (route) => false,
      );
    }
  }

  bool checkEmail(String email) {
    for (int i = 0; i < email.length; i++) {
      if (email[i] == '@') {
        return true;
      }
    }
    return false;
  }
}
