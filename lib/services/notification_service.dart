import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

// notification_service.dart ফাইলে এটি রিপ্লেস করুন
  static Future<void> init(Function(String?) onNotificationClick) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // এই লাইনটিই আপনার পাঠানো ফাংশনটিকে কল করবে
        onNotificationClick(details.payload);
      },
    );
  }

  static Future<void> showInstantNotification({
    required String title, required String body, required String payload
  }) async {
    const androidDetail = AndroidNotificationDetails(
      'quran_guidance', 'Quran Guidance',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      // সাউন্ড কাস্টমাইজ করতে চাইলে এখানে sound: RawResourceAndroidNotificationSound('mysound') দিতে পারো
    );

    await _notifications.show(0, title, body, const NotificationDetails(android: androidDetail), payload: payload);
  }
}