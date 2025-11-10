import 'package:toko_telyu/enums/role.dart';
import 'package:toko_telyu/models/cart.dart';
import 'package:toko_telyu/models/wishlist.dart';

class User {
  String _userId;
  String _email;
  String _name;
  String? _pnumber;
  Map<String, dynamic>? _address;
  String _password;
  RoleEnum _role;
  Cart? _cart;
  Wishlist? _wishlist;

  User(
    this._userId,
    this._email,
    this._name,
    this._password, {
    String? pnumber,
    Map<String, dynamic>? address,
    RoleEnum role = RoleEnum.USER,
    Cart? cart,
    Wishlist? wishlist,
  })  : _pnumber = pnumber,
        _address = address,
        _role = role,
        _cart = cart,
        _wishlist = wishlist;

  // Getters
  String get userId => _userId;
  String get email => _email;
  String get name => _name;
  String? get pnumber => _pnumber;
  Map<String, dynamic>? get address => _address;
  String get password => _password;
  RoleEnum get role => _role;
  Cart? get cart => _cart;
  Wishlist? get wishlist => _wishlist;

  // Setters
  void setUserId(String id) => _userId = id;
  void setEmail(String email) => _email = email;
  void setName(String name) => _name = name;
  void setPassword(String pass) => _password = pass;
  void setPnumber(String? number) => _pnumber = number;
  void setAddress(Map<String, dynamic>? address) => _address = address;
  void setRole(RoleEnum role) => _role = role;
  void setCart(Cart? cart) => _cart = cart;
  void setWishlist(Wishlist? wishlist) => _wishlist = wishlist;

  // Firestore conversion
  factory User.fromFirestore(Map<String, dynamic> data, String userId) {
    return User(
      userId,
      data['email'],
      data['name'],
      data['password'],
      pnumber: data['pnumber'],
      address: data['address'],
      role: RoleEnum.values.firstWhere(
        (e) => e.toString() == data['role'],
        orElse: () => RoleEnum.USER,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': _email,
      'name': _name,
      'password': _password,
      'pnumber': _pnumber,
      'address': _address,
      'role': _role.toString(),
    };
  }
}