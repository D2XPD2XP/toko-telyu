import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final String _baseUrl = "https://toko-telyu-service.vercel.app";

  static Future<void> initialize() async {
    await AwesomeNotifications().initialize('resource://drawable/notif_icon', [
      NotificationChannel(
        channelKey: 'default_channel',
        channelName: 'General Notifications',
        channelDescription: 'Notification channel for general messages',
        importance: NotificationImportance.Max,
        defaultColor: const Color(0xFFED1E28),
        ledColor: const Color(0xFFFFFFFF),
        icon: 'resource://drawable/notif_icon',
      ),
    ], debug: true);

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'default_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
        ),
      );
    } catch (e, s) {
      debugPrint('Failed to show notification: $e\n$s');
    }
  }

  static Future<void> notifyAdminsNewOrder({
    required String orderId,
    required String customerName,
  }) async {
    final url = Uri.parse('$_baseUrl/api/notifications/order-new');
    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'orderId': orderId, 'customerName': customerName}),
        )
        .timeout(Duration(seconds: 10));

    if (res.statusCode != 200) {
      debugPrint('Failed to notify admins: ${res.body}');
    }
  }

  static Future<void> notifyUserOrderStatus({
    required String customerId,
    required String orderId,
    required String newStatus,
  }) async {
    final url = Uri.parse('$_baseUrl/api/notifications/order-status');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customerId': customerId,
        'orderId': orderId,
        'newStatus': newStatus,
      }),
    );

    if (res.statusCode != 200) {
      debugPrint('Failed to notify user: ${res.body}');
    }
  }
}
