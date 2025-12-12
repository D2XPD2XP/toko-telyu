import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toko_telyu/models/chat.dart';

class ChatRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> sendMessage(Chat chat) async {
    await _db.collection('chats').doc(chat.chatId).set(chat.toFirestore());
  }

  Stream<List<Chat>> listenChat(String userId, String adminId) {
    return _db
        .collection('chats')
        .where('sender_id', whereIn: [userId, adminId])
        .where('receiver_id', whereIn: [userId, adminId])
        .orderBy('sent_at')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Chat.fromFirestore(d)).toList());
  }

  Stream<List<String>> getAllUserChatTargets(String adminId) {
    return _db
        .collection('chats')
        .where('sender_id', isEqualTo: adminId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => d.data()['receiver_id'] as String)
              .toSet()
              .toList(),
        );
  }
}
