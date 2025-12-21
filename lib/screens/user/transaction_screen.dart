import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  List<OrderModel> _orders = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  DocumentSnapshot? _lastDoc;

  final ScrollController _scrollController = ScrollController();
  final Map<String, Map<String, dynamic>> _orderPreview = {};
  final int _limit = 5;

  // Filters
  TransactionStatus? _selectedStatus;
  String? _selectedDateRange;

  final List<String> _dateRangeOptions = [
    'All Dates',
    'Today',
    'This Week',
    'This Month',
  ];
  final List<TransactionStatus?> _statusOptions = [
    null,
    ...TransactionStatus.values,
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadOrders({bool reset = true}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _orders = [];
        _lastDoc = null;
        _hasMore = true;
        _errorMessage = null;
      });
    }

    if (!_hasMore || _loadingMore) return;
    setState(() => _loadingMore = true);

    try {
      final statusList = _selectedStatus != null
          ? [_selectedStatus!.name]
          : null;

      final result = await _orderService.getOrdersPage(
        limit: _limit,
        startAfter: _lastDoc,
        statusList: statusList,
      );

      var filteredOrders = result.orders;

      // Apply date filter tetap di client
      if (_selectedDateRange != null && _selectedDateRange != 'All Dates') {
        final now = DateTime.now();
        filteredOrders = filteredOrders.where((o) {
          switch (_selectedDateRange) {
            case 'Today':
              return o.orderDate.year == now.year &&
                  o.orderDate.month == now.month &&
                  o.orderDate.day == now.day;
            case 'This Week':
              final weekStart = now.subtract(Duration(days: now.weekday - 1));
              final weekEnd = weekStart.add(const Duration(days: 6));
              return o.orderDate.isAfter(
                    weekStart.subtract(const Duration(seconds: 1)),
                  ) &&
                  o.orderDate.isBefore(weekEnd.add(const Duration(days: 1)));
            case 'This Month':
              return o.orderDate.year == now.year &&
                  o.orderDate.month == now.month;
            default:
              return true;
          }
        }).toList();
      }

      for (final order in filteredOrders) {
        if (!_orderPreview.containsKey(order.orderId)) {
          _orderPreview[order.orderId] = await _safeLoadItemPreview(
            order.orderId,
          );
        }
      }

      setState(() {
        _orders.addAll(filteredOrders);
        _lastDoc = result.lastDoc;
        _hasMore = result.orders.length == _limit;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e, s) {
      debugPrint('Error loading orders: $e');
      debugPrintStack(stackTrace: s);
      setState(() {
        _errorMessage = 'Failed to load transactions.';
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<Map<String, dynamic>> _safeLoadItemPreview(String orderId) async {
    try {
      final items = await _orderService.getOrderItems(orderId);
      if (items.isEmpty) return _emptyPreview();

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
    } catch (_) {
      return _emptyPreview();
    }
  }

  Map<String, dynamic> _emptyPreview() => {
    'image': 'assets/placeholder.png',
    'name': 'Unknown Product',
    'count': 0,
  };

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadOrders(reset: false);
    }
  }

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

  void _onFilterChanged() {
    _loadOrders(reset: true);
  }

  String _statusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return "Order Received";
      case TransactionStatus.preparingForDelivery:
        return "Preparing Order";
      case TransactionStatus.readyForPickup:
        return "Ready for Pickup";
      case TransactionStatus.outForDelivery:
        return "Out for Delivery";
      case TransactionStatus.completed:
        return "Completed";
      case TransactionStatus.cancelled:
        return "Cancelled";
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(canvasColor: Colors.white),
                child: DropdownButton<TransactionStatus?>(
                  value: _selectedStatus,
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text(
                    "All Status",
                    style: TextStyle(color: Colors.black54),
                  ),
                  items: _statusOptions
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(
                            status != null ? _statusText(status) : 'All Status',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                    _onFilterChanged();
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(canvasColor: Colors.white),
                child: DropdownButton<String>(
                  value: _selectedDateRange ?? _dateRangeOptions[0],
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text(
                    "All Dates",
                    style: TextStyle(color: Colors.black54),
                  ),
                  items: _dateRangeOptions
                      .map(
                        (range) => DropdownMenuItem(
                          value: range,
                          child: Text(
                            range,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedDateRange = value);
                    _onFilterChanged();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: TopNavbar(
          text: 'SEARCH TRANSACTION',
          onSubmitted: (_) => _loadOrders(),
          onchanged: true,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: Color(0xFFED1E28),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatbotScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xFFED1E28),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFED1E28)),
                  )
                : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : _orders.isEmpty
                ? const Center(child: Text('No transactions found'))
                : RefreshIndicator(
                    color: const Color(0xFFED1E28),
                    onRefresh: () async {
                      await _loadOrders(reset: true);
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _orders.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _orders.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFED1E28),
                              ),
                            ),
                          );
                        }

                        final order = _orders[index];
                        final preview =
                            _orderPreview[order.orderId] ?? _emptyPreview();

                        return TransactionCard(
                          productImage: ProductImageView(
                            imageUrl: preview['image'],
                            size: 60,
                          ),
                          status: order.orderStatus,
                          paymentStatus: order.paymentStatus,
                          date:
                              '${order.orderDate.day} ${_month(order.orderDate.month)} ${order.orderDate.year}',
                          productName: preview['name'],
                          itemCount: preview['count'],
                          orderTotal: order.totalAmount,
                          onTap: () => _openOrderDetail(order.orderId),
                          onPayNow: order.paymentStatus == PaymentStatus.pending
                              ? () => _openOrderDetail(order.orderId)
                              : null,
                          onTrackOrder:
                              order.orderStatus ==
                                  TransactionStatus.outForDelivery
                              ? () => _trackOrder(order.orderId)
                              : null,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

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
