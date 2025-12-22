import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_category.dart';
import 'package:toko_telyu/models/product_image.dart';
import 'package:toko_telyu/models/product_variant.dart';
import 'package:toko_telyu/services/cloudinary_service.dart';
import 'package:toko_telyu/services/product_services.dart';
import 'package:toko_telyu/widgets/admin/product/custom_dropdown.dart';
import 'package:toko_telyu/widgets/admin/product/form_field.dart';
import 'package:toko_telyu/widgets/admin/product/image_list_section.dart';
import 'package:toko_telyu/widgets/admin/product/list_section.dart';
import 'package:toko_telyu/widgets/admin/product/image_modal.dart';
import 'package:toko_telyu/widgets/admin/product/variant_modal.dart';
import 'package:toko_telyu/widgets/admin/product/price_input_formatter.dart';
import 'package:uuid/uuid.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  final List<ProductCategory> categories;

  const ProductFormScreen({super.key, this.product, required this.categories});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _service = ProductService();

  late final TextEditingController _nameC;
  late final TextEditingController _priceC;
  late final TextEditingController _descC;

  List<ProductImage> _images = [];
  List<ProductVariant> _variants = [];
  ProductCategory? _category;

  bool _isSaving = false;

  double _parsePrice(String raw) {
    return double.tryParse(raw.replaceAll('.', '')) ?? 0;
  }

  String _formatPrice(double value) {
    return NumberFormat.decimalPattern('id_ID').format(value);
  }

  double get _bottomSafePadding => MediaQuery.of(context).padding.bottom + 24;

  @override
  void initState() {
    super.initState();

    _nameC = TextEditingController(text: widget.product?.productName ?? '');
    _priceC = TextEditingController(
      text: widget.product == null ? '' : _formatPrice(widget.product!.price),
    );
    _descC = TextEditingController(text: widget.product?.description ?? '');

    _category =
        widget.product?.category ??
        (widget.categories.isNotEmpty ? widget.categories.first : null);

    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    if (widget.product == null) return;

    final id = widget.product!.productId;

    final imgs = await _service.getImages(id);
    final vars = await _service.getVariants(id);

    if (!mounted) return;
    setState(() {
      _images = imgs;
      _variants = vars;
    });
  }

  void _openAddImage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProductImageModal(
        onAdd: (url) {
          setState(() {
            _images.add(ProductImage(const Uuid().v4(), url));
          });
        },
      ),
    );
  }

  void _openAddVariant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProductVariantModal(
        onAdd: (variant) {
          setState(() => _variants.add(variant));
        },
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) return;

    setState(() => _isSaving = true);

    try {
      final name = _nameC.text.trim();
      final price = _parsePrice(_priceC.text);
      final desc = _descC.text.trim();

      Product product;

      if (widget.product == null) {
        product = await _service.createProduct(name, price, desc, _category!);
      } else {
        product = widget.product!;
        await _service.updateProduct(product.productId, {
          'product_name': name,
          'price': price,
          'description': desc,
          'category_id': _category!.categoryId,
        });
      }

      final List<ProductImage> finalImages = [];

      for (final img in _images) {
        if (img.file != null) {
          final url = await CloudinaryService.uploadImage(img.file as File);
          finalImages.add(ProductImage(const Uuid().v4(), url));
        } else {
          finalImages.add(img);
        }
      }

      await _service.syncImages(product.productId, finalImages);
      await _service.syncVariants(product.productId, _variants);

      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        surfaceTintColor: Colors.grey[100],
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          isEdit ? 'Edit Product' : 'Add Product',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, _bottomSafePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductFormField(
                  controller: _nameC,
                  label: 'Product Name',
                  validator: (v) => v!.isEmpty ? 'Product name required' : null,
                ),
                const SizedBox(height: 16),
                ProductFormField(
                  controller: _priceC,
                  label: 'Price',
                  keyboard: TextInputType.number,
                  inputFormatters: [PriceInputFormatter()],
                  validator: (v) => v!.isEmpty ? 'Price required' : null,
                ),
                const SizedBox(height: 16),
                ProductFormField(
                  controller: _descC,
                  label: 'Description',
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                ProductCustomDropdown(
                  items: widget.categories,
                  selected: _category,
                  onChanged: (c) => setState(() => _category = c),
                ),
                const SizedBox(height: 24),
                ProductImageListSection(
                  title: 'Product Images',
                  items: _images,
                  onAdd: _openAddImage,
                  onDelete: (img) => setState(() => _images.remove(img)),
                ),
                const SizedBox(height: 16),
                ProductListSection<ProductVariant>(
                  title: 'Product Variants',
                  items: _variants,
                  onAdd: _openAddVariant,
                  onDelete: (v) => setState(() => _variants.remove(v)),
                  addLabel: 'Add Variant',
                  displayText: (v) =>
                      '${v.optionName} | stock ${v.stock} (+${v.additionalPrice})',
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFED1E28),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Product',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
