import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_image.dart';
import 'package:toko_telyu/models/product_variant.dart';
import 'package:uuid/uuid.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameC;
  late final TextEditingController priceC;
  late final TextEditingController descC;

  List<ProductImage> images = [];
  List<ProductVariant> variants = [];

  @override
  void initState() {
    super.initState();

    nameC = TextEditingController(text: widget.product?.productName ?? "");
    priceC = TextEditingController(
      text: widget.product?.price.toString() ?? "",
    );
    descC = TextEditingController(text: widget.product?.description ?? "");

    if (widget.product != null) {
      _loadImages();
      _loadVariants();
    }
  }

  Future<void> _loadImages() async {
    final snap = await FirebaseFirestore.instance
        .collection("product")
        .doc(widget.product!.productId)
        .collection("product_images")
        .get();

    setState(() {
      images = snap.docs
          .map((e) => ProductImage.fromFirestore(e.data(), e.id))
          .toList();
    });
  }

  Future<void> _loadVariants() async {
    final snap = await FirebaseFirestore.instance
        .collection("product")
        .doc(widget.product!.productId)
        .collection("product_variant")
        .get();

    setState(() {
      variants = snap.docs
          .map((e) => ProductVariant.fromFirestore(e.data(), e.id))
          .toList();
    });
  }

  @override
  void dispose() {
    nameC.dispose();
    priceC.dispose();
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

              // DESC
              _FormField(controller: descC, label: "Description", maxLines: 4),
              const SizedBox(height: 24),

              // IMAGES
              _ImageListSection(
                title: "Product Images",
                items: images,
                onDelete: (img) => setState(() => images.remove(img)),
                onAdd: _addImageSheet,
              ),

              // VARIANTS
              _ListSection<ProductVariant>(
                title: "Product Variant (color/size)",
                items: variants,
                onDelete: (item) => setState(() => variants.remove(item)),
                onAdd: _addVariantSheet,
                addLabel: "Add Variant",
                displayText: (v) =>
                    "${v.optionName} - stock: ${v.stock} (+${v.additionalPrice})",
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

  // ==============================================================
  // ADD IMAGE DIALOG
  // ==============================================================
  void _addImageSheet() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
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
              "Add Image URL",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: "https://..."),
            ),
            const SizedBox(height: 12),
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
                onPressed: () {},
                child: const Text(
                  "Add Image",
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
    );
  }

  // ==============================================================
  // ADD VARIANT DIALOG
  // ==============================================================
  void _addVariantSheet() {
    final nameC = TextEditingController();
    final stockC = TextEditingController();
    final addPriceC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
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
            Text(
              "Add Variant",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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

                  setState(() => variants.add(variant));
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
      ),
    );
  }

  // ==============================================================
  // SAVE PRODUCT
  // ==============================================================
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final firestore = FirebaseFirestore.instance;

    if (widget.product == null) {
      // CREATE
      final newId = const Uuid().v4();

      await firestore.collection("product").doc(newId).set({
        "product_name": nameC.text,
        "price": double.parse(priceC.text),
        "description": descC.text,
        "category_id": widget.product?.category.categoryId ?? "",
      });

      // save images
      for (var img in images) {
        await firestore
            .collection("product")
            .doc(newId)
            .collection("product_images")
            .doc(img.imageId)
            .set(img.toFirestore());
      }

      // save variants
      for (var v in variants) {
        await firestore
            .collection("product")
            .doc(newId)
            .collection("product_variant")
            .doc(v.variantId)
            .set(v.toFirestore());
      }
    } else {
      // UPDATE
      final id = widget.product!.productId;

      await firestore.collection("product").doc(id).update({
        "product_name": nameC.text,
        "price": double.parse(priceC.text),
        "description": descC.text,
      });

      // replace images
      final imgRef = firestore
          .collection("product")
          .doc(id)
          .collection("product_images");
      final oldImgs = await imgRef.get();
      for (var d in oldImgs.docs) {
        await d.reference.delete();
      }
      for (var img in images) {
        await imgRef.doc(img.imageId).set(img.toFirestore());
      }

      // replace variants
      final varRef = firestore
          .collection("product")
          .doc(id)
          .collection("product_variant");
      final oldVar = await varRef.get();
      for (var d in oldVar.docs) {
        await d.reference.delete();
      }
      for (var v in variants) {
        await varRef.doc(v.variantId).set(v.toFirestore());
      }
    }

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
// REUSABLE LIST SECTION
// =======================================================================
//
class _ListSection<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final Function(T) onDelete;
  final VoidCallback onAdd;
  final String addLabel;
  final String Function(T) displayText;

  const _ListSection({
    required this.title,
    required this.items,
    required this.onDelete,
    required this.onAdd,
    required this.addLabel,
    required this.displayText,
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
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(displayText(item))),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(item),
                ),
              ],
            );
          }).toList(),

          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(addLabel),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFED1E28),
              side: const BorderSide(color: Color(0xFFED1E28)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageListSection extends StatelessWidget {
  final String title;
  final List<ProductImage> items;
  final Function(ProductImage) onDelete;
  final VoidCallback onAdd;

  const _ImageListSection({
    required this.title,
    required this.items,
    required this.onDelete,
    required this.onAdd,
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

          // ===========================
          //     GRID IMAGE LAYOUT
          // ===========================
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length + 1, // extra 1 for the add card
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 per row (responsive)
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              // "Add Image" button
              if (index == items.length) {
                return GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.add, size: 40, color: Colors.grey),
                    ),
                  ),
                );
              }

              final img = items[index];

              // Image card
              return Stack(
                children: [
                  // IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      img.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),

                  // DELETE BUTTON (overlay top right)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: () => onDelete(img),
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
