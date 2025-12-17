import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toko_telyu/models/order_model.dart';
import 'package:toko_telyu/enums/transaction_status.dart';
import 'package:toko_telyu/enums/shipping_method.dart';
import 'package:toko_telyu/services/order_services.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final Color primaryColor = const Color(0xFFED1E28);
  final OrderService _service = OrderService();

  late OrderModel _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
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

  TransactionStatus? _nextStatus() {
    final current = _order.orderStatus;
    final isPickup = _order.shippingMethod == ShippingMethod.pickup;

    if (isPickup) {
      switch (current) {
        case TransactionStatus.pending:
          return TransactionStatus.readyForPickup;
        case TransactionStatus.readyForPickup:
          return TransactionStatus.completed;
        default:
          return null;
      }
    } else {
      switch (current) {
        case TransactionStatus.pending:
          return TransactionStatus.outForDelivery;
        case TransactionStatus.outForDelivery:
          return TransactionStatus.completed;
        default:
          return null;
      }
    }
  }

  void _updateStatus() async {
    final next = _nextStatus();
    if (next == null) return;

    await _service.updateOrderStatus(_order.orderId, next);

    if (!mounted) return; // FIX

    setState(() => _order.orderStatus = next);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Status updated to ${next.name}"),
        backgroundColor: primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(_order.orderDate);
    final totalFormatted = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(_order.totalAmount);

    final isFinished =
        _order.orderStatus == TransactionStatus.completed ||
        _order.orderStatus == TransactionStatus.cancelled;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Order Details",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle("Order Summary"),
            _OrderCard(
              children: [
                _KeyValue("Order ID", _order.orderId),
                _KeyValue("Customer ID", _order.customerId),
                _KeyValue("Date", dateFormatted),
                _KeyValue("Total", totalFormatted, bold: true),
                _StatusBadge(
                  _order.orderStatus.name,
                  _statusColor(_order.orderStatus),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionTitle("Delivery Information"),
            _OrderCard(
              children: [
                _KeyValue("Method", _order.shippingMethod.name),
                if (_order.shippingMethod == ShippingMethod.delivery) ...[
                  _KeyValue(
                    "Address",
                    _order.shippingAddress?['fullAddress'] ?? "Not set",
                  ),
                  const SizedBox(height: 8),
                ],
                if (_order.shippingMethod == ShippingMethod.pickup) ...[
                  _KeyValue("Pickup Point", "Store Kampus - Kantin Utama"),
                  _KeyValue("Pickup Code", _order.orderId, bold: true),
                ],
              ],
            ),
            const SizedBox(height: 24),
            if (!isFinished && _nextStatus() != null)
              _UpdateStatusButton(
                primaryColor: primaryColor,
                nextStatus: _nextStatus()!.name,
                onPressed: _updateStatus,
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final List<Widget> children;
  const _OrderCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String keyText;
  final String valueText;
  final bool bold;

  const _KeyValue(this.keyText, this.valueText, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              keyText,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              valueText,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge(this.status, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Status",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _UpdateStatusButton extends StatelessWidget {
  final Color primaryColor;
  final String nextStatus;
  final VoidCallback onPressed;

  const _UpdateStatusButton({
    required this.primaryColor,
    required this.nextStatus,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: Text(
        "Update Status → $nextStatus",
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
