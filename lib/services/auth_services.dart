import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:toko_telyu/screens/user/homepage.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();
final _secureStorage = FlutterSecureStorage();
final _firestore = FirebaseFirestore.instance;

const _kSessionTokenKey = 'session_token';
const _kUserIdKey = 'user_id';

String hashPassword(String pass) {
  return sha256.convert(utf8.encode(pass)).toString();
}

void login(BuildContext context) async {
  final sessionToken = _uuid.v4();
  final userId = "001";

  await _secureStorage.write(key: _kSessionTokenKey, value: sessionToken);
  await _secureStorage.write(key: _kUserIdKey, value: userId);

  if (!context.mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => Homepage()),
  );
}

void register(BuildContext context, TextEditingController usernameController, TextEditingController emailController, TextEditingController passwordController, TextEditingController confirmController) async {
  final username = usernameController.text.trim();
  final emailIsValid = checkEmail(emailController.text.trim());
  final password = passwordController.text;
  final confirm = password == confirmController.text;

  if (username.isEmpty || !emailIsValid || !confirm) {
    
  }

}

bool checkEmail(String email) {
  for (int i = 0; i < email.length; i++){
    if (email[i] == '@') {
      return true;
    }
  }
  return false;
}
