import 'package:flutter/material.dart';

class TopNavbar extends StatefulWidget {
  const TopNavbar({
    super.key,
    required this.onSubmitted,
    required this.text,
    required this.onchanged,
  });
  final void Function(String) onSubmitted;
  final String text;
  final bool onchanged;

  @override
  State<TopNavbar> createState() => _TopNavbarState();
}

class _TopNavbarState extends State<TopNavbar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 2,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onSubmitted: (value) {
          widget.onSubmitted(value);
          _controller.clear();
        },
        onChanged: widget.onchanged
            ? (value) {
                widget.onSubmitted(value);
              }
            : null,
        decoration: InputDecoration(
          hintText: widget.text,
          hintStyle: TextStyle(color: Color(0xFF777777), fontSize: 10),
          prefixIcon: Icon(Icons.search, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 2),
        ),
      ),
    );
  }
}
