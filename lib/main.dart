import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:toko_telyu/screens/authentication.dart';
import 'package:toko_telyu/screens/user/account_screen.dart';
import 'package:toko_telyu/screens/user/homepage.dart';
import 'package:toko_telyu/screens/user/main_screen.dart';
import 'package:toko_telyu/services/firebase_options.dart';

final _secureStorage = FlutterSecureStorage();

const _kSessionTokenKey = 'session_token';
const _kUserIdKey = 'user_id';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() {
    return _App();
  }
}

class _App extends State<App> {
  bool _checking = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _tryRestoreSession();
  }

  Future<void> _tryRestoreSession() async {
    setState(() {
      _checking = true;
    });

    final token = await _secureStorage.read(key: _kSessionTokenKey);
    final userId = await _secureStorage.read(key: _kUserIdKey);

    if (token != null && userId != null) {
      setState(() {
        _isLoggedIn = true;
      });
    } else {
      await _secureStorage.delete(key: _kSessionTokenKey);
      await _secureStorage.delete(key: _kUserIdKey);
    }

    setState(() {
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _isLoggedIn ? MainScreen() : Authentication(),
    );
  }
}
