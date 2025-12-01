import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:toko_telyu/models/wishlist.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_image.dart';
import 'package:toko_telyu/models/product_variant.dart';
import 'package:toko_telyu/models/user.dart';
import 'package:toko_telyu/models/wishlist_item.dart';
import 'package:toko_telyu/services/user_services.dart';
import 'package:toko_telyu/services/wishlist_services.dart';

class ProductImageCarousel extends StatefulWidget {
  const ProductImageCarousel({
    super.key,
    required this.product,
    required this.images,
    required this.variant,
  });

  final Product product;
  final List<ProductImage> images;
  final ProductVariant variant;

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  final UserService _userService = UserService();
  final PageController _controller = PageController();
  final WishlistService _wishlistService = WishlistService();
  User? user;
  Wishlist? wishlist;
  List<WishlistItem> wishlistedItem = [];
  bool isWishlisted = false;

  @override
  void initState() {
    super.initState();
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    user = await _userService.loadUser();
    wishlist = await _wishlistService.getWishlist(user!.userId);
    wishlistedItem = await _wishlistService.getItems(
      user!.userId,
      wishlist!.wishlistId!,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    isWishlisted = _wishlistService.isWishlisted(
      widget.product.productId,
      widget.variant.variantId,
      wishlistedItem,
    );

    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              itemBuilder: (context, i) {
                return Image.network(
                  widget.images[i].imageUrl,
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
          Positioned(
            top: 0,
            right: 25,
            child: InkWell(
              onTap: () async {
                if (isWishlisted == false) {
                  await _wishlistService.addItem(
                    userId: user!.userId,
                    wishlistId: wishlist!.wishlistId!,
                    productId: widget.product.productId,
                    variantId: widget.variant.variantId,
                  );
                } else {
                  final wtemp = wishlistedItem.firstWhere(
                    (w) =>
                        w.productId == widget.product.productId &&
                        w.variantId == widget.variant.variantId,
                  );
                  await _wishlistService.deleteItem(
                    user!.userId,
                    wishlist!.wishlistId!,
                    wtemp.wishlistItemId!,
                  );
                }
                await loadWishlist();
              },
              child: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                size: 30,
                color: isWishlisted ? Color(0xFFED1E28) : Colors.black87,
              ),
            ),
          ),
          widget.images.length > 1
              ? Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: _controller,
                      count: widget.images.length,
                      effect: ExpandingDotsEffect(
                        dotWidth: 8,
                        dotHeight: 8,
                        expansionFactor: 3,
                        activeDotColor: Color(0xFFED1E28),
                        dotColor: Colors.grey.shade300,
                      ),
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
