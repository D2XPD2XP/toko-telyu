import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toko_telyu/screens/authentication.dart';
import 'package:toko_telyu/screens/user/homepage.dart';
import 'package:toko_telyu/screens/user/account_screen.dart';
import 'package:toko_telyu/screens/user/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const MainScreen());
  }
}
