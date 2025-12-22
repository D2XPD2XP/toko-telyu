import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toko_telyu/models/product_category.dart';
import 'package:toko_telyu/services/product_category_services.dart';
import 'package:toko_telyu/widgets/product_image.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ProductCategoryService _service = ProductCategoryService();
  final Color primaryColor = const Color(0xFFED1E28);

  List<ProductCategory> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';

  double get bottomPadding => MediaQuery.of(context).padding.bottom + 40;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      _categories = await _service.getCategories();
    } catch (e) {
      if (kDebugMode) debugPrint('Load categories error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ProductCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories
        .where(
          (c) =>
              c.categoryName.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  Future<void> _showCategoryForm({ProductCategory? category}) async {
    final nameCtrl = TextEditingController(text: category?.categoryName ?? '');
    bool isFittable = category?.isFittable ?? false;
    File? selectedImage;
    bool isUploadingImage = false;

    Future<void> pickImage(StateSetter setModalState) async {
      setModalState(() => isUploadingImage = true);
      try {
        final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          selectedImage = File(image.path);
        }
      } finally {
        setModalState(() => isUploadingImage = false);
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          top: false,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category == null ? 'Add New Category' : 'Edit Category',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Fittable',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: isFittable,
                                activeColor: primaryColor,
                                onChanged: (v) =>
                                    setModalState(() => isFittable = v),
                              ),
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          onPressed: isUploadingImage
                              ? null
                              : () => pickImage(setModalState),
                          icon: isUploadingImage
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: primaryColor,
                                  ),
                                )
                              : Icon(Icons.upload_file, color: primaryColor),
                          label: Text(
                            selectedImage != null ||
                                    (category != null &&
                                        category.iconUrl.isNotEmpty)
                                ? 'Change Image'
                                : 'Upload Image',
                            style: TextStyle(color: primaryColor),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    selectedImage!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : ProductImageView(
                                  imageUrl: category?.iconUrl,
                                  size: 100,
                                ),
                          if (isUploadingImage)
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: primaryColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isUploadingImage
                            ? null
                            : () async {
                                final name = nameCtrl.text.trim();
                                if (name.isEmpty) return;

                                Navigator.pop(context);

                                try {
                                  if (category == null) {
                                    if (selectedImage == null) return;
                                    await _service.createCategoryWithImage(
                                      name,
                                      isFittable,
                                      selectedImage!,
                                    );
                                  } else {
                                    if (selectedImage != null) {
                                      await _service.updateCategoryWithImage(
                                        category.categoryId,
                                        {
                                          'category_name': name,
                                          'is_fittable': isFittable,
                                        },
                                        selectedImage!,
                                      );
                                    } else {
                                      await _service
                                          .updateCategory(category.categoryId, {
                                            'category_name': name,
                                            'is_fittable': isFittable,
                                          });
                                    }
                                  }
                                  await _loadCategories();
                                } catch (e) {
                                  if (kDebugMode) {
                                    debugPrint('Submit category error: $e');
                                  }
                                }
                              },
                        child: Text(
                          category == null ? 'Save Category' : 'Save Changes',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _deleteCategory(ProductCategory category) async {
    final confirmed =
        await showDialog<bool>(
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
                'Delete Category',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              content: const Text(
                'This category will be permanently deleted.',
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

    if (!confirmed) return;

    try {
      final isUsed = await _service.isCategoryUsed(category.categoryId);
      if (isUsed) {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Cannot Delete',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            content: const Text(
              'This category is currently used by products.',
              style: TextStyle(color: Colors.black87),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
        return;
      }

      await _service.deleteCategory(category.categoryId);
      await _loadCategories();
    } catch (e) {
      if (kDebugMode) debugPrint('Delete category error: $e');
    }
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (v) => setState(() => _searchQuery = v),
      decoration: InputDecoration(
        hintText: 'Search Category...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
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
          ProductImageView(imageUrl: category.iconUrl, size: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                    category.isFittable ? 'Fittable' : 'Not Fittable',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Category',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.grey[100],
        surfaceTintColor: Colors.grey[100],
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => _showCategoryForm(),
              borderRadius: BorderRadius.circular(50),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                color: primaryColor,
                onRefresh: _loadCategories,
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : _filteredCategories.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('No Categories Found')),
                        ],
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: bottomPadding),
                        itemCount: _filteredCategories.length,
                        itemBuilder: (_, i) =>
                            _buildCategoryItem(_filteredCategories[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
