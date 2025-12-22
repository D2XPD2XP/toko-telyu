import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toko_telyu/enums/payment_status.dart';
import 'package:toko_telyu/enums/transaction_status.dart';
import 'package:toko_telyu/models/order_model.dart';
import 'package:toko_telyu/screens/admin/order_detail_screen.dart';
import 'package:toko_telyu/services/order_services.dart';
import 'package:toko_telyu/services/user_services.dart';
import 'package:toko_telyu/widgets/admin/order/order_card.dart';
import 'package:toko_telyu/widgets/admin/order/order_filter_widget.dart';

enum OrderFilter {
  all,
  waitingPayment,
  pending,
  readyForPickup,
  outForDelivery,
  completed,
  cancelled,
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _orderService = OrderService();
  final _userService = UserService();
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;

  final Color primaryColor = const Color(0xFFED1E28);
  final Map<String, String> _customerCache = {};

  List<OrderModel> _orders = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;
  final int _limit = 10;
  OrderFilter _filter = OrderFilter.pending;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrdersPage(reset: true);
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadOrdersPage({bool reset = false}) async {
    if (reset) {
      _orders = [];
      _lastDoc = null;
      _hasMore = true;
      _loading = true;
      _errorMessage = null;
    }

    if (!_hasMore || _loadingMore) return;

    _loadingMore = true;

    try {
      List<String>? statusList;
      PaymentStatus? paymentFilter;

      switch (_filter) {
        case OrderFilter.pending:
          statusList = ['PENDING'];
          paymentFilter = PaymentStatus.completed;
          break;
        case OrderFilter.waitingPayment:
          statusList = ['PENDING'];
          paymentFilter = PaymentStatus.pending;
          break;
        case OrderFilter.readyForPickup:
          statusList = ['READYFORPICKUP'];
          break;
        case OrderFilter.outForDelivery:
          statusList = ['OUTFORDELIVERY'];
          break;
        case OrderFilter.completed:
          statusList = ['COMPLETED'];
          break;
        case OrderFilter.cancelled:
          statusList = ['CANCELLED'];
          break;
        case OrderFilter.all:
          statusList = null;
          break;
      }

      final result = await _orderService.getOrdersPage(
        limit: _limit,
        startAfter: _lastDoc,
        statusList: statusList,
        paymentStatusFilter: paymentFilter,
      );

      final orders = result.orders;

      // cache customer name
      for (final o in orders) {
        if (!_customerCache.containsKey(o.customerId)) {
          try {
            final user = await _userService.getUser(o.customerId);
            _customerCache[o.customerId] = user?.name ?? 'Unknown User';
          } catch (_) {
            _customerCache[o.customerId] = 'Unknown User';
          }
        }
      }

      _orders.addAll(orders);
      _lastDoc = result.lastDoc;
      _hasMore = result.orders.length == _limit && orders.isNotEmpty;
    } catch (e, s) {
      debugPrint('Error loading orders page: $e');
      debugPrintStack(stackTrace: s);
      _errorMessage = 'Failed to load orders. Please try again.';
    } finally {
      setState(() {
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadOrdersPage();
    }
  }

  List<OrderModel> get _filtered {
    final q = _searchController.text.toLowerCase();
    return _orders.where((o) {
      final matchSearch =
          o.orderId.toLowerCase().contains(q) ||
          (_customerCache[o.customerId] ?? '').toLowerCase().contains(q);
      if (!matchSearch) return false;

      switch (_filter) {
        case OrderFilter.waitingPayment:
          return o.paymentStatus == PaymentStatus.pending;
        case OrderFilter.pending:
          return o.orderStatus == TransactionStatus.pending &&
              o.paymentStatus == PaymentStatus.completed;
        case OrderFilter.readyForPickup:
          return o.orderStatus == TransactionStatus.readyForPickup;
        case OrderFilter.outForDelivery:
          return o.orderStatus == TransactionStatus.outForDelivery;
        case OrderFilter.completed:
          return o.orderStatus == TransactionStatus.completed;
        case OrderFilter.cancelled:
          return o.orderStatus == TransactionStatus.cancelled;
        case OrderFilter.all:
          return true;
      }
    }).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Orders",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (text) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  setState(() {});
                });
              },
              decoration: InputDecoration(
                hintText: "Search order / customer",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OrderFilterWidget(
              initial: _filter,
              onChanged: (f) {
                setState(() => _filter = f);
                _loadOrdersPage(reset: true);
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                color: primaryColor,
                onRefresh: () => _loadOrdersPage(reset: true),
                child: _loading && _orders.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 200),
                          Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFED1E28),
                            ),
                          ),
                        ],
                      )
                    : _errorMessage != null
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 200),
                          Center(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom + 48,
                        ),
                        itemCount: _filtered.length + (_hasMore ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i >= _filtered.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFED1E28),
                                ),
                              ),
                            );
                          }
                          final order = _filtered[i];
                          final customerName =
                              _customerCache[order.customerId] ??
                              order.customerId;
                          return OrderCard(
                            order: order,
                            customerName: customerName,
                            primaryColor: primaryColor,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminOrderDetailScreen(
                                  order: order,
                                  orderId: order.orderId,
                                ),
                              ),
                            ),
                            onUpdateStatus: (nextStatus) async {
                              try {
                                await _orderService.updateOrderStatus(
                                  order.orderId,
                                  nextStatus,
                                );
                                _loadOrdersPage(reset: true);
                              } catch (_) {}
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
