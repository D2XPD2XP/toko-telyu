import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/models/cart_item.dart';
import 'package:toko_telyu/models/product_image.dart';
import 'package:toko_telyu/models/product_variant.dart';
import 'package:toko_telyu/screens/user/product_details_screen.dart';
import 'package:toko_telyu/services/cart_services.dart';
import 'package:toko_telyu/services/wishlist_services.dart';
import 'package:toko_telyu/widgets/custom_dialog.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';

class WishlistCard extends StatelessWidget {
  final String userId;
  final String wishlistId;
  final String itemId;
  final String cartId;
  final String productId;
  final String productName;
  final ProductImage? productImage;
  final ProductVariant variant;
  final List<CartItem>? cartItems;
  final double price;
  final VoidCallback onAdd;

  const WishlistCard({
    Key? key,
    required this.userId,
    required this.wishlistId,
    required this.itemId,
    required this.cartId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.variant,
    required this.cartItems,
    required this.price,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CartService cartService = CartService();
    WishlistService wishlistService = WishlistService();
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(productId: productId),
          ),
        );
        onAdd();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
              child: Image.network(productImage!.imageUrl, fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          productName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          onPressed: () async {
                            await wishlistService.deleteItem(userId, wishlistId, itemId);
                            onAdd();
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          alignment: Alignment.topRight,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

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
                  const SizedBox(height: 8),

                  FormattedPrice(
                    price: price,
                    size: 14,
                    fontWeight: FontWeight.w600,
                  ),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 32,
                      child: OutlinedButton(
                        onPressed: () async {
                          int currentAmount = cartItems!.isNotEmpty
                              ? cartService.currentItemAmount(
                                  cartItems,
                                  productId,
                                  variant.variantId,
                                )
                              : 0;
                          if (currentAmount + 1 <= variant.stock) {
                            await cartService.addItem(
                              userId: userId,
                              cartId: cartId,
                              productId: productId,
                              variant: variant,
                              amount: 1,
                            );
                            onAdd();
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => CustomDialog(
                                ctx: context,
                                message:
                                    'This variant is not available. Please select another variant',
                                title: "NOT AVAILABLE",
                              ),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFED1E28)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text(
                          variant.stock >= 1 ? "+ Add to Cart" : "SOLD OUT",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFFED1E28),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
