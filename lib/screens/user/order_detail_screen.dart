import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:toko_telyu/enums/payment_status.dart';
import 'package:toko_telyu/enums/transaction_status.dart';
import 'package:toko_telyu/models/order_item_model.dart';
import 'package:toko_telyu/models/order_model.dart';
import 'package:toko_telyu/models/payment_model.dart';

import 'package:toko_telyu/screens/user/chatbot_screen.dart';
import 'package:toko_telyu/screens/user/payment_screen.dart';
import 'package:toko_telyu/screens/user/track_order_screen.dart';

import 'package:toko_telyu/services/order_services.dart';
import 'package:toko_telyu/services/payment_services.dart';
import 'package:toko_telyu/services/product_services.dart';

import 'package:toko_telyu/widgets/formatted_price.dart';
import 'package:toko_telyu/widgets/product_image.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _orderService = OrderService();
  final _productService = ProductService();
  final _paymentService = PaymentService();

  OrderModel? order;
  PaymentModel? payment;
  List<OrderItem> items = [];
  final Map<String, Map<String, String>> products = {};

  bool loading = true;
  bool get isPaymentPending => order?.paymentStatus == PaymentStatus.pending;
  bool get isPaymentCompleted =>
      order?.paymentStatus == PaymentStatus.completed;
  bool get canTrack => order?.orderStatus == TransactionStatus.outForDelivery;
  bool _showAllProducts = false;

  static const _primaryRed = Color(0xFFED1E28);
  static const _bgGrey = Color(0xFFF2F2F2);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _orderService.getOrderWithItems(widget.orderId);
      order = data['order'];
      items = data['items'];

      payment = await _paymentService.getPaymentByOrder(widget.orderId);

      for (final i in items) {
        final p = await _productService.getProduct(i.productId);
        final imgs = await _productService.getImages(i.productId);
        products[i.productId] = {
          'name': p.productName,
          'image': imgs.isNotEmpty
              ? imgs.first.imageUrl
              : 'assets/placeholder.png',
          'price': p.price.toString(),
        };
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String get _bottomText {
    if (isPaymentPending) return 'Check Payment Status';
    if (canTrack) return 'Track Order';
    if (isCompleted) return 'Reorder';
    return '';
  }

  VoidCallback? get _bottomAction {
    if (isPaymentPending) {
      return () async {
        final updated = await _orderService.getOrderById(order!.orderId);
        if (!mounted) return;
        setState(() => order = updated);
      };
    }

    if (canTrack) {
      return () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrackOrderScreen(orderId: order!.orderId),
          ),
        );
      };
    }

    if (isCompleted) {
      return () {};
    }

    return null;
  }

  List<OrderItem> get _visibleItems {
    if (_showAllProducts || items.length <= 2) return items;
    return items.take(2).toList();
  }

  bool get _canShowMore => items.length > 2;

  bool get isPending => order?.paymentStatus == PaymentStatus.pending;
  bool get isCompleted => order?.orderStatus == TransactionStatus.completed;

  double get subtotal => items.fold(0, (s, i) => s + i.subtotal);
  double get total => subtotal + order!.shippingCost + 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGrey,
      appBar: _appBar(),
      body: loading ? _skeleton() : _content(),
      bottomNavigationBar: _bottomCTA(),
    );
  }

  // ===================== APP BAR =====================

  AppBar _appBar() => AppBar(
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
    actions: [
      IconButton(
        icon: const Icon(Icons.chat_bubble_outline, color: _primaryRed),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
        ),
      ),
    ],
  );

  // ===================== CONTENT =====================

  Widget _content() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _orderStatus(),
        _productDetails(),
        _paymentDetails(),
        _helpSection(),
      ],
    );
  }

  // ===================== SECTIONS =====================

  Widget _orderStatus() => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 22, color: _primaryRed),
            const SizedBox(width: 8),
            Text(
              isPaymentPending
                  ? 'Payment Pending'
                  : isCompleted
                  ? 'Order Completed'
                  : 'Order Processing',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Divider(height: 24),
        _row(
          'Purchase Date',
          '${order!.orderDate.day} November 2025, 12:46 WIB',
        ),
      ],
    ),
  );

  Widget _productDetails() => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Product Details'),
        const SizedBox(height: 12),

        ..._visibleItems.map(_productRow),

        if (_canShowMore)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () =>
                  setState(() => _showAllProducts = !_showAllProducts),
              child: Text(
                _showAllProducts ? 'Show less' : 'Show more',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _primaryRed,
                ),
              ),
            ),
          ),

        Align(
          alignment: Alignment.centerRight,
          child: _smallButton(
            isPaymentPending ? 'Pay Now' : 'Reorder',
            onTap: isPaymentPending && payment != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(
                          orderId: order!.orderId,
                          transactionToken: payment!.midtransTransactionId,
                          redirectUrl: payment!.paymentUrl ?? '',
                        ),
                      ),
                    );
                  }
                : null,
          ),
        ),
      ],
    ),
  );

  Widget _paymentDetails() => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Payment Details'),
        const SizedBox(height: 8),
        _row('Payment Method', order!.paymentStatus.name.toUpperCase()),
        const Divider(),
        _priceRow('Item Subtotal', subtotal),
        _priceRow('Total Shipping Cost', order!.shippingCost),
        _priceRow('Service Fee', 1000),
        const Divider(),
        _priceRow('Order Total', total, bold: true),
      ],
    ),
  );

  Widget _helpSection() => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Help'),
        const SizedBox(height: 12),

        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatbotScreen()),
          ),
          child: Row(
            children: [
              const Icon(Icons.headset_mic, size: 22),
              const SizedBox(width: 12),

              const Text(
                'TOKTEL AI',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),

              const Spacer(),

              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ],
    ),
  );

  // ===================== BOTTOM CTA =====================

  Widget _bottomCTA() => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _bottomAction,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryRed,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          _bottomText,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );

  // ===================== SMALL WIDGETS =====================

  Widget _productRow(OrderItem item) {
    final p = products[item.productId]!;

    final price = double.parse(p['price']!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ProductImage(imageUrl: p['image']!, size: 64),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['name']!,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${item.amount} x '),
                    FormattedPrice(
                      price: price,
                      size: 12,
                      fontWeight: FontWeight.normal,
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

  Widget _row(String l, String v) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(l, style: const TextStyle(color: Colors.grey)),
      Text(v),
    ],
  );

  Widget _priceRow(String l, double v, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(l),
      FormattedPrice(
        price: v,
        size: bold ? 16 : 13,
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
      ),
    ],
  );

  Widget _sectionTitle(String t) => Text(
    t,
    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
  );

  Widget _smallButton(String t, {VoidCallback? onTap}) => ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: _primaryRed,
      foregroundColor: Colors.white,
      minimumSize: const Size(110, 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      elevation: 0,
    ),
    child: Text(
      t,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );

  Widget _card(Widget c) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(16),
    color: Colors.white,
    child: c,
  );

  Widget _skeleton() => const Center(child: CircularProgressIndicator());
}
