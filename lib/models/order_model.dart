import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toko_telyu/enums/payment_status.dart';
import 'package:toko_telyu/enums/shipping_method.dart';
import 'package:toko_telyu/enums/shipping_status.dart';
import 'package:toko_telyu/enums/transaction_status.dart';

TransactionStatus _parseTransactionStatus(String? status) {
  switch (status?.toUpperCase()) {
    case "PENDING":
      return TransactionStatus.pending;
    case "READYFORPICKUP":
      return TransactionStatus.readyForPickup;
    case "OUTFORDELIVERY":
      return TransactionStatus.outForDelivery;
    case "COMPLETED":
      return TransactionStatus.completed;
    case "CANCELLED":
      return TransactionStatus.cancelled;
    default:
      return TransactionStatus.pending;
  }
}

ShippingMethod _parseShippingMethod(String? method) {
  switch (method) {
    case "directDelivery":
      return ShippingMethod.directDelivery;
    case "delivery":
      return ShippingMethod.delivery;
    case "pickup":
      return ShippingMethod.pickup;
    default:
      return ShippingMethod.delivery;
  }
}

ShippingStatus? _parseShippingStatus(String? status) {
  switch (status) {
    case "pending":
      return ShippingStatus.packed;
    case "on_the_way":
      return ShippingStatus.shipped;
    case "delivered":
      return ShippingStatus.delivered;
    default:
      return null;
  }
}

class OrderModel {
  String orderId;
  String customerId;
  TransactionStatus orderStatus;
  ShippingMethod shippingMethod;
  ShippingStatus? shippingStatus;
  Map<String, dynamic>? shippingAddress;
  DateTime orderDate;
  double totalAmount;

  PaymentStatus paymentStatus;
  String? deliveryAreaId;
  DateTime? shippingDate;

  double shippingCost;

  OrderModel({
    required this.orderId,
    required this.customerId,
    required this.orderStatus,
    required this.shippingMethod,
    required this.shippingStatus,
    required this.shippingAddress,
    required this.orderDate,
    required this.totalAmount,
    required this.paymentStatus,
    required this.deliveryAreaId,
    required this.shippingDate,
    this.shippingCost = 0,
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      orderId: data['order_id'] ?? id,
      customerId: data['user_id'] ?? "unknown",
      orderStatus: _parseTransactionStatus(data['order_status']),
      shippingMethod: _parseShippingMethod(data['shipping_method']),
      shippingStatus: _parseShippingStatus(data['shipping_status']),
      shippingAddress:
          data['shipping_address'] != null && data['shipping_address'] is Map
          ? Map<String, dynamic>.from(data['shipping_address'])
          : null,
      orderDate: (data['order_date'] as Timestamp).toDate(),
      shippingDate: data['shipping_date'] != null
          ? (data['shipping_date'] as Timestamp).toDate()
          : null,
      totalAmount: (data['total_amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: parsePaymentStatus(data['payment_status']),
      deliveryAreaId: data['delivery_area_id'],
      shippingCost: (data['shipping_cost'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'order_id': orderId,
      'user_id': customerId,
      'order_status': orderStatus.name.toUpperCase(),
      'shipping_method': shippingMethod.name,
      'shipping_status': shippingStatus?.name,
      'shipping_address': shippingAddress,
      'order_date': orderDate,
      'shipping_date': shippingDate,
      'total_amount': totalAmount,
      'payment_status': paymentStatus.name,
      'delivery_area_id': deliveryAreaId,
      'shipping_cost': shippingCost,
    };
  }
}
