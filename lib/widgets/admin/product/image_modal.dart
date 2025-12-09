import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toko_telyu/services/cloudinary_service.dart';

class ProductImageModal extends StatefulWidget {
  final void Function(String imageUrl) onAdd;

  const ProductImageModal({super.key, required this.onAdd});

  @override
  State<ProductImageModal> createState() => _ProductImageModalState();
}

class _ProductImageModalState extends State<ProductImageModal> {
  bool isLoading = false;

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() => isLoading = true);

    try {
      final file = File(picked.path);

      // Upload ke Cloudinary
      final imageUrl = await CloudinaryService.uploadImage(file);

      widget.onAdd(imageUrl);
      Navigator.pop(context);
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload gagal: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Modal konten
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add Product Image",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFED1E28),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  onPressed: pickAndUploadImage,
                  child: const Text(
                    "Pick Image from Gallery",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // Full overlay loading
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFED1E28)),
              ),
            ),
          ),
      ],
    );
  }
}
