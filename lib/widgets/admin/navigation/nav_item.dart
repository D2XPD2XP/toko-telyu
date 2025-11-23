import 'package:flutter/material.dart';
import 'nav_item_model.dart';

class NavItem extends StatelessWidget {
  final bool isActive;
  final NavItemModel item;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.isActive,
    required this.item,
    required this.onTap,
    required Color activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 14 : 0,
          vertical: isActive ? 8 : 0,
        ),
        decoration: isActive
            ? BoxDecoration(
                color: const Color(0xFFED1E28).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Row(
          children: [
            Icon(
              item.icon,
              color: isActive ? const Color(0xFFED1E28) : Colors.grey,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                item.label,
                style: const TextStyle(
                  color: Color(0xFFED1E28),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
