import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:toko_telyu/services/notification_services.dart';

class FcmService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> setup(String userId) async {
    try {
      final token = await _fcm.getToken();
      if (token != null) await _updateToken(userId, token);
    } catch (e, stack) {
      debugPrint('Error getting FCM token: $e\n$stack');
    }

    _fcm.onTokenRefresh.listen((newToken) async {
      try {
        await _updateToken(userId, newToken);
      } catch (e, stack) {
        debugPrint('Error updating FCM token: $e\n$stack');
      }
    });

    FirebaseMessaging.onMessage.listen((message) async {
      try {
        final title =
            message.notification?.title ??
            message.data['title'] ??
            'Notification';
        final body = message.notification?.body ?? message.data['body'] ?? '';
        await NotificationService.showNotification(title: title, body: body);
        debugPrint('Foreground message shown: $title | $body');
      } catch (e, stack) {
        debugPrint('Error showing foreground notification: $e\n$stack');
      }
    });
  }

  static Future<void> _updateToken(String userId, String token) async {
    try {
      await FirebaseFirestore.instance.collection('user').doc(userId).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
      debugPrint('FCM token updated: $token');
    } catch (e, stack) {
      debugPrint('Error updating FCM token in Firestore: $e\n$stack');
    }
  }
}
