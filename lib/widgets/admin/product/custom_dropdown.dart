import 'package:flutter/material.dart';
import '../../../models/product_category.dart';

class ProductCustomDropdown extends StatefulWidget {
  final List<ProductCategory> items;
  final ProductCategory? selected;
  final void Function(ProductCategory) onChanged;

  const ProductCustomDropdown({
    super.key,
    required this.items,
    this.selected,
    required this.onChanged,
  });

  @override
  State<ProductCustomDropdown> createState() => _ProductCustomDropdownState();
}

class _ProductCustomDropdownState extends State<ProductCustomDropdown> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _overlay;
  bool _open = false;
  ProductCategory? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.selected;
  }

  void _toggleDropdown() {
    if (_open) {
      _overlay?.remove();
      _open = false;
    } else {
      _overlay = _createOverlay();
      Overlay.of(context).insert(_overlay!);
      _open = true;
    }
  }

  OverlayEntry _createOverlay() {
    RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final offset = box.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleDropdown,
              behavior: HitTestBehavior.translucent,
            ),
          ),

          Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 5,
            width: size.width,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final c = widget.items[index];
                    final isSelected = c == selected;

                    return InkWell(
                      onTap: () {
                        setState(() => selected = c);
                        widget.onChanged(c);
                        _toggleDropdown();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.grey.shade200
                              : Colors.white,
                        ),
                        child: Text(
                          c.categoryName,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFFED1E28)
                                : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selected?.categoryName ?? "Select a category",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Color(0xFFED1E28)),
            ],
          ),
        ),
      ),
    );
  }
}
