import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toko_telyu/enums/role.dart';
import 'package:uuid/uuid.dart';

class User {
  String _userId;
  String _email;
  String _name;
  String _pnumber;
  Map<String, dynamic> _address;
  String _password;
  RoleEnum _role;
  Cart? _cart;
  Wishlist? _wishlist;

  User(
    this._userId,
    this._email,
    this._name,
    this._pnumber,
    this._address,
    this._password, {
    RoleEnum role = RoleEnum.USER,
    Cart? cart,
    Wishlist? wishlist,
  }) : _role = role,
       _cart = cart,
       _wishlist = wishlist;

  factory User.create({
    required String email,
    required String name,
    required String pnumber,
    required Map<String, dynamic> address,
    required String password,
  }) {
    final uuid = const Uuid().v4();
    return User(uuid, email, name, pnumber, address, password);
  }

  String getUserId() => _userId;
  String getName() => _name;
  String getEmail() => _email;
  RoleEnum getRole() => _role;
  Cart? getCart() => _cart;
  Wishlist? getWishlist() => _wishlist;

  Map<String, dynamic> toFirestore() {
    return {
      'email': _email,
      'name': _name,
      'pnumber': _pnumber,
      'address': _address,
      'password': _password,
      'role': _role.toString().split('.').last,
    };
  }

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return User(
      doc.id,
      data['email'] ?? '',
      data['name'] ?? '',
      data['pnumber'] ?? '',
      Map<String, dynamic>.from(data['address'] ?? {}),
      data['password'] ?? '',
      role: _stringToRole(data['role'] ?? 'USER'),
    );
  }

  static RoleEnum _stringToRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return RoleEnum.ADMIN;
      default:
        return RoleEnum.USER;
    }
  }
}
