import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_category.dart';
import 'package:toko_telyu/models/product_image.dart';
import 'package:toko_telyu/models/product_variant.dart';
import 'package:toko_telyu/services/product_services.dart';
import 'package:uuid/uuid.dart';

import '../../widgets/admin/product/custom_dropdown.dart';
import '../../widgets/admin/product/form_field.dart';
import '../../widgets/admin/product/image_list_section.dart';
import '../../widgets/admin/product/list_section.dart';
import '../../widgets/admin/product/image_modal.dart';
import '../../widgets/admin/product/variant_modal.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  final List<ProductCategory> categories;

  const ProductFormScreen({super.key, this.product, required this.categories});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  late final TextEditingController nameC;
  late final TextEditingController priceC;
  late final TextEditingController descC;

  List<ProductImage> images = [];
  List<ProductVariant> variants = [];
  ProductCategory? selectedCategory;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.product?.productName ?? "");
    priceC = TextEditingController(
      text: widget.product?.price.toString() ?? "",
    );
    descC = TextEditingController(text: widget.product?.description ?? "");
    selectedCategory =
        widget.product?.category ??
        (widget.categories.isNotEmpty ? widget.categories.first : null);

    _loadProductData();
  }

  Future<void> _loadProductData() async {
    if (widget.product == null) return;
    final id = widget.product!.productId;
    final imgs = await _productService.getImages(id);
    final vars = await _productService.getVariants(id);

    setState(() {
      images = imgs;
      variants = vars;
    });
  }

  void _addImage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProductImageModal(
        onAdd: (imgUrl) =>
            setState(() => images.add(ProductImage(Uuid().v4(), imgUrl))),
      ),
    );
  }

  void _addVariant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          ProductVariantModal(onAdd: (v) => setState(() => variants.add(v))),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    final name = nameC.text;
    final price = double.parse(priceC.text);
    final desc = descC.text;
    final category = selectedCategory!;
    final id = widget.product?.productId ?? const Uuid().v4();

    if (widget.product == null) {
      final newProduct = await _productService.createProduct(
        name,
        price,
        desc,
        category,
      );
      await _productService.replaceImages(newProduct.productId, images);
      await _productService.replaceVariants(newProduct.productId, variants);
    } else {
      await _productService.updateProduct(id, {
        "product_name": name,
        "price": price,
        "description": desc,
        "category_id": category.categoryId,
      });
      await _productService.replaceImages(id, images);
      await _productService.replaceVariants(id, variants);
    }

    Navigator.pop(context);
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
              ProductFormField(
                controller: nameC,
                label: "Product Name",
                validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              ProductFormField(
                controller: priceC,
                label: "Price",
                keyboard: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Harga wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              ProductFormField(
                controller: descC,
                label: "Description",
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              ProductCustomDropdown(
                items: widget.categories,
                selected: selectedCategory,
                onChanged: (c) => setState(() => selectedCategory = c),
              ),
              const SizedBox(height: 24),
              ProductImageListSection(
                title: "Product Images",
                items: images,
                onDelete: (img) => setState(() => images.remove(img)),
                onAdd: _addImage,
              ),
              const SizedBox(height: 16),
              ProductListSection<ProductVariant>(
                title: "Product Variant (color/size)",
                items: variants,
                onDelete: (v) => setState(() => variants.remove(v)),
                onAdd: _addVariant,
                addLabel: "Add Variant",
                displayText: (v) =>
                    "${v.optionName} - stock: ${v.stock} (+${v.additionalPrice})",
              ),
              const SizedBox(height: 40),
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
}
