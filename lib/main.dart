import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:toko_telyu/enums/role.dart';
import 'package:toko_telyu/models/user.dart';
import 'package:toko_telyu/screens/admin/main_admin_screen.dart';
import 'package:toko_telyu/screens/authentication.dart';
import 'package:toko_telyu/screens/user/main_screen.dart';
import 'package:toko_telyu/services/firebase_options.dart';
import 'package:toko_telyu/services/user_services.dart';
import 'package:toko_telyu/widgets/connection_guard.dart';

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
  UserService userService = UserService();
  User? user;
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
      user = await userService.loadUser();
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
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFFED1E28)),
          ),
        ),
      );
    }

    if (!_isLoggedIn) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Authentication(),
        builder: (context, child) => ConnectionGuard(child: child!),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: user!.role == RoleEnum.USER ? MainScreen() : MainAdminScreen(),
      builder: (context, child) => ConnectionGuard(child: child!),
    );
  }
}
