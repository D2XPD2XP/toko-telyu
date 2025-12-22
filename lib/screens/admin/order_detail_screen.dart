import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:toko_telyu/models/order_item_model.dart';
import 'package:toko_telyu/models/order_model.dart';
import 'package:toko_telyu/services/order_services.dart';
import 'package:toko_telyu/services/product_services.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';
import 'package:toko_telyu/widgets/product_image.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final String orderId;
  const AdminOrderDetailScreen({
    super.key,
    required this.orderId,
    required OrderModel order,
  });

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final _orderService = OrderService();
  final _productService = ProductService();

  OrderModel? order;
  List<OrderItem> items = [];
  final Map<String, Map<String, String>> products = {};
  bool loading = true;
  bool error = false;
  bool _showAllProducts = false;

  static const _primaryRed = Color(0xFFED1E28);
  static const _bgGrey = Color(0xFFF2F2F2);

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      final data = await _orderService.getOrderWithItems(widget.orderId);
      order = data['order'];
      items = data['items'];
      for (final i in items) {
        final p = await _productService.getProduct(i.productId);
        final imgs = await _productService.getImages(i.productId);
        products[i.productId] = {
          'name': p.productName,
          'price': p.price.toString(),
          'image': imgs.isNotEmpty
              ? imgs.first.imageUrl
              : 'assets/placeholder.png',
        };
      }
    } catch (_) {
      error = true;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  List<OrderItem> get _visibleItems {
    if (_showAllProducts || items.length <= 2) return items;
    return items.take(2).toList();
  }

  double get subtotal => items.fold(0, (s, i) => s + i.subtotal);
  double get total => subtotal + (order?.shippingCost ?? 0) + 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'Order Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: _primaryRed))
          : error
          ? _errorState()
          : _content(),
    );
  }

  Widget _content() => ListView(
    padding: const EdgeInsets.all(16),
    children: [_orderInfoCard(), _productDetailsCard(), _paymentCard()],
  );

  Widget _orderInfoCard() => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Information',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        _row('Order ID', order!.orderId),
        _row('Order Date', DateFormat('dd MMMM yyyy').format(order!.orderDate)),
        _row('Shipping Cost', order!.shippingCost.toString()),
        _row('Total', total.toString()),
      ],
    ),
  );

  Widget _productDetailsCard() => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Products', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ..._visibleItems.map(_productRow),
        if (items.length > 2)
          TextButton(
            onPressed: () =>
                setState(() => _showAllProducts = !_showAllProducts),
            child: Text(
              _showAllProducts ? 'Show Less' : 'Show More',
              style: const TextStyle(color: _primaryRed),
            ),
          ),
      ],
    ),
  );

  Widget _paymentCard() => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Details',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        _row('Payment Status', order!.paymentStatus.name.toUpperCase()),
        _row('Order Status', order!.orderStatus.name.toUpperCase()),
        _priceRow('Subtotal', subtotal),
        _priceRow('Shipping', order!.shippingCost),
        _priceRow('Service Fee', 1000),
        const Divider(),
        _priceRow('Total', total, bold: true),
      ],
    ),
  );

  Widget _productRow(OrderItem item) {
    final p = products[item.productId]!;
    final price = double.parse(p['price']!);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ProductImageView(imageUrl: p['image']!, size: 56),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['name']!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Text('${item.amount} x '),
                    FormattedPrice(
                      price: price,
                      size: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(color: Colors.grey)),
        ),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    ),
  );

  Widget _priceRow(String label, double value, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label),
      FormattedPrice(
        price: value,
        size: bold ? 16 : 13,
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
      ),
    ],
  );

  Widget _card(Widget child) => Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 8),
    color: Colors.white,
    child: child,
  );

  Widget _errorState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Failed to load order'),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            setState(() {
              loading = true;
              error = false;
            });
            _loadOrder();
          },
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
