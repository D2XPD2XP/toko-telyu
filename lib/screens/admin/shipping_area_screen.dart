import 'package:flutter/material.dart';

class ShippingAreaScreen extends StatefulWidget {
  const ShippingAreaScreen({super.key});

  @override
  State<ShippingAreaScreen> createState() => _ShippingAreaScreenState();
}

class _ShippingAreaScreenState extends State<ShippingAreaScreen> {
  final Color primaryColor = const Color(0xFFED1E28);

  final List<Map<String, dynamic>> _areas = [
    {"city": "Jakarta", "cost": 10000},
    {"city": "Bandung", "cost": 15000},
  ];

  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  // ---------------------------------------------------------
  // OPEN FORM (Add / Edit)
  // ---------------------------------------------------------
  void _openAreaForm({Map<String, dynamic>? data, int? index}) {
    final isEdit = data != null;

    _cityController.text = isEdit ? data["city"] : "";
    _costController.text = isEdit ? data["cost"].toString() : "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _buildFormSheet(isEdit: isEdit, index: index),
    );
  }

  // ---------------------------------------------------------
  // FORM BOTTOM SHEET UI
  // ---------------------------------------------------------
  Widget _buildFormSheet({required bool isEdit, int? index}) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEdit ? "Edit Shipping Area" : "Add Shipping Area",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),

          _buildTextField(controller: _cityController, label: "City"),

          const SizedBox(height: 14),

          _buildTextField(
            controller: _costController,
            label: "Shipping Cost",
            keyboard: TextInputType.number,
          ),

          const SizedBox(height: 20),

          _buildSaveButton(isEdit: isEdit, index: index),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // CUSTOM TEXT FIELD
  // ---------------------------------------------------------
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // SAVE BUTTON
  // ---------------------------------------------------------
  Widget _buildSaveButton({required bool isEdit, int? index}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _onSavePressed(isEdit: isEdit, index: index),
        child: Text(
          isEdit ? "Save Changes" : "Add Area",
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // SAVE LOGIC
  // ---------------------------------------------------------
  VoidCallback _onSavePressed({required bool isEdit, int? index}) {
    return () {
      if (_cityController.text.isEmpty || _costController.text.isEmpty) return;

      final newData = {
        "city": _cityController.text,
        "cost": int.tryParse(_costController.text) ?? 0,
      };

      setState(() {
        if (isEdit && index != null) {
          _areas[index] = newData;
        } else {
          _areas.add(newData);
        }
      });

      Navigator.pop(context);
    };
  }

  // ---------------------------------------------------------
  // AREA ITEM CARD
  // ---------------------------------------------------------
  Widget _buildAreaCard(Map<String, dynamic> area, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              area["city"],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          Text(
            "Rp ${area["cost"]}",
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),

          const SizedBox(width: 12),

          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => _openAreaForm(data: area, index: index),
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline, size: 22),
            color: Colors.red,
            onPressed: () {
              setState(() => _areas.removeAt(index));
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Shipping Area & Rates",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.6,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _openAreaForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      backgroundColor: Colors.grey[100],

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _areas.length,
        itemBuilder: (_, index) => _buildAreaCard(_areas[index], index),
      ),
    );
  }
}
