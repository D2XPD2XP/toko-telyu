import 'package:flutter/material.dart';
import 'package:toko_telyu/screens/admin/orders_screen.dart';

class OrderFilterWidget extends StatefulWidget {
  final OrderFilter initial;
  final ValueChanged<OrderFilter> onChanged;

  const OrderFilterWidget({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<OrderFilterWidget> createState() => _OrderFilterWidgetState();
}

class _OrderFilterWidgetState extends State<OrderFilterWidget> {
  late OrderFilter _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: OrderFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final filter = OrderFilter.values[i];
          final active = filter == _selected;

          return GestureDetector(
            onTap: () {
              setState(() => _selected = filter);
              widget.onChanged(filter);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? Colors.red.shade100 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? Colors.red.shade400 : Colors.red.shade200,
                ),
              ),
              child: Text(
                _label(filter),
                style: TextStyle(
                  color: active ? Colors.red.shade700 : Colors.red.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _label(OrderFilter filter) {
    switch (filter) {
      case OrderFilter.all:
        return 'All';
      case OrderFilter.waitingPayment:
        return 'Waiting Payment';
      case OrderFilter.pending:
        return 'Processing';
      case OrderFilter.readyForPickup:
        return 'Pickup Ready';
      case OrderFilter.outForDelivery:
        return 'Delivering';
      case OrderFilter.completed:
        return 'Completed';
      case OrderFilter.cancelled:
        return 'Cancelled';
    }
  }
}
