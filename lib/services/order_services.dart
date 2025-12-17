import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:toko_telyu/enums/payment_status.dart';
import 'package:toko_telyu/enums/role.dart';
import 'package:toko_telyu/enums/shipping_method.dart';
import 'package:toko_telyu/enums/shipping_status.dart';
import 'package:toko_telyu/enums/transaction_status.dart';
import 'package:toko_telyu/models/order_item_model.dart';
import 'package:toko_telyu/models/order_model.dart';
import 'package:toko_telyu/repositories/order_repositories.dart';
import 'package:toko_telyu/services/midtrans_services.dart';
import 'package:toko_telyu/services/payment_services.dart';
import 'package:toko_telyu/services/user_services.dart';

class CheckoutResult {
  final String orderId;
  final String transactionToken;
  final String redirectUrl;

  CheckoutResult({
    required this.orderId,
    required this.transactionToken,
    required this.redirectUrl,
  });
}

class _MidtransResult {
  final String transactionToken;
  final String redirectUrl;

  _MidtransResult({required this.transactionToken, required this.redirectUrl});
}

class OrderService {
  final OrderRepository _orderRepo;
  final PaymentService _paymentService;
  final MidtransService _midtransService;
  UserService userService = UserService();
  final storage = FlutterSecureStorage();

  OrderService({
    OrderRepository? orderRepository,
    PaymentService? paymentService,
    MidtransService? midtransService,
  }) : _orderRepo = orderRepository ?? OrderRepository(),
       _paymentService = paymentService ?? PaymentService(),
       _midtransService = MidtransService(
         baseUrl: "https://toko-telyu-service.vercel.app",
       );
  //  midtransService ?? MidtransService(baseUrl: "http://10.0.2.2:8000");

  Future<OrderModel> getOrderById(String orderId) async {
    final order = await _orderRepo.getOrderById(orderId);
    if (order == null) {
      throw Exception("Order not found");
    }
    return order;
  }

  Future<List<OrderItem>> getOrderItems(String orderId) {
    return _orderRepo.getOrderItems(orderId);
  }

  Future<Map<String, dynamic>> getOrderWithItems(String orderId) async {
    final order = await getOrderById(orderId);
    final items = await getOrderItems(orderId);
    return {'order': order, 'items': items};
  }

  Future<List<OrderModel>> getAllOrders() async {
    try {
      final user = await userService.loadUser();

      if (user == null) {
        throw Exception('User not found. Please login again.');
      }

      if (user.role == RoleEnum.ADMIN) {
        return await _orderRepo.getAllOrders();
      } else {
        return await _orderRepo.getOrdersByUserId(user.userId);
      }
    } catch (e, stackTrace) {
      debugPrint('Error getAllOrders: $e');
      debugPrint(stackTrace as String?);
      return [];
    }
  }

  Future<CheckoutResult> checkout({
    required String customerId,
    required List<OrderItem> items,
    required double totalAmount,
    required String customerName,
    required String customerEmail,
    required ShippingMethod shippingMethod,
    required Map<String, dynamic> shippingAddress,
    double shippingCost = 0,
  }) async {
    final order = _buildOrder(
      customerId: customerId,
      totalAmount: totalAmount,
      shippingMethod: shippingMethod,
      shippingAddress: shippingAddress,
      shippingCost: shippingCost,
    );

    await _orderRepo.createOrder(order);
    await _addOrderItems(order.orderId, items);

    final paymentData = await _createMidtransTransaction(
      orderId: order.orderId,
      amount: totalAmount,
      customerName: customerName,
      customerEmail: customerEmail,
    );

    await _paymentService.createPayment(
      orderId: order.orderId,
      transactionToken: paymentData.transactionToken,
      redirectUrl: paymentData.redirectUrl,
      amount: totalAmount.toInt(),
    );

    return CheckoutResult(
      orderId: order.orderId,
      transactionToken: paymentData.transactionToken,
      redirectUrl: paymentData.redirectUrl,
    );
  }

  Future<void> updateOrderStatus(
    String orderId,
    TransactionStatus status,
  ) async {
    final order = await getOrderById(orderId);
    order.orderStatus = status;
    await _orderRepo.updateOrder(order);
  }

  Future<void> updateShippingStatus(
    String orderId,
    ShippingStatus status,
  ) async {
    final order = await getOrderById(orderId);
    order.shippingStatus = status;
    order.shippingDate ??= DateTime.now();
    await _orderRepo.updateOrder(order);
  }

  Future<void> deleteOrderCompletely(String orderId) async {
    final items = await getOrderItems(orderId);

    for (final item in items) {
      await _orderRepo.deleteOrderItem(orderId, item.orderItemId);
    }

    await _orderRepo.deleteOrder(orderId);
  }

  OrderModel _buildOrder({
    required String customerId,
    required double totalAmount,
    required ShippingMethod shippingMethod,
    required Map<String, dynamic> shippingAddress,
    required double shippingCost,
  }) {
    return OrderModel(
      orderId: _generateOrderId(),
      customerId: customerId,
      orderStatus: TransactionStatus.pending,
      paymentStatus: PaymentStatus.pending,
      shippingMethod: shippingMethod,
      shippingStatus: null,
      shippingAddress: shippingAddress,
      deliveryAreaId: shippingAddress['deliveryAreaId'],
      orderDate: DateTime.now(),
      shippingDate: null,
      totalAmount: totalAmount,
      shippingCost: shippingCost,
    );
  }

  Future<void> _addOrderItems(String orderId, List<OrderItem> items) async {
    for (final item in items) {
      await _orderRepo.addOrderItem(orderId, item);
    }
  }

  Future<_MidtransResult> _createMidtransTransaction({
    required String orderId,
    required double amount,
    required String customerName,
    required String customerEmail,
  }) async {
    final data = await _midtransService.createTransaction(
      orderId: orderId,
      amount: amount.toInt(),
      customerName: customerName,
      customerEmail: customerEmail,
    );

    final token = data?['transactionToken'];
    final url = data?['redirectUrl'];

    if (token == null || url == null) {
      throw Exception(
        'Invalid Midtrans response: token or redirectUrl is null',
      );
    }

    return _MidtransResult(transactionToken: token, redirectUrl: url);
  }

  String _generateOrderId() => "ORDER-${DateTime.now().millisecondsSinceEpoch}";
}
