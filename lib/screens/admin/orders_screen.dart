import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toko_telyu/screens/admin/order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = OrderStatus.all;

  final Color primaryColor = const Color(0xFFED1E28);

  // ============================================================
  // DUMMY ORDERS (SAMA SEPERTI SEBELUMNYA)
  // ============================================================
  final List<Map<String, dynamic>> _orders = [
    {
      "id": "ORD001",
      "customerName": "Budi Santoso",
      "date": DateTime.now().subtract(const Duration(hours: 4)),
      "total": 150000,
      "status": OrderStatus.pending,
      "deliveryType": OrderMethod.pickup,
    },
    {
      "id": "ORD002",
      "customerName": "Siti Aminah",
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "total": 250000,
      "status": OrderStatus.pending,
      "deliveryType": OrderMethod.delivery,
    },
    {
      "id": "ORD003",
      "customerName": "Agus Wijaya",
      "date": DateTime.now(),
      "total": 175000,
      "status": OrderStatus.onDelivery,
      "deliveryType": OrderMethod.delivery,
    },
    {
      "id": "ORD004",
      "customerName": "Dewi Lestari",
      "date": DateTime.now().subtract(const Duration(days: 3)),
      "total": 200000,
      "status": OrderStatus.readyPickup,
      "deliveryType": OrderMethod.pickup,
    },
  ];

  // ============================================================
  // FILTERING
  // ============================================================
  List<Map<String, dynamic>> get _filteredOrders {
    final query = _searchController.text.toLowerCase();

    return _orders.where((order) {
      final matchStatus =
          _selectedStatus == OrderStatus.all ||
          order['status'] == _selectedStatus;

      final matchSearch =
          order['id'].toLowerCase().contains(query) ||
          order['customerName'].toLowerCase().contains(query);

      return matchStatus && matchSearch;
    }).toList();
  }

  // ============================================================
  // STATUS COLORS
  // ============================================================
  Color _statusColor(String status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparingPickup:
        return Colors.amber;
      case OrderStatus.readyPickup:
        return Colors.green;
      case OrderStatus.onDelivery:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // ACCEPT ORDER
  // ============================================================
  void _acceptOrder(Map<String, dynamic> order) {
    setState(() {
      if (order['deliveryType'] == OrderMethod.delivery) {
        order['status'] = OrderStatus.onDelivery;
      } else {
        order['status'] = OrderStatus.preparingPickup;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Order accepted.'),
        backgroundColor: primaryColor,
      ),
    );
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),

            const SizedBox(height: 12),

            _StatusFilterChips(
              selected: _selectedStatus,
              primaryColor: primaryColor,
              onSelected: (value) {
                setState(() => _selectedStatus = value);
              },
            ),

            const SizedBox(height: 12),

            Expanded(child: _buildOrderList()),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // UI COMPONENTS
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Orders",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.grey[100],
      elevation: 0,
      automaticallyImplyLeading: false,
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
    if (_filteredOrders.isEmpty) {
      return const Center(child: Text("No orders found."));
    }

    return ListView.builder(
      itemCount: _filteredOrders.length,
      itemBuilder: (_, index) {
        final order = _filteredOrders[index];
        return _OrderCard(
          order: order,
          primaryColor: primaryColor,
          statusColor: _statusColor(order['status']),
          onDetail: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminOrderDetailScreen(order: order),
              ),
            );
          },
          onAccept: order['status'] == OrderStatus.pending
              ? () => _acceptOrder(order)
              : null,
        );
      },
    );
  }
}

//
// ============================================================
// CONSTANTS
// ============================================================
//
class OrderStatus {
  static const all = "All";
  static const pending = "Pending";
  static const preparingPickup = "Preparing Pickup";
  static const readyPickup = "Ready for Pickup";
  static const onDelivery = "On Delivery";
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

class OrderMethod {
  static const delivery = "Delivery";
  static const pickup = "Pickup";
}

//
// ============================================================
// STATUS FILTER CHIPS
// ============================================================
//
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
              selectedColor: primaryColor.withOpacity(0.2),
              backgroundColor: Colors.white,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}

//
// ============================================================
// ORDER CARD COMPONENT
// ============================================================
//
class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Color primaryColor;
  final Color statusColor;
  final VoidCallback? onAccept;
  final VoidCallback onDetail;

  const _OrderCard({
    required this.order,
    required this.primaryColor,
    required this.statusColor,
    required this.onDetail,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(order['date']);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          Text("Customer: ${order['customerName']}"),
          Text("Date: $dateFormatted"),
          Text("Total: Rp ${order['total']}"),
          const SizedBox(height: 12),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          order['id'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            order['status'],
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: onDetail,
          child: Text("Detail", style: TextStyle(color: primaryColor)),
        ),
        if (onAccept != null)
          ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text("Accept", style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }
}
