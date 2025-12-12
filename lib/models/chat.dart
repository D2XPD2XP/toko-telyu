import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toko_telyu/enums/role.dart';

class Chat {
  String chatId;
  String senderId;
  String receiverId;
  String message;
  RoleEnum senderRole;
  DateTime sentAt;

  Chat({
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.senderRole,
    required this.sentAt,
  });

  factory Chat.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Chat(
      chatId: doc.id,
      senderId: data['sender_id'],
      receiverId: data['receiver_id'],
      message: data['message'],
      senderRole: RoleEnum.values
          .firstWhere((e) => e.toString() == data['sender_role']),
      sentAt: (data['sent_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'sender_role': senderRole.toString(),
      'sent_at': sentAt,
    };
  }
}

