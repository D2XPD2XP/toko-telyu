import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toko_telyu/enums/payment_status.dart';
import 'package:toko_telyu/enums/shipping_method.dart';
import 'package:toko_telyu/enums/transaction_status.dart';
import 'package:toko_telyu/models/order_model.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';

class OrderCard extends StatefulWidget {
  final OrderModel order;
  final String customerName;
  final Color primaryColor;
  final VoidCallback onTap;
  final Future<void> Function(TransactionStatus nextStatus) onUpdateStatus;

  const OrderCard({
    super.key,
    required this.order,
    required this.customerName,
    required this.primaryColor,
    required this.onTap,
    required this.onUpdateStatus,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final statusText = _displayStatus(widget.order);
    final nextStatus = _nextStatus(widget.order);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(statusText),
            const SizedBox(height: 8),
            Text("Customer: ${widget.customerName}"),
            Text(
              DateFormat('dd MMM yyyy, HH:mm').format(widget.order.orderDate),
            ),
            const SizedBox(height: 6),
            _totalRow(),
            if (nextStatus != null) ...[
              const SizedBox(height: 12),
              _actionButton(nextStatus),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.order.orderId,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(status).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: _statusColor(status),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _totalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Total"),
        FormattedPrice(
          price: widget.order.totalAmount,
          size: 14,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  Widget _actionButton(TransactionStatus nextStatus) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading
            ? null
            : () async {
                setState(() => _loading = true);
                try {
                  await widget.onUpdateStatus(nextStatus);
                } finally {
                  if (mounted) {
                    setState(() => _loading = false);
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                _label(nextStatus),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  TransactionStatus? _nextStatus(OrderModel order) {
    if (order.paymentStatus == PaymentStatus.pending) return null;

    switch (order.orderStatus) {
      case TransactionStatus.pending:
        return order.shippingMethod == ShippingMethod.delivery
            ? TransactionStatus.preparingForDelivery
            : TransactionStatus.readyForPickup;

      case TransactionStatus.preparingForDelivery:
        return TransactionStatus.outForDelivery;

      case TransactionStatus.readyForPickup:
      case TransactionStatus.outForDelivery:
        return TransactionStatus.completed;

      default:
        return null;
    }
  }

  String _label(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.preparingForDelivery:
        return "Preparing for Delivery";
      case TransactionStatus.readyForPickup:
        return "Ready for Pickup";
      case TransactionStatus.outForDelivery:
        return "Out for Delivery";
      case TransactionStatus.completed:
        return "Mark as Completed";
      default:
        return status.name;
    }
  }

  String _displayStatus(OrderModel order) {
    if (order.paymentStatus == PaymentStatus.pending) {
      return "Waiting for Payment";
    }

    switch (order.orderStatus) {
      case TransactionStatus.pending:
        return "Processing Order";
      case TransactionStatus.preparingForDelivery:
        return "Preparing for Delivery";
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

  Color _statusColor(String status) {
    switch (status) {
      case "Waiting for Payment":
        return Colors.orange;
      case "Processing Order":
        return Colors.blue;
      case "Preparing for Delivery":
        return Colors.amber.shade700;
      case "Ready for Pickup":
        return Colors.green.shade700;
      case "Out for Delivery":
        return Colors.blue.shade700;
      case "Completed":
        return Colors.green;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
