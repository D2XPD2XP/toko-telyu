import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/enums/shipping_method.dart';
import 'package:toko_telyu/models/cart_item.dart';
import 'package:toko_telyu/models/delivery_area.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_image.dart';
import 'package:toko_telyu/models/product_variant.dart';
import 'package:toko_telyu/models/user.dart';
import 'package:toko_telyu/services/delivery_area_services.dart';
import 'package:toko_telyu/services/product_services.dart';
import 'package:toko_telyu/services/user_services.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';
import 'package:toko_telyu/widgets/shipping_address_sheet.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Color primaryRed = const Color(0xFFED1E28);
  final Color bgGrey = const Color(0xFFF5F5F5);
  final UserService _userService = UserService();
  final ProductService productService = ProductService();
  final DeliveryAreaService _deliveryAreaService = DeliveryAreaService();

  User? user;
  List<Widget> checkoutItem = [];
  List<DeliveryArea> deliveryAreas = [];
  bool loading = false;
  ShippingMethod shippingMethod = ShippingMethod.delivery;
  DeliveryArea? selectedAddress;
  Map<String, dynamic>? currentAddress;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      loading = true;
    });
    user = await _userService.loadUser();
    checkoutItem.clear();
    for (var item in widget.cartItems) {
      final product = await productService.getProduct(item.productId);
      final images = await productService.getImages(item.productId);
      final variants = await productService.getVariants(item.productId);
      final variant = variants.firstWhere((v) => item.variantId == v.variantId);

      checkoutItem.add(
        _buildProductItem(product, variant, images.first, item.amount),
      );
    }
    deliveryAreas = await _deliveryAreaService.fetchAllAreas();
    selectedAddress = deliveryAreas[0];
    currentAddress = user!.address;
    setState(() {
      loading = false;
    });
  }

  void onConfirmShipping(
    ShippingMethod newMethod,
    DeliveryArea? newArea,
    Map<String, dynamic>? address,
  ) {
    setState(() {
      shippingMethod = newMethod;
      selectedAddress = newArea;
      currentAddress = address;
    });
  }

  void _showAddressSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ShippingAddressSheet(
          deliveryArea: deliveryAreas,
          currentSelection: selectedAddress ?? deliveryAreas[0],
          currentAddress: user!.address,
          shippingMethod: shippingMethod,
          onConfirm: onConfirmShipping,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFED1E28)),
        ),
      );
    }

    double serviceFee = 1000;
    double totalPrice = 0;
    for (var item in widget.cartItems) {
      totalPrice += item.subtotal;
    }
    double shippingCost = (shippingMethod == ShippingMethod.directDelivery)
        ? (selectedAddress?.getDeliveryfee() ?? 0)
        : (shippingMethod == ShippingMethod.delivery ? 3000 : 0);
    double grandTotal = totalPrice + serviceFee + shippingCost;

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Checkout",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),

      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return checkoutItem[index];
              },
              itemCount: checkoutItem.length,
            ),

            const SizedBox(height: 16),

            InkWell(
              onTap: _showAddressSelection,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Shipping Option",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_right, color: Colors.black),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Details",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Payment Method",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  _buildDetailRow("Item Subtotal", totalPrice),
                  if (shippingMethod != ShippingMethod.pickup)
                    _buildDetailRow(
                      "Total Shipping Cost",
                      shippingMethod == ShippingMethod.directDelivery
                          ? selectedAddress!.getDeliveryfee()
                          : 3000,
                    ),
                  _buildDetailRow("Service Fee", serviceFee),
                  const Divider(),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order Total",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      FormattedPrice(
                        price: grandTotal,
                        size: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Check Out",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(
    Product product,
    ProductVariant variant,
    ProductImage image,
    int quantity,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Image.network(
                image.imageUrl,
                width: 60,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    variant.optionName,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FormattedPrice(
                      price: product.price,
                      size: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryRed),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "x$quantity",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: primaryRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildDetailRow(String label, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
          FormattedPrice(price: price, size: 12, fontWeight: FontWeight.w400),
        ],
      ),
    );
  }
}
