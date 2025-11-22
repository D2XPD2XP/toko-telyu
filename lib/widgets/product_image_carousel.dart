import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductImageCarousel extends StatefulWidget {
  const ProductImageCarousel({super.key});

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  final PageController _controller = PageController();
  bool isFavorite = false;

  final List<String> images = [
    'assets/seragam_merah_telkom.png',
    'assets/seragam_merah_telkom.png',
    'assets/seragam_merah_telkom.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: PageView.builder(
            controller: _controller,
            itemCount: images.length,
            itemBuilder: (context, i) {
              return Image.asset(
                images[i],
                fit: BoxFit.contain,
              );
            },
          ),
        ),
        Positioned(
          top: 0,
          right: 25,
          child: InkWell(
            onTap: () {
              setState(() => isFavorite = !isFavorite);
            },
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 30,
              color: Colors.black87,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: SmoothPageIndicator(
              controller: _controller,
              count: images.length,
              effect: ExpandingDotsEffect(
                dotWidth: 8,
                dotHeight: 8,
                expansionFactor: 3,
                activeDotColor: Colors.red,
                dotColor: Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
