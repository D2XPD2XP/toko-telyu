import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({super.key, required this.ctx, required this.message});

  final BuildContext ctx;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        "Invalid Input!",
        style: TextStyle(color: Color(0xFFED1E28), fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(
                const Color.fromARGB(255, 255, 255, 255),
              ),
              backgroundColor: WidgetStateProperty.all(const Color(0xFFED1E28)),
            ),
            child: Text("OK"),
          ),
        ),
      ],
    );
  }
}
