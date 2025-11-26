import 'package:flutter/material.dart';

class EditProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final Widget? trailingIcon;
  final Color? valueColor;

  const EditProfileRow({
    Key? key,
    required this.label,
    required this.value,
    required this.onTap,
    this.trailingIcon,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            // Label (cth: "Name")
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),

            // Spacer
            Expanded(child: Container()),

            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color:
                    valueColor ??
                    Colors.black54, // Pakai warna custom atau default
                fontWeight: FontWeight.w400,
              ),
            ),

            SizedBox(width: 8),

            if (trailingIcon != null) trailingIcon!,
          ],
        ),
      ),
    );
  }
}
