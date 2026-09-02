import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around Firebase Cloud Messaging setup (§48).
/// Notification content/targeting itself is admin-configured and sent
/// server-side via the `sendNotification` Cloud Function -- this service
/// only handles device registration and permission requests.
class MessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await _messaging.getToken();
      if (kDebugMode) {
        debugPrint('FCM token: $token');
      }

      FirebaseMessaging.onMessage.listen((message) {
        if (kDebugMode) {
          debugPrint('Foreground FCM message: ${message.notification?.title}');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('MessagingService.init failed: $e');
      }
    }
  }
}
