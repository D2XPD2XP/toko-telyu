import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _userCollection =>
      _firestore.collection('user');

  Future<void> createUser(User user) async {
    await _userCollection.doc(user.userId).set(user.toFirestore());
  }

  Future<User?> getUserById(String userId) async {
    final doc = await _userCollection.doc(userId).get();
    if (!doc.exists) return null;
    return User.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    await _userCollection.doc(userId).update(updates);
  }

  Future<void> deleteUser(String userId) async {
    await _userCollection.doc(userId).delete();
  }

  Future<List<User>> getAllUsers() async {
    final snapshot = await _userCollection.get();
    return snapshot.docs
        .map((doc) => User.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}
