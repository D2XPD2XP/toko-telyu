import 'package:flutter/material.dart';
import 'package:toko_telyu/enums/payment_status.dart';
import 'package:toko_telyu/enums/shipping_method.dart';
import 'package:toko_telyu/enums/transaction_status.dart';
import 'package:toko_telyu/models/order_model.dart';

class OrderActionButton extends StatefulWidget {
  final OrderModel order;
  final Future<void> Function(TransactionStatus status) onActionCompleted;

  const OrderActionButton({
    super.key,
    required this.order,
    required this.onActionCompleted,
  });

  @override
  State<OrderActionButton> createState() => _OrderActionButtonState();
}

class _OrderActionButtonState extends State<OrderActionButton> {
  static const _color = Color(0xFFED1E28);
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (widget.order.paymentStatus == PaymentStatus.pending) {
      return const SizedBox();
    }

    final nextStatus = _nextStatus(widget.order);
    if (nextStatus == null) return const SizedBox();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : () => _handlePress(nextStatus),
        style: ElevatedButton.styleFrom(
          backgroundColor: _color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(_label(nextStatus)),
      ),
    );
  }

  Future<void> _handlePress(TransactionStatus status) async {
    setState(() => _loading = true);
    try {
      await widget.onActionCompleted(status);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  TransactionStatus? _nextStatus(OrderModel order) {
    return switch (order.orderStatus) {
      TransactionStatus.pending =>
        order.shippingMethod == ShippingMethod.pickup
            ? TransactionStatus.readyForPickup
            : TransactionStatus.outForDelivery,
      TransactionStatus.readyForPickup ||
      TransactionStatus.outForDelivery => TransactionStatus.completed,
      _ => null,
    };
  }

  String _label(TransactionStatus status) {
    return switch (status) {
      TransactionStatus.pending => 'Preparing for Delivery',
      TransactionStatus.readyForPickup => 'Ready for Pickup',
      TransactionStatus.outForDelivery => 'Out for Delivery',
      TransactionStatus.completed => 'Mark as Completed',
      _ => status.name,
    };
  }
}
