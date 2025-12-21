import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toko_telyu/models/order_item_model.dart';
import 'package:toko_telyu/models/order_model.dart';
import 'package:uuid/uuid.dart';

class OrderRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<List<OrderModel>> getAllOrders() async {
    final snap = await FirebaseFirestore.instance
        .collection('order')
        .orderBy('order_date', descending: true)
        .get();

    return snap.docs
        .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<OrderModel>> getOrdersByUserId(String userId) async {
    final snap = await FirebaseFirestore.instance
        .collection('order')
        .where('user_id', isEqualTo: userId)
        .get();

    return snap.docs
        .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<String> createOrder(OrderModel order) async {
    await _db.collection('order').doc(order.orderId).set(order.toFirestore());
    return order.orderId;
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await FirebaseFirestore.instance
        .collection('order')
        .doc(orderId)
        .get();
    if (!doc.exists) return null;
    return OrderModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> updateOrder(OrderModel order) async {
    await _db
        .collection('order')
        .doc(order.orderId)
        .update(order.toFirestore());
  }

  Future<void> deleteOrder(String orderId) async {
    await _db.collection('order').doc(orderId).delete();
  }

  Future<String> addOrderItem(String orderId, OrderItem item) async {
    final itemId = _uuid.v4();
    await _db
        .collection('order')
        .doc(orderId)
        .collection('order_items')
        .doc(itemId)
        .set(item.toFirestore());
    return itemId;
  }

  Future<List<OrderItem>> getOrderItems(String orderId) async {
    final snapshot = await _db
        .collection("order")
        .doc(orderId)
        .collection("order_items")
        .get();

    return snapshot.docs
        .map((d) => OrderItem.fromFirestore(d.data(), d.id))
        .toList();
  }

  Future<void> updateOrderItem(String orderId, OrderItem item) async {
    await _db
        .collection('order')
        .doc(orderId)
        .collection('order_items')
        .doc(item.orderItemId)
        .update(item.toFirestore());
  }

  Future<void> deleteOrderItem(String orderId, String itemId) async {
    await _db
        .collection('order')
        .doc(orderId)
        .collection('order_items')
        .doc(itemId)
        .delete();
  }
}
