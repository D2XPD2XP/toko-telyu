import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toko_telyu/models/order_model.dart';
import 'package:toko_telyu/screens/admin/order_detail_screen.dart';
import 'package:toko_telyu/enums/transaction_status.dart';
import 'package:toko_telyu/enums/shipping_method.dart';
import 'package:toko_telyu/services/order_services.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderService _service = OrderService();
  final TextEditingController _searchController = TextEditingController();
  final Color primaryColor = const Color(0xFFED1E28);

  double get bottomPadding => MediaQuery.of(context).padding.bottom + 50;

  List<OrderModel> _orders = [];
  String _selectedStatus = OrderStatus.all;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    final orders = await _service.getAllOrders();
    setState(() {
      _orders = orders;
      _loading = false;
    });
  }

  // Filtered orders based on search and status
  List<OrderModel> get _filteredOrders {
    final query = _searchController.text.toLowerCase();
    return _orders.where((order) {
      final matchStatus =
          _selectedStatus == OrderStatus.all ||
          order.orderStatus.name == _selectedStatus;
      final matchSearch =
          order.orderId.toLowerCase().contains(query) ||
          (order.customerId.toLowerCase().contains(query));
      return matchStatus && matchSearch;
    }).toList();
  }

  Color _statusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.readyForPickup:
        return Colors.green;
      case TransactionStatus.preparingForDelivery:
        return Colors.yellow;
      case TransactionStatus.outForDelivery:
        return Colors.blue;
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.cancelled:
        return Colors.red;
    }
  }

  void _acceptOrder(OrderModel order) async {
    if (order.shippingMethod == ShippingMethod.delivery) {
      await _service.updateOrderStatus(
        order.orderId,
        TransactionStatus.outForDelivery,
      );
    } else {
      await _service.updateOrderStatus(
        order.orderId,
        TransactionStatus.pending,
      );
    }
    _loadOrders();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Order accepted.'),
        backgroundColor: primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  _StatusFilterChips(
                    selected: _selectedStatus,
                    primaryColor: primaryColor,
                    onSelected: (value) =>
                        setState(() => _selectedStatus = value),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildOrderList()),
                ],
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Orders",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.grey[100],
      elevation: 0,
      automaticallyImplyLeading: false,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "Search order ID / customer...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildOrderList() {
    final filteredOrders = _filteredOrders;
    if (filteredOrders.isEmpty) {
      return const Center(child: Text("No orders found."));
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: bottomPadding),
      itemCount: filteredOrders.length,
      itemBuilder: (_, index) {
        final order = filteredOrders[index];
        final dateFormatted = DateFormat(
          'dd MMM yyyy, HH:mm',
        ).format(order.orderDate);
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderId,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(
                        order.orderStatus,
                      ).withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.orderStatus.name,
                      style: TextStyle(
                        color: _statusColor(order.orderStatus),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text("Customer: ${order.customerId}"),
              Text("Date: $dateFormatted"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total:"),
                  FormattedPrice(
                    price: order.totalAmount.toDouble(),
                    size: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminOrderDetailScreen(order: order),
                        ),
                      );
                    },
                    child: Text(
                      "Detail",
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                  if (order.orderStatus == TransactionStatus.pending)
                    ElevatedButton(
                      onPressed: () => _acceptOrder(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      child: const Text(
                        "Accept",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class OrderStatus {
  static const all = "All";
  static const pending = "Pending";
  static const preparingPickup = "PreparingPickup";
  static const readyPickup = "ReadyPickup";
  static const onDelivery = "OnDelivery";
  static const completed = "Completed";
  static const cancelled = "Cancelled";

  static const filters = [
    all,
    pending,
    preparingPickup,
    readyPickup,
    onDelivery,
    completed,
  ];
}

class _StatusFilterChips extends StatelessWidget {
  final String selected;
  final Color primaryColor;
  final ValueChanged<String> onSelected;

  const _StatusFilterChips({
    required this.selected,
    required this.primaryColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: OrderStatus.filters.map((status) {
          final bool isSelected = selected == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (_) => onSelected(status),
              selectedColor: primaryColor.withAlpha((0.2 * 255).round()),
              backgroundColor: Colors.white,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}
