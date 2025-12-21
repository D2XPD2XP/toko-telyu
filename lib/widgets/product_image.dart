import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProductImageView extends StatefulWidget {
  final String? imageUrl;
  final double size;
  final BorderRadius borderRadius;

  const ProductImageView({
    super.key,
    required this.imageUrl,
    this.size = 70,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<ProductImageView> createState() => _ProductImageViewState();
}

class _ProductImageViewState extends State<ProductImageView> {
  bool _hasError = false;

  void _retry() {
    setState(() {
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: widget.borderRadius,
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError || widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return _fallbackWidget();
    }

    return Image.network(
      widget.imageUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFED1E28),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (kDebugMode) {
          print("Image load failed: ${widget.imageUrl}, error: $error");
        }
        _hasError = true;
        return _fallbackWidget();
      },
    );
  }

  Widget _fallbackWidget() {
    return GestureDetector(
      onTap: _retry,
      child: Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 32,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
