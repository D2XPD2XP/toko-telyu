import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/services/auth_services.dart';
import 'package:toko_telyu/widgets/auth_button.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() {
    return _SignupPage();
  }
}

class _SignupPage extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final AuthServices _authServices = AuthServices();
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logoaja.png', width: 240),
              Text(
                'Sign Up',
                style: GoogleFonts.poppins(
                  fontSize: 37,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        label: Text(
                          'Username',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        label: Text(
                          'Email',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      obscureText: _obscure1,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        label: Text(
                          'Password',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                          ),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure1 = !_obscure1),
                          icon: Icon(
                            _obscure1 == false
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      obscureText: _obscure2,
                      controller: _confirmController,
                      decoration: InputDecoration(
                        label: Text(
                          'Confirm Password',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                          ),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure2 = !_obscure2),
                          icon: Icon(
                            _obscure2 == false
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              AuthButton(
                text: "Sign Up",
                type: "login",
                onTap: () async {
                  await _authServices.register(
                    context,
                    _usernameController,
                    _emailController,
                    _passwordController,
                    _confirmController,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
