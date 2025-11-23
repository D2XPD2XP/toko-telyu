import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final Color primaryColor = const Color(0xFFED1E28);

  static const String methodDelivery = "Delivery";
  static const String methodPickup = "Pickup";

  static const String sPending = "Pending";
  static const String sPreparingPickup = "Preparing Pickup";
  static const String sReadyPickup = "Ready for Pickup";
  static const String sOnDelivery = "On Delivery";
  static const String sCompleted = "Completed";
  static const String sCancelled = "Cancelled";

  // =============================================================
  // STATUS → COLOR
  // =============================================================
  Color _statusColor(String status) {
    switch (status) {
      case sPending:
        return Colors.orange;
      case sPreparingPickup:
        return Colors.amber;
      case sReadyPickup:
        return Colors.green;
      case sOnDelivery:
        return Colors.blue;
      case sCompleted:
        return Colors.green;
      case sCancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // =============================================================
  // STATUS → NEXT-STATUS LOGIC
  // =============================================================
  String _nextStatus(String current, String deliveryType) {
    final isPickup = deliveryType == methodPickup;

    if (isPickup) {
      return {
            sPending: sPreparingPickup,
            sPreparingPickup: sReadyPickup,
            sReadyPickup: sCompleted,
          }[current] ??
          current;
    }

    return {sPending: sOnDelivery, sOnDelivery: sCompleted}[current] ?? current;
  }

  // =============================================================
  // MAIN UI
  // =============================================================
  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    final String dateFormatted = DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(order['date'] as DateTime);

    final String totalFormatted = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(order['total']);

    final String currentStatus = order['status'];
    final bool isFinished =
        currentStatus == sCompleted || currentStatus == sCancelled;

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
            // ORDER SUMMARY
            _SectionTitle("Order Summary"),
            _OrderCard(
              children: [
                _KeyValue("Order ID", order['id']),
                _KeyValue("Customer", order['customerName']),
                _KeyValue("Date", dateFormatted),
                _KeyValue("Total", totalFormatted, bold: true),
                _StatusBadge(currentStatus, _statusColor(currentStatus)),
              ],
            ),

            const SizedBox(height: 20),

            // DELIVERY INFORMATION
            _SectionTitle("Delivery Information"),
            _OrderCard(
              children: [
                _KeyValue("Method", order['deliveryType']),

                if (order['deliveryType'] == methodDelivery) ...[
                  _KeyValue("Address", "Jalan Mawar No. 123 (contoh)"),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "See on Google Maps",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],

                if (order['deliveryType'] == methodPickup) ...[
                  _KeyValue("Pickup Point", "Store Kampus - Kantin Utama"),
                  _KeyValue("Pickup Code", order['id'], bold: true),
                ],
              ],
            ),

            const SizedBox(height: 24),

            // UPDATE STATUS BUTTON
            if (!isFinished)
              _UpdateStatusButton(
                primaryColor: primaryColor,
                nextStatus: _nextStatus(currentStatus, order['deliveryType']),
                onPressed: () {
                  final next = _nextStatus(
                    currentStatus,
                    order['deliveryType'],
                  );

                  setState(() => order['status'] = next);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Status updated to $next"),
                      backgroundColor: primaryColor,
                    ),
                  );
                },
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

//
// =============================================================
// REUSABLE COMPONENTS (PRIVATE WIDGETS)
// =============================================================
//

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
