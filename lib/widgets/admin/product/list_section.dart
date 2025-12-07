import 'package:flutter/material.dart';

class ProductListSection<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final void Function(T) onDelete;
  final VoidCallback onAdd;
  final String addLabel;
  final String Function(T) displayText;

  const ProductListSection({
    super.key,
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
          ...items.map(
            (item) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(displayText(item))),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(item),
                ),
              ],
            ),
          ),
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
