import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_category.dart';
import 'package:toko_telyu/models/product_image.dart';
import 'package:toko_telyu/models/product_variant.dart';
import 'package:toko_telyu/screens/admin/product_form_screen.dart';
import 'package:toko_telyu/services/product_category_services.dart';
import 'package:toko_telyu/services/product_services.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';
import 'package:toko_telyu/widgets/product_image.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _service = ProductService();
  final ProductCategoryService _categoryService = ProductCategoryService();

  List<Product> _products = [];
  List<ProductCategory> _categories = [];

  final Map<String, List<ProductImage>> _productImages = {};
  final Map<String, List<ProductVariant>> _productVariants = {};

  bool _isLoading = true;
  String searchQuery = "";

  double get bottomPadding => MediaQuery.of(context).padding.bottom + 50;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;

    try {
      setState(() => _isLoading = true);

      _categories = await _categoryService.getCategories();
      final products = await _service.getAllProducts(_categories);

      for (final p in products) {
        _productImages[p.productId] = await _service.getImages(p.productId);
        _productVariants[p.productId] = await _service.getVariants(p.productId);
      }

      if (!mounted) return;
      setState(() => _products = products);
    } catch (e) {
      if (kDebugMode) {
        print("ERROR loadAll => $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _search(String q) async {
    searchQuery = q;

    if (q.trim().isEmpty) {
      await _loadAll();
      return;
    }

    final results = await _service.searchProducts(q, _categories);

    for (final p in results) {
      _productImages[p.productId] = await _service.getImages(p.productId);
      _productVariants[p.productId] = await _service.getVariants(p.productId);
    }

    if (!mounted) return;
    setState(() => _products = results);
  }

  Future<bool> _confirmDelete() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Delete Product',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              content: const Text(
                'This product will be permanently deleted.',
                style: TextStyle(color: Colors.black87),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget _buildImage(String? path) {
    return ProductImageView(
      imageUrl: path,
      size: 55,
      borderRadius: BorderRadius.circular(10),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        onChanged: _search,
        decoration: const InputDecoration(
          hintText: "Search product...",
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductFormScreen(categories: _categories),
            ),
          );
          _loadAll();
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFED1E28),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildProductItem(Product item) {
    final images = _productImages[item.productId] ?? [];
    final variants = _productVariants[item.productId] ?? [];

    final imageUrl = images.isNotEmpty ? images.first.imageUrl : null;
    final totalStock = variants.fold<int>(0, (s, v) => s + v.stock);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(imageUrl),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      "Stok: $totalStock",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                FormattedPrice(
                  price: item.price,
                  size: 14,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  children: [
                    _meta(Icons.image, "${images.length} Image"),
                    _meta(Icons.layers, "${variants.length} Variant"),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            onSelected: (value) async {
              if (value == "edit") {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductFormScreen(
                      product: item,
                      categories: _categories,
                    ),
                  ),
                );
                _loadAll();
              }

              if (value == "delete") {
                final confirm = await _confirmDelete();
                if (!confirm) return;

                await _service.deleteProduct(item.productId);
                _loadAll();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: "edit",
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text("Edit"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "delete",
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Hapus"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Product List",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.grey[100],
        surfaceTintColor: Colors.grey[100],
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [_buildAddButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading && _products.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFED1E28),
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFFED1E28),
                      onRefresh: _loadAll,
                      child: _products.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 200),
                                Center(child: Text("Product not found")),
                              ],
                            )
                          : ListView.builder(
                              padding: EdgeInsets.only(bottom: bottomPadding),
                              itemCount: _products.length,
                              itemBuilder: (_, i) =>
                                  _buildProductItem(_products[i]),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
