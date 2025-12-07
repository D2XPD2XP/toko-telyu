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
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Add Variant",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nameC,
            decoration: const InputDecoration(
              labelText: "Option Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: stockC,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Stock",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: addPriceC,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Additional Price",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
