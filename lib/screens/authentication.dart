import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/widgets/auth_button.dart';

class Authentication extends StatelessWidget {
  const Authentication({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 150),
            Image.asset(
              'assets/logoaja.png',
              width: 240,
            ),
            Text(
              'Hello!',
              style: GoogleFonts.poppins(
                fontSize: 37,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Welcome to Toko Telyu',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 85,),
            AuthButton(text: "Login", type: "login"),
            SizedBox(height: 15),
            AuthButton(text: "Sign Up", type: "signup")
          ],
        ),
      ),
    );
  }
}