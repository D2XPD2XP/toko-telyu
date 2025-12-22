import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toko_telyu/models/order_item_model.dart';
import 'package:toko_telyu/models/order_model.dart';
import 'package:uuid/uuid.dart';

class OrderPageResult {
  final List<OrderModel> orders;
  final DocumentSnapshot? lastDoc;

  OrderPageResult({required this.orders, required this.lastDoc});
}

class OrderRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // CRUD Order
  Future<String> createOrder(OrderModel order) async {
    await _db.collection('order').doc(order.orderId).set(order.toFirestore());
    return order.orderId;
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _db.collection('order').doc(orderId).get();
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

  // CRUD Order Items
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
        .collection('order')
        .doc(orderId)
        .collection('order_items')
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

  // Query / List
  Future<List<OrderModel>> getAllOrders() async {
    final snap = await _db
        .collection('order')
        .orderBy('order_date', descending: true)
        .get();
    return snap.docs
        .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<OrderModel>> getOrdersByUserId(String userId) async {
    final snap = await _db
        .collection('order')
        .where('user_id', isEqualTo: userId)
        .get();
    return snap.docs
        .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<OrderPageResult> getOrdersPage({
    required int limit,
    DocumentSnapshot? startAfter,
    String? userId,
    List<String>? statusList,
  }) async {
    Query query = _db
        .collection('order')
        .orderBy('order_date', descending: true);

    if (userId != null) {
      query = query.where('user_id', isEqualTo: userId);
    }

    if (statusList != null && statusList.isNotEmpty) {
      query = query.where('order_status', whereIn: statusList);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    query = query.limit(limit);

    final snap = await query.get();
    final orders = snap.docs
        .map(
          (doc) => OrderModel.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();

    return OrderPageResult(
      orders: orders,
      lastDoc: snap.docs.isNotEmpty ? snap.docs.last : null,
    );
  }

  // Transactions
  Future<void> createOrderWithItemsAndReduceStock({
    required OrderModel order,
    required List<OrderItem> items,
  }) async {
    await _db.runTransaction((transaction) async {
      for (final item in items) {
        final variantRef = _db
            .collection('product')
            .doc(item.productId)
            .collection('product_variant')
            .doc(item.variantId);

        final variantSnap = await transaction.get(variantRef);
        if (!variantSnap.exists) {
          throw Exception(
            'The selected product option is no longer available. Refresh your cart and try again.',
          );
        }

        final currentStock = variantSnap.get('stock');
        if (currentStock == null ||
            currentStock is! int ||
            currentStock < item.amount) {
          throw Exception(
            'Insufficient stock for one or more items in your cart.',
          );
        }

        transaction.update(variantRef, {'stock': currentStock - item.amount});
      }

      final orderRef = _db.collection('order').doc(order.orderId);
      transaction.set(orderRef, order.toFirestore());

      for (final item in items) {
        final itemId = item.orderItemId.isEmpty ? _uuid.v4() : item.orderItemId;
        final itemRef = orderRef.collection('order_items').doc(itemId);
        transaction.set(itemRef, item.toFirestore());
      }
    });
  }
}
