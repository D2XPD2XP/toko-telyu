import 'package:toko_telyu/enums/payment_status.dart';

PaymentStatus _parsePaymentStatus(String? status) {
  switch (status) {
    case "pending":
      return PaymentStatus.pending;
    case "completed":
      return PaymentStatus.completed;
    case "failed":
      return PaymentStatus.failed;
    default:
      return PaymentStatus.pending;
  }
}

class PaymentModel {
  String paymentId;
  String orderId;
  String midtransTransactionId;
  String paymentMethod;
  PaymentStatus paymentStatus;
  int amount;
  String? paymentUrl;
  Map<String, dynamic> responseJson;

  PaymentModel({
    required this.paymentId,
    required this.orderId,
    required this.midtransTransactionId,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.amount,
    this.paymentUrl,
    required this.responseJson,
  });

  String? get bank => responseJson["bank"];
  String? get statusCode => responseJson["status_code"];
  String? get vaNumber => responseJson["va_number"];
  DateTime? get transactionTime {
    if (responseJson["transaction_time"] == null) return null;
    return DateTime.tryParse(responseJson["transaction_time"]);
  }

  factory PaymentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PaymentModel(
      paymentId: id,
      orderId: data['order_id'] ?? "",
      midtransTransactionId: data['midtrans_transaction_id'] ?? "",
      paymentMethod: data['payment_method'] ?? "",
      paymentStatus: _parsePaymentStatus(data['payment_status']),
      amount: data['amount'] ?? 0,
      paymentUrl: data['payment_url'],
      responseJson: data['response_json'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "order_id": orderId,
      "midtrans_transaction_id": midtransTransactionId,
      "payment_method": paymentMethod,
      "payment_status": paymentStatus.name,
      "amount": amount,
      "payment_url": paymentUrl,
      "response_json": responseJson,
    };
  }
}
