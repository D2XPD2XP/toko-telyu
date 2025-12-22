import 'package:cloud_firestore/cloud_firestore.dart';
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

  const _MidtransResult({
    required this.transactionToken,
    required this.redirectUrl,
  });
}

class OrderService {
  final OrderRepository _orderRepo;
  final PaymentService _paymentService;
  final MidtransService _midtransService;
  final UserService _userService;

  OrderService({
    OrderRepository? orderRepository,
    PaymentService? paymentService,
    MidtransService? midtransService,
    UserService? userService,
    FlutterSecureStorage? storage,
  }) : _orderRepo = orderRepository ?? OrderRepository(),
       _paymentService = paymentService ?? PaymentService(),
       _midtransService =
           midtransService ??
           MidtransService(baseUrl: "https://toko-telyu-service.vercel.app"),
       _userService = userService ?? UserService();

  // Fetch / Read
  Future<OrderModel> getOrderById(String orderId) async {
    final order = await _orderRepo.getOrderById(orderId);
    if (order == null) throw Exception('Order not found');
    return order;
  }

  Future<List<OrderItem>> getOrderItems(String orderId) =>
      _orderRepo.getOrderItems(orderId);

  Future<Map<String, dynamic>> getOrderWithItems(String orderId) async {
    final order = await getOrderById(orderId);
    final items = await getOrderItems(orderId);
    return {'order': order, 'items': items};
  }

  Future<List<OrderModel>> getAllOrders() async {
    final user = await _userService.loadUser();
    if (user == null) throw Exception('User not found');

    return user.role == RoleEnum.ADMIN
        ? _orderRepo.getAllOrders()
        : _orderRepo.getOrdersByUserId(user.userId);
  }

  Future<OrderPageResult> getOrdersPage({
    required int limit,
    DocumentSnapshot? startAfter,
    List<String>? statusList,
  }) async {
    final user = await _userService.loadUser();
    if (user == null) throw Exception('User not logged in');

    if (user.role == RoleEnum.ADMIN) {
      return _orderRepo.getOrdersPage(
        limit: limit,
        startAfter: startAfter,
        statusList: statusList,
      );
    }

    return _orderRepo.getOrdersPage(
      limit: limit,
      startAfter: startAfter,
      userId: user.userId,
      statusList: statusList,
    );
  }

  // Actions / Mutations
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
      deliveryAreaId: shippingAddress['delivery_area_id'],
    );

    await _orderRepo.createOrderWithItemsAndReduceStock(
      order: order,
      items: items,
    );

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

  Future<void> updateOrderStatus(String orderId, TransactionStatus next) async {
    final order = await getOrderById(orderId);
    if (order.paymentStatus != PaymentStatus.completed) {
      throw Exception('Cannot update status before payment is completed');
    }
    order.orderStatus = next;
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

  // Helpers
  TransactionStatus? getNextStatus(OrderModel order) {
    if (order.paymentStatus != PaymentStatus.completed) return null;

    switch (order.orderStatus) {
      case TransactionStatus.pending:
        return order.shippingMethod == ShippingMethod.delivery
            ? TransactionStatus.outForDelivery
            : TransactionStatus.readyForPickup;
      case TransactionStatus.readyForPickup:
      case TransactionStatus.outForDelivery:
        return TransactionStatus.completed;
      default:
        return null;
    }
  }

  // Private builders / utils
  OrderModel _buildOrder({
    required String customerId,
    required double totalAmount,
    required ShippingMethod shippingMethod,
    required Map<String, dynamic> shippingAddress,
    required double shippingCost,
    String? deliveryAreaId,
  }) => OrderModel(
    orderId: _generateOrderId(),
    customerId: customerId,
    orderStatus: TransactionStatus.pending,
    paymentStatus: PaymentStatus.pending,
    shippingMethod: shippingMethod,
    shippingStatus: null,
    shippingAddress: shippingAddress,
    deliveryAreaId: deliveryAreaId,
    orderDate: DateTime.now(),
    shippingDate: null,
    totalAmount: totalAmount,
    shippingCost: shippingCost,
  );

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
