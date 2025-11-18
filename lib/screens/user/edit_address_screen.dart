import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditAddressScreen extends StatefulWidget {
  const EditAddressScreen({
    super.key,
    required this.onTap,
    required this.value,
  });

  final Future<void> Function(BuildContext, Map<String, dynamic>) onTap;
  final Map<String, dynamic>? value;

  @override
  State<EditAddressScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditAddressScreen> {
  late TextEditingController _textController;
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedPostalCode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.value?['street'] ?? "",
    );
    _selectedProvince = widget.value?['province'] ?? '';
    _selectedCity = widget.value?['city'] ?? '';
    _selectedDistrict = widget.value?['district'] ?? '';
    _selectedPostalCode = widget.value?['postal_code'] ?? '';
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Address"),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Province', style: TextStyle(fontSize: 17)),
              SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedProvince,
                    items: const [
                      DropdownMenuItem(
                        value: '',
                        child: Text(
                          'Choose Province',
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Jawa Barat',
                        child: Text(
                          'Jawa Barat',
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedProvince = value;
                      });
                    },
                    icon: const SizedBox.shrink(),
                    isExpanded: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('City', style: TextStyle(fontSize: 17)),
              SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCity,
                    items: const [
                      DropdownMenuItem(
                        value: '',
                        child: Text(
                          'Choose City',
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Bandung',
                        child: Text(
                          'Bandung',
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                      });
                    },
                    icon: const SizedBox.shrink(),
                    isExpanded: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('District', style: TextStyle(fontSize: 17)),
              SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDistrict,
                    items: const [
                      DropdownMenuItem(
                        value: '',
                        child: Text(
                          'Choose District',
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Bojongsoang',
                        child: Text(
                          'Bojongsoang',
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDistrict = value;
                      });
                    },
                    icon: const SizedBox.shrink(),
                    isExpanded: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Postal Code', style: TextStyle(fontSize: 17)),
              SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPostalCode,
                    items: const [
                      DropdownMenuItem(
                        value: '',
                        child: Text(
                          'Choose Postal Code',
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                      ),
                      DropdownMenuItem(
                        value: '40257',
                        child: Text(
                          '40257',
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ),
                      DropdownMenuItem(
                        value: '40258',
                        child: Text(
                          '40258',
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ),
                      DropdownMenuItem(
                        value: '40259',
                        child: Text(
                          '40259',
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPostalCode = value;
                      });
                    },
                    icon: const SizedBox.shrink(),
                    isExpanded: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Street', style: TextStyle(fontSize: 17)),
              SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  widget.onTap(context, {
                    'province': _selectedProvince,
                    'city': _selectedCity,
                    'district': _selectedDistrict,
                    'postal_code': _selectedPostalCode,
                    'street': _textController.text
                  });
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFED1E28),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
