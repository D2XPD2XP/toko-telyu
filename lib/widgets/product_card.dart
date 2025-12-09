import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:toko_telyu/models/wishlist.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_image.dart';
import 'package:toko_telyu/models/user.dart';
import 'package:toko_telyu/models/wishlist_item.dart';
import 'package:toko_telyu/screens/user/product_details_screen.dart';
import 'package:toko_telyu/services/wishlist_services.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.user,
    required this.product,
    required this.image,
  });

  final User user;
  final Product product;
  final ProductImage? image;

  @override
  State<ProductCard> createState() {
    return _ProductCardState();
  }
}

class _ProductCardState extends State<ProductCard> {
  final WishlistService _wishlistService = WishlistService();
  Wishlist? wishlist;
  List<WishlistItem>? wishlistedItem;
  bool isWishlisted = false;

  @override
  void initState() {
    super.initState();
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    wishlist = await _wishlistService.getWishlist(widget.user.userId);
    wishlistedItem = await _wishlistService.getItems(
      widget.user.userId,
      wishlist!.wishlistId!,
    );
    setState(() {
      if (wishlistedItem != null) {
        isWishlisted = _wishlistService.isWishlisted(
          widget.product.productId,
          null,
          wishlistedItem!,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailsScreen(productId: widget.product.productId),
          ),
        );
        loadWishlist();
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 2,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                AspectRatio(
                  aspectRatio: 1, 
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: (widget.image?.imageUrl ?? '').isNotEmpty
                        ? Image.network(
                            widget.image!.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFED1E28),),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    isWishlisted ? Icons.favorite : Symbols.favorite,
                    color: Color(0xFFED1E28)
                  ),
                ),
              ],
            ),
            Text(
              widget.product.category.categoryName,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              widget.product.productName,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),
            FormattedPrice(
              price: widget.product.price,
              size: 11,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}
