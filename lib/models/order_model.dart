import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toko_telyu/models/order_item_model.dart';

enum OrderStatus {
  pending,
  paid,
  processing,
  readyForPickup,
  delivering,
  completed,
  cancelled,
}

enum ShippingMethod { pickup, delivery }

enum ShippingStatus { notApplicable, pending, delivering, delivered, failed }

class Order {
  String orderId;
  String customerId;
  OrderStatus orderStatus;
  ShippingMethod shippingMethod;
  ShippingStatus shippingStatus;
  String shippingAddress;
  DateTime orderDate;
  int totalAmount;
  List<OrderItem> orderItems;
  String paymentId;
  String deliveryAreaId;

  Order({
    required this.orderId,
    required this.customerId,
    required this.orderStatus,
    required this.shippingMethod,
    required this.shippingStatus,
    required this.shippingAddress,
    required this.orderDate,
    required this.totalAmount,
    required this.orderItems,
    required this.paymentId,
    required this.deliveryAreaId,
  });

  factory Order.fromFirestore(Map<String, dynamic> data, String id) {
    return Order(
      orderId: id,
      customerId: data['customerId'] ?? '',
      orderStatus: OrderStatus.values.byName(data['orderStatus'] ?? "pending"),
      shippingMethod: ShippingMethod.values.byName(
        data['shippingMethod'] ?? "pickup",
      ),
      shippingStatus: ShippingStatus.values.byName(
        data['shippingStatus'] ?? "notApplicable",
      ),
      shippingAddress: data['shippingAddress'] ?? '',
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      totalAmount: data['totalAmount'] ?? 0,
      paymentId: data['paymentId'] ?? '',
      deliveryAreaId: data['deliveryAreaId'] ?? '',
      orderItems: data['orderItems'] != null
          ? List<Map<String, dynamic>>.from(
              data['orderItems'],
            ).map((item) => OrderItem.fromFirestore(item)).toList()
          : [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "customerId": customerId,
      "orderStatus": orderStatus.name,
      "shippingMethod": shippingMethod.name,
      "shippingStatus": shippingStatus.name,
      "shippingAddress": shippingAddress,
      "orderDate": orderDate,
      "totalAmount": totalAmount,
      "paymentId": paymentId,
      "deliveryAreaId": deliveryAreaId,
      "orderItems": orderItems.map((e) => e.toFirestore()).toList(),
    };
  }
}
