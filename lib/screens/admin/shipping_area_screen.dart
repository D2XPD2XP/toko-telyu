import 'package:flutter/material.dart';
import 'package:toko_telyu/models/delivery_area.dart';
import 'package:toko_telyu/services/delivery_area_services.dart';
import 'package:toko_telyu/widgets/formatted_price.dart';

class ShippingAreaScreen extends StatefulWidget {
  const ShippingAreaScreen({super.key});

  @override
  State<ShippingAreaScreen> createState() => _ShippingAreaScreenState();
}

class _ShippingAreaScreenState extends State<ShippingAreaScreen> {
  final Color primaryColor = const Color(0xFFED1E28);
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final DeliveryAreaService _deliveryAreaService = DeliveryAreaService();
  List<DeliveryArea> _areas = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
    });
    _areas = await _deliveryAreaService.fetchAllAreas();
    setState(() {
      loading = false;
    });
  }

  // ---------------------------------------------------------
  // OPEN FORM (Add / Edit)
  // ---------------------------------------------------------
  void _openAreaForm({DeliveryArea? data, int? index}) {
    final isEdit = data != null;

    _cityController.text = isEdit ? data.getAreaname() : "";
    _costController.text = isEdit ? data.getDeliveryfee().toString() : "";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => isEdit
          ? _buildFormSheet(id: data.getAreaId(), isEdit: isEdit, index: index)
          : _buildFormSheet(isEdit: isEdit, index: index),
    );
  }

  // ---------------------------------------------------------
  // FORM BOTTOM SHEET UI
  // ---------------------------------------------------------
  Widget _buildFormSheet({String? id, required bool isEdit, int? index}) {
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

          _buildTextField(controller: _cityController, label: "Area Name"),

          const SizedBox(height: 14),

          _buildTextField(
            controller: _costController,
            label: "Shipping Cost",
            keyboard: TextInputType.number,
          ),

          const SizedBox(height: 20),

          _buildSaveButton(id: id, isEdit: isEdit, index: index),

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
  Widget _buildSaveButton({String? id, required bool isEdit, int? index}) {
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
        onPressed: () async =>
            _onSavePressed(id: id, isEdit: isEdit, index: index),
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
  Future<void> _onSavePressed({
    String? id,
    required bool isEdit,
    int? index,
  }) async {
    if (_cityController.text.isEmpty || _costController.text.isEmpty) return;

    if (isEdit && index != null) {
      await _deliveryAreaService.updateArea(
        id!,
        _cityController.text,
        double.parse(_costController.text),
      );
    } else {
      await _deliveryAreaService.createArea(
        _cityController.text,
        double.parse(_costController.text),
      );
    }

    await loadData();

    Navigator.pop(context);
  }

  // ---------------------------------------------------------
  // AREA ITEM CARD
  // ---------------------------------------------------------
  Widget _buildAreaCard(DeliveryArea area, int index) {
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
              area.getAreaname(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          FormattedPrice(
            price: area.getDeliveryfee(),
            size: 14,
            fontWeight: FontWeight.w200,
          ),

          const SizedBox(width: 12),

          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => _openAreaForm(data: area, index: index),
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline, size: 22),
            color: Colors.red,
            onPressed: () async {
              await _deliveryAreaService.deleteArea(area.getAreaId());
              setState(() {});
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
