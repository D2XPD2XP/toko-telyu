import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toko_telyu/models/delivery_area.dart';
import 'package:toko_telyu/models/order_model.dart';
import 'package:toko_telyu/enums/transaction_status.dart';
import 'package:toko_telyu/enums/shipping_method.dart';
import 'package:toko_telyu/enums/payment_status.dart';
import 'package:toko_telyu/services/delivery_area_services.dart';
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
  final DeliveryAreaService _deliveryAreaService = DeliveryAreaService();
  late OrderModel _order;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  TransactionStatus? _nextStatus() {
    if (_order.paymentStatus == PaymentStatus.pending) return null;
    switch (_order.orderStatus) {
      case TransactionStatus.pending:
        if (_order.shippingMethod == ShippingMethod.delivery) {
          return TransactionStatus.preparingForDelivery;
        } else if (_order.shippingMethod == ShippingMethod.pickup) {
          return TransactionStatus.readyForPickup;
        } else if (_order.shippingMethod == ShippingMethod.directDelivery) {
          return TransactionStatus.outForDelivery;
        }
        return null;
      case TransactionStatus.preparingForDelivery:
      case TransactionStatus.outForDelivery:
        return TransactionStatus.completed;
      case TransactionStatus.readyForPickup:
        return TransactionStatus.completed;
      default:
        return null;
    }
  }

  String _statusLabel(TransactionStatus status) {
    if (_order.paymentStatus == PaymentStatus.pending) {
      return "Waiting for Payment";
    }
    switch (status) {
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

  String formatShippingAddress(Map<String, dynamic>? address) {
    if (address == null) return "Not set";
    final street = address['street'] ?? '';
    final district = address['district'] ?? '';
    final city = address['city'] ?? '';
    final province = address['province'] ?? '';
    final postalCode = address['postal_code'] ?? '';
    final parts = [
      street,
      district,
      city,
      province,
      postalCode,
    ].where((p) => p.isNotEmpty).toList();
    return parts.join(', ');
  }

  String displayShippingMethod(ShippingMethod method) {
    switch (method) {
      case ShippingMethod.delivery:
        return "Delivery";
      case ShippingMethod.pickup:
        return "Pickup";
      case ShippingMethod.directDelivery:
        return "Direct Delivery";
    }
  }

  Future<void> _updateStatus() async {
    final next = _nextStatus();
    if (next == null) return;
    setState(() => _loading = true);
    try {
      await _service.updateOrderStatus(_order.orderId, next);
      if (!mounted) return;
      setState(() => _order.orderStatus = next);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Status updated to ${_statusLabel(next)}"),
          backgroundColor: primaryColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update status: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
    final nextStatus = _nextStatus();

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
                  _statusLabel(_order.orderStatus),
                  _statusColor(_statusLabel(_order.orderStatus)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionTitle("Delivery Information"),
            _OrderCard(
              children: [
                _KeyValue(
                  "Method",
                  displayShippingMethod(_order.shippingMethod),
                ),
                if (_order.shippingMethod == ShippingMethod.delivery)
                  _KeyValue(
                    "Address",
                    formatShippingAddress(_order.shippingAddress),
                  )
                else if (_order.shippingMethod == ShippingMethod.directDelivery)
                  FutureBuilder<DeliveryArea?>(
                    future: _deliveryAreaService.fetchArea(
                      _order.deliveryAreaId!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _KeyValue("Delivery Area", "Loading...");
                      } else if (snapshot.hasError || snapshot.data == null) {
                        return _KeyValue("Delivery Area", "Not set");
                      } else {
                        return _KeyValue(
                          "Delivery Area",
                          snapshot.data!.getAreaname(),
                        );
                      }
                    },
                  ),

                if (_order.shippingMethod == ShippingMethod.pickup) ...[
                  _KeyValue("Pickup Point", "Store Kampus - Kantin Utama"),
                  _KeyValue("Pickup Code", _order.orderId, bold: true),
                ],
              ],
            ),
            const SizedBox(height: 24),
            if (!isFinished && nextStatus != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _updateStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                          "Update Status → ${_statusLabel(nextStatus)}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
            color: color.withOpacity(0.15),
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
