import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus { pending, success, failed, expired, refunded }

class Payment {
  String paymentId;
  String method;
  PaymentStatus status;
  int amount;
  DateTime createdAt;

  Payment({
    required this.paymentId,
    required this.method,
    required this.status,
    required this.amount,
    required this.createdAt,
  });

  factory Payment.fromFirestore(Map<String, dynamic> data, String id) {
    return Payment(
      paymentId: id,
      method: data['method'] ?? "",
      status: PaymentStatus.values.byName(data['status'] ?? "pending"),
      amount: data['amount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "method": method,
      "status": status.name,
      "amount": amount,
      "createdAt": createdAt,
    };
  }
}
