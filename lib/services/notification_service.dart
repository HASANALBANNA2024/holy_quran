import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
class NotificationService {

  // ১. সব নোটিফিকেশন বন্ধ করার জন্য
  static Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print("✅ সব নোটিফিকেশন বন্ধ করা হয়েছে");
  }

  // ২. নামাজের সময় অনুযায়ী আবার সব নোটিফিকেশন সেট করার জন্য
  static Future<void> scheduleAll() async {
    // এখানে আপনার নামাজের সময় বের করে নোটিফিকেশন শিডিউল করার মেইন লজিক কল করবেন
    // উদাহরণস্বরূপ:
    // await schedulePrayerNotifications();
    print("✅ সব নোটিফিকেশন আবার চালু করা হয়েছে");
  }

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
  void _toggleNotifications(bool value) async {
    // ১. মেমরিতে সেভ করার জন্য (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotifOn', value);

    // ২. নোটিফিকেশন বন্ধ বা চালু করার জন্য
    if (value == false) {
      await NotificationService.cancelAll(); // সব বন্ধ
    } else {
      await NotificationService.scheduleAll(); // আবার চালু
    }
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