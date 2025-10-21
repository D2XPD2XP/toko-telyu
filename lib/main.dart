import 'package:flutter/material.dart';
import 'package:toko_telyu/screens/authentication.dart';
import 'package:toko_telyu/screens/homepage.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Authentication(),
    );
  }
}