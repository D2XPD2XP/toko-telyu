import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:toko_telyu/enums/payment_status.dart';
import 'package:toko_telyu/enums/transaction_status.dart';
import 'package:toko_telyu/models/order_item_model.dart';
import 'package:toko_telyu/models/order_model.dart';
import 'package:toko_telyu/models/payment_model.dart';
import 'package:toko_telyu/models/product_variant.dart';

import 'package:toko_telyu/screens/user/chatbot_screen.dart';
import 'package:toko_telyu/screens/user/payment_screen.dart';
import 'package:toko_telyu/screens/user/product_details_screen.dart';

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
  final Map<String, ProductVariant?> variants = {};

  bool loading = true;
  bool error = false;
  bool _showAllProducts = false;

  static const _primaryRed = Color(0xFFED1E28);
  static const _bgGrey = Color(0xFFF2F2F2);

  bool get isPaymentPending => order?.paymentStatus == PaymentStatus.pending;

  bool get isCompleted => order?.orderStatus == TransactionStatus.completed;

  bool get canTrack => order?.orderStatus == TransactionStatus.outForDelivery;

  bool get showBottomCTA => isPaymentPending || isCompleted;

  String getOrderStatusText({
    required PaymentStatus paymentStatus,
    required TransactionStatus status,
  }) {
    if (paymentStatus == PaymentStatus.pending) {
      return 'Awaiting Payment';
    }

    if (paymentStatus == PaymentStatus.failed) {
      return 'Cancelled';
    }

    switch (status) {
      case TransactionStatus.pending:
        return 'Preparing Order';

      case TransactionStatus.readyForPickup:
        return 'Ready for Pickup';

      case TransactionStatus.outForDelivery:
        return 'Out for Delivery';

      case TransactionStatus.completed:
        return 'Completed';

      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

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
          'price': p.price.toString(),
          'image': imgs.isNotEmpty
              ? imgs.first.imageUrl
              : 'assets/placeholder.png',
        };

        final variant = await _productService.getVariantById(
          i.productId,
          i.variantId,
        );
        variants[i.orderItemId] = variant;
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
      appBar: _appBar(),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: _primaryRed))
          : error
          ? _errorState()
          : _content(),
      bottomNavigationBar: showBottomCTA ? _bottomCTA() : null,
    );
  }

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

  Widget _content() => ListView(
    padding: const EdgeInsets.only(bottom: 80),
    children: [
      _orderStatus(),
      _productDetails(),
      _paymentDetails(),
      _helpSection(),
    ],
  );

  Widget _orderStatus() => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 20, color: _primaryRed),
            const SizedBox(width: 8),
            Text(
              getOrderStatusText(
                paymentStatus: order!.paymentStatus,
                status: order!.orderStatus,
              ),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const Divider(height: 20),
        _row('Order Code', order!.orderId),
        _row(
          'Purchase Date',
          DateFormat('dd MMMM yyyy').format(order!.orderDate),
        ),
      ],
    ),
  );

  Widget _productDetails() => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Product Details'),
        const SizedBox(height: 8),
        ..._visibleItems.map(_productRow),
        if (items.length > 2)
          TextButton(
            onPressed: () =>
                setState(() => _showAllProducts = !_showAllProducts),
            child: Text(
              _showAllProducts ? 'Show less' : 'Show more',
              style: const TextStyle(color: _primaryRed),
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
        _row('Payment Status', order!.paymentStatus.name.toUpperCase()),
        const Divider(),
        _priceRow('Item Subtotal', subtotal),
        _priceRow('Shipping', order!.shippingCost),
        _priceRow('Service Fee', 1000),
        const Divider(),
        _priceRow('Order Total', total, bold: true),
      ],
    ),
  );

  Widget _helpSection() => _card(
    InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatbotScreen()),
      ),
      child: Row(
        children: const [
          Icon(Icons.headset_mic),
          SizedBox(width: 12),
          Text('TOKTEL AI', style: TextStyle(fontWeight: FontWeight.w600)),
          Spacer(),
          Icon(Icons.chevron_right),
        ],
      ),
    ),
  );

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
          elevation: 0,
        ),
        child: Text(
          isPaymentPending ? 'Pay Now' : 'Reorder',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );

  VoidCallback? get _bottomAction {
    if (isPaymentPending && payment != null) {
      return () {
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
      };
    }

    if (isCompleted && items.isNotEmpty) {
      return () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailsScreen(productId: items.first.productId),
          ),
        );
      };
    }
    return null;
  }

  Widget _productRow(OrderItem item) {
    final p = products[item.productId]!;
    final basePrice = double.parse(p['price']!);
    final variant = variants[item.orderItemId];
    final variantName = variant?.optionName ?? '';
    final totalPrice = basePrice + (variant?.additionalPrice ?? 0);

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
                if (variantName.isNotEmpty)
                  Text(
                    'Variant: $variantName',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                Row(
                  children: [
                    Text('${item.amount} x '),
                    FormattedPrice(
                      price: totalPrice,
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
          width: 110,
          child: Text(label, style: const TextStyle(color: Colors.grey)),
        ),
        const Spacer(),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    ),
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
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  );

  Widget _card(Widget c) => Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 8),
    color: Colors.white,
    child: c,
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
            _load();
          },
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
