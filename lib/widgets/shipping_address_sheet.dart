import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/enums/shipping_method.dart';
import 'package:toko_telyu/models/delivery_area.dart';

class ShippingAddressSheet extends StatefulWidget {
  final List<DeliveryArea> deliveryArea;
  final DeliveryArea? currentSelection;
  final Map<String, dynamic>? currentAddress;
  final ShippingMethod shippingMethod;
  final void Function(ShippingMethod, DeliveryArea?, Map<String, dynamic>?)
  onConfirm;

  const ShippingAddressSheet({
    Key? key,
    required this.deliveryArea,
    required this.currentSelection,
    required this.currentAddress,
    required this.shippingMethod,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<ShippingAddressSheet> createState() => _ShippingAddressSheetState();
}

class _ShippingAddressSheetState extends State<ShippingAddressSheet> {
  late DeliveryArea? _tempSelectedAddress;
  late ShippingMethod _tempshippingMethod;
  final Color primaryRed = const Color(0xFFED1E28);

  @override
  void initState() {
    super.initState();
    _tempshippingMethod = widget.shippingMethod;
    _tempSelectedAddress = widget.currentSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _tempshippingMethod == ShippingMethod.pickup
          ? MediaQuery.of(context).size.height * 0.45
          : (_tempshippingMethod == ShippingMethod.delivery
                ? MediaQuery.of(context).size.height * 0.6
                : MediaQuery.of(context).size.height * 0.8),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Shipping Method",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.currentAddress != null
                  ? ShippingMethod.values.length
                  : ShippingMethod.values.length - 1,
              itemBuilder: (context, index) {
                final method = ShippingMethod.values[index];
                final isSelected = method == _tempshippingMethod;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _tempshippingMethod = method;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryRed : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            ShippingMethod.values[index] ==
                                    ShippingMethod.directDelivery
                                ? 'DIRECT DELIVERY'
                                : ShippingMethod.values[index].name
                                      .toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : primaryRed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected ? Colors.white : primaryRed,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          if (_tempshippingMethod == ShippingMethod.directDelivery ||
              _tempshippingMethod == ShippingMethod.delivery) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Shipping Address",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            if (_tempshippingMethod == ShippingMethod.directDelivery)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.deliveryArea.length,
                  itemBuilder: (context, index) {
                    final address = widget.deliveryArea[index];
                    final isSelected = address == _tempSelectedAddress;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _tempSelectedAddress = address;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryRed : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                address.getAreaname(),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : primaryRed,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected ? Colors.white : primaryRed,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (_tempshippingMethod == ShippingMethod.delivery)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: primaryRed,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.currentAddress!['street'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.radio_button_checked,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
          ],

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_tempshippingMethod == ShippingMethod.pickup) {
                    widget.onConfirm(_tempshippingMethod, null, null);
                  } else if (_tempshippingMethod ==
                      ShippingMethod.directDelivery) {
                    widget.onConfirm(
                      _tempshippingMethod,
                      _tempSelectedAddress,
                      null,
                    );
                  } else {
                    widget.onConfirm(
                      _tempshippingMethod,
                      null,
                      widget.currentAddress,
                    );
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "OK",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
