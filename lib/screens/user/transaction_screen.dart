import 'package:flutter/material.dart';

import 'package:toko_telyu/enums/payment_status.dart';
import 'package:toko_telyu/enums/transaction_status.dart';

import 'package:toko_telyu/models/order_model.dart';

import 'package:toko_telyu/screens/user/cart_screen.dart';
import 'package:toko_telyu/screens/user/chatbot_screen.dart';
import 'package:toko_telyu/screens/user/order_detail_screen.dart';
import 'package:toko_telyu/screens/user/track_order_screen.dart';

import 'package:toko_telyu/services/order_services.dart';
import 'package:toko_telyu/services/product_services.dart';

import 'package:toko_telyu/widgets/product_image.dart';
import 'package:toko_telyu/widgets/top_navbar.dart';
import 'package:toko_telyu/widgets/transaction_card.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final OrderService _orderService = OrderService();
  final ProductService _productService = ProductService();

  String _selectedStatus = 'All Products';
  String _selectedDate = 'All Dates';

  List<OrderModel> _orders = [];
  bool _loading = true;

  final Map<String, Map<String, dynamic>> _orderPreview = {};

  // ===================== LIFECYCLE =====================

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // ===================== DATA =====================

  Future<void> _fetchOrders() async {
    try {
      final orders = await _orderService.getAllOrders()
        ..sort((a, b) => b.orderDate.compareTo(a.orderDate));

      // Load semua preview item sekaligus
      for (final order in orders) {
        _orderPreview[order.orderId] = await _loadItemPreview(order.orderId);
      }

      if (!mounted) return;
      setState(() {
        _orders = orders;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading orders: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<Map<String, dynamic>> _loadItemPreview(String orderId) async {
    final items = await _orderService.getOrderItems(orderId);

    if (items.isEmpty) {
      return {
        'image': 'assets/placeholder.png',
        'name': 'No Items',
        'count': 0,
      };
    }

    final firstItem = items.first;
    final product = await _productService.getProduct(firstItem.productId);
    final images = await _productService.getImages(firstItem.productId);

    return {
      'image': images.isNotEmpty
          ? images.first.imageUrl
          : 'assets/placeholder.png',
      'name': product.productName,
      'count': items.length,
    };
  }

  // ===================== FILTER =====================

  List<OrderModel> _filteredOrders() {
    return _orders.where((order) {
      if (_selectedStatus != 'All Products') {
        if (_selectedStatus == 'Completed' &&
            order.orderStatus != TransactionStatus.completed) {
          return false;
        }

        if (_selectedStatus == 'Pending' &&
            order.orderStatus != TransactionStatus.pending) {
          return false;
        }
      }

      if (_selectedDate != 'All Dates') {
        final diff = DateTime.now().difference(order.orderDate).inDays;

        if (_selectedDate == 'Last 30 Days' && diff > 30) return false;
        if (_selectedDate == 'Last 90 Days' && diff > 90) return false;
      }

      return true;
    }).toList();
  }

  // ===================== ACTION =====================

  void _openOrderDetail(String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId)),
    );
  }

  void _trackOrder(String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrackOrderScreen(orderId: orderId)),
    );
  }

  void _reorder(String orderId) {
    debugPrint('Reorder order $orderId');
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _appBar(),
      body: _loading ? _loadingView() : _listView(orders),
    );
  }

  AppBar _appBar() => AppBar(
    backgroundColor: Colors.grey[100],
    elevation: 0,
    automaticallyImplyLeading: false,
    titleSpacing: 16,
    title: TopNavbar(
      text: 'SEARCH TRANSACTION',
      onSubmitted: (_) {},
      onchanged: true,
    ),
    actions: [
      _appBarIcon(
        Icons.chat_bubble_outline,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
        ),
      ),
      _appBarIcon(
        Icons.shopping_cart_outlined,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
      ),
      const SizedBox(width: 8),
    ],
  );

  Widget _appBarIcon(IconData icon, VoidCallback onTap) => IconButton(
    icon: Icon(icon, color: const Color(0xFFED1E28)),
    onPressed: onTap,
  );

  Widget _loadingView() =>
      const Center(child: CircularProgressIndicator(color: Color(0xFFED1E28)));

  Widget _listView(List<OrderModel> orders) => ListView(
    padding: EdgeInsets.zero,
    children: [
      _buildFilterBar(),
      for (final order in orders) _transactionItem(order),
    ],
  );

  Widget _transactionItem(OrderModel order) {
    final data = _orderPreview[order.orderId];

    if (data == null) {
      // loading merah hanya untuk card yang belum siap
      return SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    return TransactionCard(
      productImage: ProductImageView(imageUrl: data['image'], size: 60),
      status: order.orderStatus,
      paymentStatus: order.paymentStatus,
      date:
          '${order.orderDate.day} ${_month(order.orderDate.month)} ${order.orderDate.year}',
      productName: data['name'],
      itemCount: data['count'],
      orderTotal: order.totalAmount.toDouble(),
      onTap: () => _openOrderDetail(order.orderId),
      onPayNow: order.paymentStatus == PaymentStatus.pending
          ? () => _openOrderDetail(order.orderId)
          : null,
      onTrackOrder: order.orderStatus == TransactionStatus.outForDelivery
          ? () => _trackOrder(order.orderId)
          : null,
      onReorder: order.orderStatus == TransactionStatus.completed
          ? () => _reorder(order.orderId)
          : null,
    );
  }

  // ===================== FILTER UI =====================

  Widget _buildFilterBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        _dropdown(
          value: _selectedStatus,
          items: const ['All Products', 'Completed', 'Pending'],
          onChanged: (v) => setState(() => _selectedStatus = v),
        ),
        const SizedBox(width: 10),
        _dropdown(
          value: _selectedDate,
          items: const ['All Dates', 'Last 30 Days', 'Last 90 Days'],
          onChanged: (v) => setState(() => _selectedDate = v),
        ),
      ],
    ),
  );

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Expanded(
      child: Container(
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    );
  }

  // ===================== UTIL =====================

  String _month(int m) => const [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][m];
}
