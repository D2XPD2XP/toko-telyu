import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:toko_telyu/models/product_variant.dart';

class ProductVariantModal extends StatelessWidget {
  final void Function(ProductVariant variant) onAdd;

  const ProductVariantModal({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final nameC = TextEditingController();
    final stockC = TextEditingController();
    final addPriceC = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const Text(
              "Add Variant",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            _buildInput(controller: nameC, label: "Option Name"),

            const SizedBox(height: 14),

            _buildInput(controller: stockC, label: "Stock", isNumber: true),

            const SizedBox(height: 14),

            _buildInput(
              controller: addPriceC,
              label: "Additional Price",
              isNumber: true,
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFED1E28),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (nameC.text.isEmpty || stockC.text.isEmpty) return;

                  final variant = ProductVariant(
                    const Uuid().v4(),
                    nameC.text,
                    int.parse(stockC.text),
                    double.tryParse(addPriceC.text) ?? 0,
                  );

                  onAdd(variant);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Add Variant",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFED1E28)),
        ),
      ),
    );
  }
}
