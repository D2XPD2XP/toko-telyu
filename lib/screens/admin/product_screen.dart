import 'package:flutter/material.dart';
import 'package:toko_telyu/screens/admin/product_form_screen.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final List<Map<String, dynamic>> _products = [
    {
      "name": "Produk 1",
      "price": 15000,
      "stock": 20,
      "description": "Deskripsi produk 1",
      "image_urls": ["assets/seragam_merah_telkom.png"],
      "image_is_asset": true,
      "image_variants": ["Merah", "Putih"],
    },
    {
      "name": "Produk 2",
      "price": 20000,
      "stock": 10,
      "description": "Deskripsi produk 2",
      "image_urls": [
        "https://images-na.ssl-images-amazon.com/images/I/61PpAbgnfgL._UL500_.jpg",
      ],
      "image_variants": [],
    },
    {
      "name": "Produk 3",
      "price": 18000,
      "stock": 5,
      "description": "Deskripsi produk 3",
      "image_urls": [
        "https://down-id.img.susercontent.com/file/id-11134207-7rasd-m0fijd10cd3we7",
      ],
      "image_variants": ["Small"],
    },
  ];

  String searchQuery = "";

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
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: const InputDecoration(
          hintText: "Search product...",
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // -------------------------------
  // ACTION BUTTON ADD
  // -------------------------------
  Widget _buildAddButton() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
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
  // PRODUCT ITEM CARD
  // -------------------------------
  Widget _buildProductItem(Map<String, dynamic> item) {
    final List imageUrls = item["image_urls"] ?? [];
    final List imageVariants = item["image_variants"] ?? [];

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
            child: imageUrls.isNotEmpty
                ? _buildImage(imageUrls[0])
                : Container(
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
                  ),
          ),
          const SizedBox(width: 14),

          // TEXT CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PRODUCT NAME + STOCK
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item["name"],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "Stok: ${item["stock"]}",
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
                  price: (item["price"] ?? 0).toDouble(),
                  size: 14.0,
                  fontWeight: FontWeight.w600,
                ),

                const SizedBox(height: 8),

                // IMAGE + VARIANT COUNT
                Row(
                  children: [
                    Icon(Icons.image, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "${imageUrls.length} Image",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.layers, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "${imageVariants.length} Variant",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // MENU BUTTON
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "edit") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductFormScreen(product: item),
                  ),
                );
              } else if (value == "delete") {
                setState(() => _products.remove(item));
              }
            },
            color: Colors.grey[50],
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: "edit",
                child: Row(
                  children: const [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text("Edit"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "delete",
                child: Row(
                  children: const [
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
    final filtered = _products
        .where(
          (p) => p["name"].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ),
        )
        .toList();

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text("Produk tidak ditemukan"))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _buildProductItem(filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
