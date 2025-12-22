import 'package:flutter/material.dart';
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

  final Color primaryColor = const Color(0xFFED1E28);

  final Map<String, String> _customerCache = {};
  List<OrderModel> _orders = [];

  bool _loading = true;
  OrderFilter _filter = OrderFilter.pending;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final orders = await _orderService.getAllOrders();
    _orders = orders;

    for (final o in orders) {
      if (_customerCache.containsKey(o.customerId)) continue;
      final user = await _userService.getUser(o.customerId);
      _customerCache[o.customerId] = user?.name ?? 'Unknown User';
    }

    setState(() => _loading = false);
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
          return o.paymentStatus == PaymentStatus.completed &&
              o.orderStatus == TransactionStatus.pending;

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
              onChanged: (_) => setState(() {}),
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
              onChanged: (f) => setState(() => _filter = f),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                color: primaryColor,
                onRefresh: _load,
                child: _loading
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
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom + 48,
                        ),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final order = _filtered[i];
                          return OrderCard(
                            order: order,
                            customerName:
                                _customerCache[order.customerId] ??
                                order.customerId,
                            primaryColor: primaryColor,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AdminOrderDetailScreen(order: order),
                              ),
                            ),
                            onUpdateStatus: (nextStatus) async {
                              await _orderService.updateOrderStatus(
                                order.orderId,
                                nextStatus,
                              );
                              await _load();
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
