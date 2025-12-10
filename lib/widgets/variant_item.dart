import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VariantItem extends StatelessWidget {
  const VariantItem({
    super.key,
    required this.variant,
    required this.isSelected,
    required this.idx,
    required this.onTap,
  });

  final String variant;
  final bool isSelected;
  final int idx;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {onTap(idx);},
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 18),
        height: 25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: !isSelected ? Color(0xFF959597) : Color(0xFFED1E28),
          ),
        ),
        child: Text(
          variant,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Color(0xFFED1E28) : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
