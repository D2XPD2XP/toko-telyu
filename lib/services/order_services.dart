import 'package:toko_telyu/enums/shipping_method.dart';
import 'package:toko_telyu/enums/shipping_status.dart';
import 'package:toko_telyu/enums/transaction_status.dart';
import 'package:toko_telyu/models/order_item_model.dart';
import 'package:toko_telyu/models/order_model.dart';
import 'package:toko_telyu/repositories/order_repositories.dart';
import 'package:uuid/uuid.dart';


class OrderService {
  final OrderRepository _repo = OrderRepository();

  Future<String> createOrderWithItems(OrderModel order, List<OrderItem> items) async {

    final orderId = await _repo.createOrder(order);
    for (var item in items) {
      await _repo.addOrderItem(orderId, item);
    }
    return orderId;
  }

  Future<void> updateOrderStatus(
      String orderId, TransactionStatus status) async {
    final order = await _repo.getOrderById(orderId);
    if (order == null) return;
    order.orderStatus = status;
    await _repo.updateOrder(order);
  }

  Future<void> updateShippingStatus(
      String orderId, ShippingStatus status) async {
    final order = await _repo.getOrderById(orderId);
    if (order == null) return;
    order.shippingStatus = status;
    await _repo.updateOrder(order);
  }

  Future<Map<String, dynamic>> getOrderWithItems(String orderId) async {
    final order = await _repo.getOrderById(orderId);
    final items = await _repo.getOrderItems(orderId);
    return {'order': order, 'items': items};
  }

  Future<void> deleteOrderCompletely(String orderId) async {
    final items = await _repo.getOrderItems(orderId);
    for (var item in items) {
      await _repo.deleteOrderItem(orderId, item.orderItemId);
    }
    await _repo.deleteOrder(orderId);
  }
}
