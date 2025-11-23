import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductFormScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController nameC;
  late final TextEditingController priceC;
  late final TextEditingController stockC;
  late final TextEditingController descC;

  List<String> imageUrls = [];
  List<String> imageVariants = [];

  @override
  void initState() {
    super.initState();

    nameC = TextEditingController(text: widget.product?["name"] ?? "");
    priceC = TextEditingController(
      text: widget.product?["price"]?.toString() ?? "",
    );
    stockC = TextEditingController(
      text: widget.product?["stock"]?.toString() ?? "",
    );
    descC = TextEditingController(text: widget.product?["description"] ?? "");

    imageUrls = List<String>.from(widget.product?["image_url"] ?? []);
    imageVariants = List<String>.from(widget.product?["image_variant"] ?? []);
  }

  @override
  void dispose() {
    nameC.dispose();
    priceC.dispose();
    stockC.dispose();
    descC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[100],
        title: Text(
          isEdit ? "Edit Product" : "Add New Product",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NAME
              _FormField(
                controller: nameC,
                label: "Product Name",
                validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // PRICE
              _FormField(
                controller: priceC,
                label: "Price",
                keyboard: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Harga wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // STOCK
              _FormField(
                controller: stockC,
                label: "Stock",
                keyboard: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Stok wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // DESC
              _FormField(controller: descC, label: "Description", maxLines: 4),

              const SizedBox(height: 24),

              // IMAGE URL SECTION
              _ListSection(
                title: "Product Image",
                items: imageUrls,
                onDelete: (item) => setState(() => imageUrls.remove(item)),
                onAdd: () {
                  // TODO: Tambah URL gambar
                },
                addLabel: "Add Image URL",
              ),

              const SizedBox(height: 24),

              // VARIANT SECTION
              _ListSection(
                title: "Product Variant (color/size, etc.)",
                items: imageVariants,
                onDelete: (item) => setState(() => imageVariants.remove(item)),
                onAdd: () {
                  // TODO: Tambah variant
                },
                addLabel: "Add Variant",
              ),

              const SizedBox(height: 40),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFED1E28),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _saveProduct,
                  child: const Text(
                    "Save Product",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: Simpan ke backend nanti
    print("Saving product...");

    Navigator.pop(context);
  }
}

//
// =======================================================================
// REUSABLE FORM FIELD
// =======================================================================
//
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboard,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFFED1E28)),
        ),
      ),
    );
  }
}

//
// =======================================================================
// REUSABLE LIST SECTION (image url / variant list)
// =======================================================================
//
class _ListSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final Function(String) onDelete;
  final VoidCallback onAdd;
  final String addLabel;

  const _ListSection({
    required this.title,
    required this.items,
    required this.onDelete,
    required this.onAdd,
    required this.addLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          ...items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(item, overflow: TextOverflow.ellipsis)),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onDelete(item),
                  ),
                ],
              ),
            );
          }),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(addLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFED1E28),
                side: const BorderSide(color: Color(0xFFED1E28)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
