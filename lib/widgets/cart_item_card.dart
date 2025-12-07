import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_image.dart';
import 'package:toko_telyu/models/product_variant.dart';
import 'package:toko_telyu/services/cart_services.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';

class CartItemCard extends StatefulWidget {
  final String userId;
  final String cartId;
  final String cartItemId;
  final Product product;
  final ProductImage productImage;
  final ProductVariant variant;
  final int quantity;
  final VoidCallback? onChanged;

  const CartItemCard({
    super.key,
    required this.userId,
    required this.cartId,
    required this.cartItemId,
    required this.product,
    required this.productImage,
    required this.variant,
    required this.quantity,
    this.onChanged,
  });

  @override
  State<CartItemCard> createState() {
    return _CartItemCardState();
  }
}

class _CartItemCardState extends State<CartItemCard> {
  CartService cartService = CartService();
  int _quantity = 0;

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.network(
              widget.productImage.imageUrl,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.productName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.variant.optionName,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FormattedPrice(
                  price: widget.product.price * _quantity,
                  size: 13,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 55),
              Container(
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        if (_quantity == 1) {
                          await cartService.deleteItem(
                            widget.userId,
                            widget.cartId,
                            widget.cartItemId,
                          );
                          widget.onChanged?.call();
                        } else {
                          await cartService.updateItem(
                            widget.userId,
                            widget.cartId,
                            widget.cartItemId,
                            {
                              'amount': _quantity - 1,
                              'subtotal':
                                  widget.product.price * (_quantity - 1),
                            },
                          );
                          setState(() {
                            _quantity -= 1;
                          });
                          widget.onChanged?.call();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          _quantity == 1 ? Icons.delete_outline : Icons.remove,
                          size: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Text(
                      "$_quantity",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    widget.variant.stock > _quantity
                        ? InkWell(
                            onTap: () async {
                              await cartService.updateItem(
                                widget.userId,
                                widget.cartId,
                                widget.cartItemId,
                                {
                                  'amount': _quantity + 1,
                                  'subtotal':
                                      widget.product.price * (_quantity + 1),
                                },
                              );
                              setState(() {
                                _quantity += 1;
                              });
                              widget.onChanged?.call();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Icon(
                                Icons.add,
                                size: 14,
                                color: Colors.black54,
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
