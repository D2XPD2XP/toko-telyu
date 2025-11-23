import 'package:flutter/material.dart';

class PickupPointScreen extends StatefulWidget {
  const PickupPointScreen({super.key});

  @override
  State<PickupPointScreen> createState() => _PickupPointScreenState();
}

class _PickupPointScreenState extends State<PickupPointScreen> {
  final Color primaryColor = const Color(0xFFED1E28);

  // Data pickup point dummy (sementara)
  final List<Map<String, String>> pickupPoints = [
    {"name": "Main Warehouse", "address": "Jl. Melati No. 22, Jakarta"},
    {"name": "Bandung Hub", "address": "Jl. Sukajadi No. 11, Bandung"},
  ];

  // Controllers form
  final TextEditingController nameC = TextEditingController();
  final TextEditingController addressC = TextEditingController();

  // -------------------------------------------------------------------
  // OPEN FORM (ADD / EDIT)
  // -------------------------------------------------------------------
  void _openPickupForm({Map<String, String>? initial, int? index}) {
    if (initial != null) {
      nameC.text = initial["name"]!;
      addressC.text = initial["address"]!;
    } else {
      nameC.clear();
      addressC.clear();
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => PickupPointFormSheet(
        nameC: nameC,
        addressC: addressC,
        primaryColor: primaryColor,
        isEdit: initial != null,
        onSave: () {
          if (initial == null) {
            setState(() {
              pickupPoints.add({"name": nameC.text, "address": addressC.text});
            });
          } else {
            setState(() {
              pickupPoints[index!] = {
                "name": nameC.text,
                "address": addressC.text,
              };
            });
          }
        },
      ),
    );
  }

  // -------------------------------------------------------------------
  // MAIN UI
  // -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _openPickupForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pickupPoints.length,
        itemBuilder: (_, index) {
          final data = pickupPoints[index];
          return PickupPointItem(
            data: data,
            onEdit: () => _openPickupForm(initial: data, index: index),
            onDelete: () {
              setState(() => pickupPoints.removeAt(index));
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Pickup Point Management",
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 0.6,
    );
  }
}

//
// =======================================================================
// COMPONENT: Pickup Point Item
// =======================================================================
//
class PickupPointItem extends StatelessWidget {
  final Map<String, String> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PickupPointItem({
    super.key,
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT: name + address
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["name"]!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data["address"]!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // EDIT BUTTON
          IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),

          // DELETE BUTTON
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

//
// =======================================================================
// COMPONENT: FORM BOTTOM SHEET
// =======================================================================
//
class PickupPointFormSheet extends StatelessWidget {
  final TextEditingController nameC;
  final TextEditingController addressC;
  final Color primaryColor;
  final bool isEdit;
  final VoidCallback onSave;

  const PickupPointFormSheet({
    super.key,
    required this.nameC,
    required this.addressC,
    required this.primaryColor,
    required this.isEdit,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEdit ? "Edit Pickup Point" : "Add Pickup Point",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 20),

          // NAME FIELD
          _buildTextField(controller: nameC, label: "Pickup Point Name"),

          const SizedBox(height: 12),

          // ADDRESS FIELD
          _buildTextField(controller: addressC, label: "Address", maxLines: 3),

          const SizedBox(height: 18),

          // SAVE BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (nameC.text.isEmpty || addressC.text.isEmpty) return;
                onSave();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
