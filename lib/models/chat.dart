import 'package:toko_telyu/enums/role.dart';
import 'package:toko_telyu/models/user.dart';

class Chat {
  String _chatId;
  User _customer;
  User _admin;
  String _message;
  RoleEnum _senderRole;
  DateTime _sentAt;

  Chat(
    this._chatId,
    this._customer,
    this._admin,
    this._message,
    this._senderRole,
    this._sentAt,
  );

  // Getters
  String getChatId() => _chatId;
  User getCustomer() => _customer;
  User getAdmin() => _admin;
  String getMessage() => _message;
  RoleEnum getSenderRole() => _senderRole;
  DateTime getSentAt() => _sentAt;

  // Setters
  void setChatId(String chatId) {
    _chatId = chatId;
  }

  void setCustomer(User customer) {
    _customer = customer;
  }

  void setAdmin(User admin) {
    _admin = admin;
  }

  void setMessage(String message) {
    _message = message;
  }

  void setSenderRole(RoleEnum role) {
    _senderRole = role;
  }

  void setSentAt(DateTime sentAt) {
    _sentAt = sentAt;
  }
}
