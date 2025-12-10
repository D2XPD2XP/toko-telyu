import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toko_telyu/models/product_category.dart';
import 'package:toko_telyu/services/product_category_services.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final Color primaryColor = const Color(0xFFED1E28);
  final ProductCategoryService _service = ProductCategoryService();
  double get bottomPadding => MediaQuery.of(context).padding.bottom + 50;

  List<ProductCategory> _categories = [];
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      _categories = await _service.getCategories();
    } catch (e) {
      print("Error loading categories: $e");
    }
    setState(() => _isLoading = false);
  }

  List<ProductCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories
        .where(
          (cat) => cat.categoryName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  void _showCategoryForm({ProductCategory? category}) {
    final TextEditingController nameCtrl = TextEditingController(
      text: category?.categoryName ?? "",
    );
    bool isFittable = category?.isFittable ?? false;
    File? selectedImage;

    void pickImage() async {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    category == null ? "Add New Category" : "Edit Category",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name field
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: "Category Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Row: Fittable + Upload/Change Image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Fittable",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Transform.scale(
                            scale: 0.8, // mengecilkan switch
                            child: Switch(
                              value: isFittable,
                              onChanged: (val) {
                                setModalState(() => isFittable = val);
                              },
                              activeColor: const Color(0xFFED1E28),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(
                          Icons.upload_file,
                          color: Color(0xFFED1E28),
                        ),
                        label: Text(
                          selectedImage != null
                              ? "Change Image"
                              : category != null && category.iconUrl.isNotEmpty
                              ? "Change Image"
                              : "Upload Image",
                          style: const TextStyle(color: Color(0xFFED1E28)),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFED1E28)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Image Preview
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.grey.shade100,
                        image: selectedImage != null
                            ? DecorationImage(
                                image: FileImage(selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : category != null && category.iconUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(category.iconUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child:
                          selectedImage == null &&
                              (category == null || category.iconUrl.isEmpty)
                          ? const Icon(Icons.image, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) return;

                        if (category == null) {
                          await _service.createCategory(
                            name,
                            isFittable,
                            selectedImage?.path ?? "",
                          );
                        } else {
                          await _service.updateCategory(category.categoryId, {
                            "category_name": name,
                            "is_fittable": isFittable,
                            "icon_url": selectedImage?.path ?? category.iconUrl,
                          });
                        }

                        Navigator.pop(context);
                        _loadCategories();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFED1E28),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        category == null ? "Save Category" : "Save Changes",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteCategory(ProductCategory category) async {
    await _service.deleteCategory(category.categoryId);
    _loadCategories();
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: const InputDecoration(
          hintText: "Search Category...",
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCategoryItem(ProductCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          category.iconUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    category.iconUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                )
              : Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.categoryName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: category.isFittable
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category.isFittable ? "Fittable" : "Not Fittable",
                    style: TextStyle(
                      fontSize: 12,
                      color: category.isFittable
                          ? Colors.green.shade800
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _showCategoryForm(category: category),
                icon: Icon(Icons.edit, color: primaryColor),
              ),
              IconButton(
                onPressed: () => _deleteCategory(category),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Category",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () => _showCategoryForm(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCategories.isEmpty
                  ? const Center(child: Text("No Categories Found"))
                  : ListView.builder(
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      itemCount: _filteredCategories.length,
                      itemBuilder: (_, index) =>
                          _buildCategoryItem(_filteredCategories[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
