import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toko_telyu/enums/shipping_method.dart';
import 'package:toko_telyu/enums/shipping_status.dart';
import 'package:toko_telyu/enums/transaction_status.dart';

class OrderModel {
  String orderId;
  String customerId;
  TransactionStatus orderStatus;
  ShippingMethod shippingMethod;
  ShippingStatus? shippingStatus;
  Map<String, dynamic>? shippingAddress;
  DateTime orderDate;
  int totalAmount;
  String paymentId;
  String? deliveryAreaId;

  OrderModel({
    required this.orderId,
    required this.customerId,
    required this.orderStatus,
    required this.shippingMethod,
    required this.shippingStatus,
    required this.shippingAddress,
    required this.orderDate,
    required this.totalAmount,
    required this.paymentId,
    required this.deliveryAreaId,
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      orderId: id,
      customerId: data['customerId'],
      orderStatus: TransactionStatus.values.byName(data['orderStatus']),
      shippingMethod: ShippingMethod.values.byName(data['shippingMethod']),
      shippingStatus: data['shippingStatus'] != null
          ? ShippingStatus.values.byName(data['shippingStatus'])
          : null,
      shippingAddress: data['shippingAddress'],
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      totalAmount: data['totalAmount'],
      paymentId: data['paymentId'],
      deliveryAreaId: data['deliveryAreaId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'orderStatus': orderStatus.name,
      'shippingMethod': shippingMethod.name,
      'shippingStatus': shippingStatus?.name,
      'shippingAddress': shippingAddress,
      'orderDate': orderDate,
      'totalAmount': totalAmount,
      'paymentId': paymentId,
      'deliveryAreaId': deliveryAreaId,
    };
  }
}