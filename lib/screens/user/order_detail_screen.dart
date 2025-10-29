import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  // Anda bisa tambahkan parameter 'orderId' di sini nanti
  const OrderDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Pesanan")),
      body: Center(child: Text("Ini adalah halaman Detail Pesanan")),
    );
  }
}
