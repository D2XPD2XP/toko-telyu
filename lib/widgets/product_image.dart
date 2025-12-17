import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final BorderRadius borderRadius;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.size = 70,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(borderRadius: borderRadius, child: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _fallbackIcon();
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, _, _) => _fallbackIcon(),
    );
  }

  Widget _fallbackIcon() {
    return const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 32,
        color: Colors.grey,
      ),
    );
  }
}
