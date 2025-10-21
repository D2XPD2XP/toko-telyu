import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/widgets/auth_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            Image.asset('assets/logoaja.png', width: 240),
            Text(
              'Login',
              style: GoogleFonts.poppins(
                fontSize: 37,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 85),
            AuthButton(text: "Login", type: "login"),
          ],
        ),
      ),
    );
  }
}
