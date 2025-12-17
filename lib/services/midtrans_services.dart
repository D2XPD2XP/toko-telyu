import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MidtransService {
  final String baseUrl;

  MidtransService({required this.baseUrl});

  Future<Map<String, String>?> createTransaction({
    required String orderId,
    required int amount,
    required String customerName,
    required String customerEmail,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/transaction'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'orderId': orderId,
              'amount': amount,
              'customerName': customerName,
              'customerEmail': customerEmail,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        debugPrint("Midtrans Error: ${response.statusCode} | ${response.body}");
        return null;
      }

      final data = jsonDecode(response.body);
      if (data is! Map) {
        debugPrint("Invalid API response format");
        return null;
      }

      return {
        "transactionToken": data['transactionToken'].toString(),
        "redirectUrl": data['redirectUrl'].toString(),
      };
    } catch (e) {
      debugPrint("Midtrans createTransaction error: $e");
      return null;
    }
  }
}
