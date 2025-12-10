import 'package:flutter/material.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/screens/admin/product_form_screen.dart';
import 'package:toko_telyu/services/product_category_services.dart';
import 'package:toko_telyu/services/product_services.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';
import 'package:toko_telyu/models/product_image.dart';
import 'package:toko_telyu/models/product_variant.dart';
import 'package:toko_telyu/models/product_category.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _service = ProductService();
  final ProductCategoryService _categoryService = ProductCategoryService();

  double get bottomPadding => MediaQuery.of(context).padding.bottom + 50;

  List<Product> _products = [];
  List<ProductCategory> _categories = [];

  /// Penyimpanan sementara images & variants
  final Map<String, List<ProductImage>> _productImages = {};
  final Map<String, List<ProductVariant>> _productVariants = {};

  bool _isLoading = true;
  String searchQuery = "";

  // -------------------------------
  // LOAD DATA AWAL
  // -------------------------------
  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      setState(() => _isLoading = true);

      _categories = await _categoryService.getCategories();
      final products = await _service.getAllProducts(_categories);

      for (var p in products) {
        _productImages[p.productId] = await _service.getImages(p.productId);
        _productVariants[p.productId] = await _service.getVariants(p.productId);
      }

      setState(() {
        _products = products;
      });
    } catch (e) {
      print("ERROR loadAll => $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // -------------------------------
  // SEARCH
  // -------------------------------
  Future<void> _search(String q) async {
    searchQuery = q;

    if (q.trim().isEmpty) {
      return _loadAll();
    }

    final results = await _service.searchProducts(q, _categories);

    // load images & variants
    for (var p in results) {
      _productImages[p.productId] = await _service.getImages(p.productId);
      _productVariants[p.productId] = await _service.getVariants(p.productId);
    }

    setState(() => _products = results);
  }

  // -------------------------------
  // IMAGE LOADER
  // -------------------------------
  Widget _buildImage(String path) {
    if (path.startsWith("http")) {
      return Image.network(path, height: 55, width: 55, fit: BoxFit.cover);
    }
    return Image.asset(path, height: 55, width: 55, fit: BoxFit.cover);
  }

  // -------------------------------
  // SEARCH FIELD
  // -------------------------------
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        onChanged: (value) => _search(value),
        decoration: const InputDecoration(
          hintText: "Search product...",
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // -------------------------------
  // ADD BUTTON
  // -------------------------------
  Widget _buildAddButton() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
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
          decoration: BoxDecoration(
            color: const Color(0xFFED1E28),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  // -------------------------------
  // PRODUCT ITEM (UI unchanged)
  // -------------------------------
  Widget _buildProductItem(Product item) {
    final images = _productImages[item.productId] ?? [];
    final variants = _productVariants[item.productId] ?? [];

    final imageUrl = images.isNotEmpty ? images.first.imageUrl : null;
    final totalStock = variants.fold<int>(0, (sum, v) => sum + v.stock);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl == null
                ? Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  )
                : _buildImage(imageUrl),
          ),

          const SizedBox(width: 14),

          // CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAME + STOCK
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

                // PRICE
                FormattedPrice(
                  price: item.price,
                  size: 14.0,
                  fontWeight: FontWeight.w600,
                ),

                const SizedBox(height: 8),

                // IMAGE + VARIANT COUNT
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "${images.length} Image",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.layers, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "${variants.length} Variant",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // MENU
          PopupMenuButton(
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
              } else if (value == "delete") {
                await _service.deleteProduct(item.productId);
                _loadAll();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: "edit",
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text("Edit"),
                  ],
                ),
              ),
              const PopupMenuItem(
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
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  // -------------------------------
  // BUILD
  // -------------------------------
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
        elevation: 0,
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
                      onRefresh: () async {
                        await _loadAll();
                      },
                      child: _products.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 200),
                                Center(child: Text("Product not found")),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
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
