import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/enums/shipping_method.dart';
import 'package:toko_telyu/models/cart_item.dart';
import 'package:toko_telyu/models/delivery_area.dart';
import 'package:toko_telyu/models/order_item_model.dart';
import 'package:toko_telyu/models/user.dart';
import 'package:toko_telyu/screens/user/edit_address_screen.dart';
import 'package:toko_telyu/screens/user/payment_screen.dart';
import 'package:toko_telyu/services/delivery_area_services.dart';
import 'package:toko_telyu/services/order_services.dart';
import 'package:toko_telyu/services/product_services.dart';
import 'package:toko_telyu/services/user_services.dart';
import 'package:toko_telyu/widgets/checkout/checkout_payment_detail.dart';
import 'package:toko_telyu/widgets/checkout/checkout_product_item.dart';
import 'package:toko_telyu/widgets/checkout/checkout_shipping_card.dart';
import 'package:toko_telyu/widgets/checkout/checkout_status_overlay.dart';
import 'package:toko_telyu/widgets/shipping_address_sheet.dart';

// =======================================================
// CHECKOUT TOTAL MODEL
// =======================================================
class CheckoutTotals {
  final double subtotal;
  final double shippingCost;
  final double serviceFee;
  final double grandTotal;

  const CheckoutTotals({
    required this.subtotal,
    required this.shippingCost,
    required this.serviceFee,
    required this.grandTotal,
  });
}

// =======================================================
// CHECKOUT SCREEN
// =======================================================
class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // ===================== SERVICES =====================
  final UserService _userService = UserService();
  final ProductService _productService = ProductService();
  final DeliveryAreaService _deliveryAreaService = DeliveryAreaService();
  final OrderService _orderService = OrderService();

  // ===================== CONSTANTS =====================
  static const Color _primaryRed = Color(0xFFED1E28);
  static const Color _bgGrey = Color(0xFFF5F5F5);
  static const double _serviceFee = 1000;

  // ===================== STATE =====================
  User? _user;
  bool _loading = false;

  bool _showSuccessOverlay = false;
  bool _showErrorOverlay = false;
  String _errorMessage = "";

  ShippingMethod _shippingMethod = ShippingMethod.delivery;
  DeliveryArea? _selectedAddress;
  Map<String, dynamic>? _currentAddress;

  final List<Widget> _productWidgets = [];
  List<DeliveryArea> _deliveryAreas = [];

  // ===================== LIFECYCLE =====================
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // ===================================================
  // DATA LOADING
  // ===================================================
  Future<void> _loadInitialData() async {
    setState(() => _loading = true);

    _user = await _userService.loadUser();
    await Future.wait([_loadCheckoutProducts(), _loadDeliveryAreas()]);

    _currentAddress = _user?.address;

    setState(() => _loading = false);
  }

  Future<void> _loadCheckoutProducts() async {
    _productWidgets.clear();

    for (final item in widget.cartItems) {
      final product = await _productService.getProduct(item.productId);
      final images = await _productService.getImages(item.productId);
      final variants = await _productService.getVariants(item.productId);

      final variant = variants.firstWhere((v) => v.variantId == item.variantId);

      _productWidgets.add(
        CheckoutProductItem(
          product: product,
          variant: variant,
          image: images.first,
          qty: item.amount,
        ),
      );
    }
  }

  Future<void> _loadDeliveryAreas() async {
    _deliveryAreas = await _deliveryAreaService.fetchAllAreas();
    if (_deliveryAreas.isNotEmpty) {
      _selectedAddress = _deliveryAreas.first;
    }
  }

  // ===================================================
  // SHIPPING
  // ===================================================
  void _onShippingConfirmed(
    ShippingMethod method,
    DeliveryArea? area,
    Map<String, dynamic>? address,
  ) {
    setState(() {
      _shippingMethod = method;
      _selectedAddress = area;
      _currentAddress = address;
    });
  }

  void _openShippingSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShippingAddressSheet(
        deliveryArea: _deliveryAreas,
        currentSelection: _selectedAddress ?? _deliveryAreas.first,
        currentAddress: _user!.address,
        shippingMethod: _shippingMethod,
        onConfirm: _onShippingConfirmed,
      ),
    );
  }

  // ===================================================
  // TOTAL CALCULATION
  // ===================================================
  CheckoutTotals _calculateTotals() {
    final subtotal = widget.cartItems.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    final shippingCost = _resolveShippingCost();

    return CheckoutTotals(
      subtotal: subtotal,
      shippingCost: shippingCost,
      serviceFee: _serviceFee,
      grandTotal: subtotal + shippingCost + _serviceFee,
    );
  }

  double _resolveShippingCost() {
    switch (_shippingMethod) {
      case ShippingMethod.directDelivery:
        return _selectedAddress?.getDeliveryfee() ?? 0;
      case ShippingMethod.delivery:
        return 3000;
      case ShippingMethod.pickup:
        return 0;
    }
  }

  // ===================================================
  // CHECKOUT PROCESS
  // ===================================================
  Future<void> _processCheckout(CheckoutTotals totals) async {
    setState(() => _loading = true);

    try {
      final items = widget.cartItems
          .map(
            (cartItem) => OrderItem(
              orderItemId: "",
              productId: cartItem.productId,
              variantId: cartItem.variantId,
              subtotal: cartItem.subtotal,
              amount: cartItem.amount,
            ),
          )
          .toList();

      final result = await _orderService.checkout(
        customerId: _user!.userId,
        items: items,
        totalAmount: totals.grandTotal,
        customerName: _user!.name,
        customerEmail: _user!.email,
        shippingAddress: _currentAddress ?? {},
        shippingMethod: _shippingMethod,
        shippingCost: totals.shippingCost,
      );

      if (!mounted) return;

      setState(() => _showSuccessOverlay = true);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            orderId: result.orderId,
            transactionToken: result.transactionToken,
            redirectUrl: result.redirectUrl,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _showErrorOverlay = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) setState(() => _showErrorOverlay = false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ===================================================
  // UI
  // ===================================================
  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: _bgGrey,
          appBar: _buildAppBar(),
          body: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: _primaryRed),
                )
              : SingleChildScrollView(child: _buildBody(totals)),
          bottomNavigationBar: _buildBottomBar(totals),
        ),

        CheckoutStatusOverlay(
          visible: _showSuccessOverlay,
          icon: Icons.check_circle,
          iconColor: Colors.green,
          title: "Checkout Successful",
          message:
              "Your order is confirmed. Proceed to payment to complete the checkout.",
        ),

        CheckoutStatusOverlay(
          visible: _showErrorOverlay,
          icon: Icons.error,
          iconColor: Colors.red,
          title: "Checkout Failed",
          message: _errorMessage,
        ),
      ],
    );
  }

  // ===================================================
  // APP BAR
  // ===================================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Checkout",
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  // ===================================================
  // BODY
  // ===================================================
  Widget _buildBody(CheckoutTotals totals) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProductList(),
          const SizedBox(height: 16),

          CheckoutShippingCard(
            method: _shippingMethod,
            area: _selectedAddress,
            address: _currentAddress,
            onTap: _openShippingSelector,
          ),

          const SizedBox(height: 16),

          CheckoutPaymentDetail(
            subtotal: totals.subtotal,
            shippingCost: totals.shippingCost,
            serviceFee: totals.serviceFee,
            grandTotal: totals.grandTotal,
            shippingMethod: _shippingMethod,
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _productWidgets.length,
      itemBuilder: (_, i) => _productWidgets[i],
    );
  }

  // ===================================================
  // BOTTOM BAR (SAFE AREA)
  // ===================================================
  Widget _buildBottomBar(CheckoutTotals totals) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (_shippingMethod == ShippingMethod.delivery &&
                  (_currentAddress?["street"] == null ||
                      _currentAddress!["street"].toString().isEmpty)) {
                _showEmptyAddressWarning();
                return;
              }

              await _processCheckout(totals);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Check Out",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===================================================
  // DIALOG
  // ===================================================
  void _showEmptyAddressWarning() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Address Required"),
        content: const Text(
          "To use delivery, please complete your address first.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditAddressScreen(
                    userId: _user!.userId,
                    value: _user!.address,
                    onTap: _userService.handleAddress,
                  ),
                ),
              );
            },
            child: const Text("Edit Address"),
          ),
        ],
      ),
    );
  }
}
