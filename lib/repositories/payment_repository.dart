import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toko_telyu/enums/payment_status.dart';
import 'package:toko_telyu/models/payment_model.dart';

class PaymentRepository {
  final CollectionReference _payments = FirebaseFirestore.instance.collection(
    'payment',
  );

  Future<PaymentModel?> getPaymentByOrder(String orderId) async {
    final snapshot = await _payments
        .where('order_id', isEqualTo: orderId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel.fromFirestore(data, doc.id);
  }

  Future<String> createPayment(PaymentModel payment) async {
    final docRef = _payments.doc(payment.paymentId);

    await docRef.set(payment.toFirestore());

    return docRef.id;
  }

  Future<void> updatePayment(PaymentModel payment) async {
    await _payments.doc(payment.paymentId).update(payment.toFirestore());
  }

  Future<void> updatePaymentStatus(String paymentId, String newStatus) async {
    await _payments.doc(paymentId).update({"payment_status": newStatus});
  }

  Future<PaymentModel?> getPaymentById(String paymentId) async {
    final doc = await _payments.doc(paymentId).get();

    if (!doc.exists) return null;

    return PaymentModel.fromFirestore(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }

  Future<PaymentModel?> getPaymentByOrderId(String orderId) async {
    final snap = await _payments
        .where("order_id", isEqualTo: orderId)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    final doc = snap.docs.first;

    return PaymentModel.fromFirestore(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }

  Future<void> deletePayment(String paymentId) async {
    await _payments.doc(paymentId).delete();
  }

  Stream<List<PaymentModel>> streamPayments() {
    return _payments.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => PaymentModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    });
  }

  Future<List<PaymentModel>> getAllPayments() async {
    final snap = await _payments.get();
    return snap.docs
        .map(
          (doc) => PaymentModel.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();
  }

  Future<void> updatePaymentFromMidtrans({
    required String paymentId,
    required String midtransTransactionId,
    required String paymentMethod,
    required String transactionStatus,
    required Map<String, dynamic> responseJson,
  }) async {
    final status = _parsePaymentStatus(transactionStatus);

    await _payments.doc(paymentId).update({
      "midtrans_transaction_id": midtransTransactionId,
      "payment_method": paymentMethod,
      "payment_status": status.name,
      "response_json": responseJson,
    });
  }

  PaymentStatus _parsePaymentStatus(String? status) {
    switch (status) {
      case "pending":
        return PaymentStatus.pending;
      case "settlement":
      case "capture":
        return PaymentStatus.completed;
      case "deny":
      case "expire":
      case "cancel":
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }
}
