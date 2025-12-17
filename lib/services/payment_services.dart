import 'package:flutter/widgets.dart';
import 'package:toko_telyu/enums/payment_status.dart';
import 'package:toko_telyu/models/payment_model.dart';
import 'package:toko_telyu/repositories/payment_repository.dart';

class PaymentService {
  final PaymentRepository _repo;

  PaymentService({PaymentRepository? repository})
    : _repo = repository ?? PaymentRepository();

  Future<void> createPayment({
    required String orderId,
    required String transactionToken,
    required String redirectUrl,
    required int amount,
    String paymentMethod = "midtrans",
  }) async {
    final payment = PaymentModel(
      paymentId: _generatePaymentId(),
      orderId: orderId,
      midtransTransactionId: transactionToken,
      paymentMethod: paymentMethod,
      paymentStatus: PaymentStatus.pending,
      amount: amount,
      paymentUrl: redirectUrl,
      responseJson: _buildInitialResponse(transactionToken, redirectUrl),
    );

    await _repo.createPayment(payment);
  }

  Future<PaymentModel?> getPaymentByOrder(String orderId) async {
    try {
      return await _repo.getPaymentByOrder(orderId);
    } catch (e) {
      debugPrint("Failed to get payment for order $orderId: $e");
      return null;
    }
  }

  Future<void> updatePaymentFromMidtrans({
    required String paymentId,
    required Map<String, dynamic> midtransResponse,
  }) async {
    await _repo.updatePaymentFromMidtrans(
      paymentId: paymentId,
      midtransTransactionId:
          midtransResponse["transaction_id"] as String? ?? "",
      paymentMethod: midtransResponse["payment_type"] as String? ?? "midtrans",
      transactionStatus:
          midtransResponse["transaction_status"] as String? ?? "pending",
      responseJson: midtransResponse,
    );
  }

  String _generatePaymentId() => "PAY-${DateTime.now().millisecondsSinceEpoch}";

  Map<String, dynamic> _buildInitialResponse(String token, String redirectUrl) {
    return {"transaction_token": token, "redirect_url": redirectUrl};
  }
}
