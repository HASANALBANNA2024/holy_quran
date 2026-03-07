import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:adhan/adhan.dart';
import 'package:holy_quran/logics/prayer_logic.dart'; // আপনার প্রয়ার লজিক পাথ দিন

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class NotificationService {

  static Future<void> init(Function(String?) onNotificationClick) async {
    // ১. টাইমজোন ডাটা লোড করা (নামাজের সময়ের জন্য জরুরি)
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    // ২. নোটিফিকেশন প্লাগইন ইনিশিয়ালাইজ করা
    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // ইউজার ক্লিক করলে আপনার পাঠানো ফাংশনটি (onNotificationClick) রান করবে
        onNotificationClick(response.payload);
      },
    );
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'instant_notification_channel', // চ্যানেল আইডি
      'Instant Notifications',         // চ্যানেলের নাম
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // নোটিফিকেশন আইডি (ইউনিক হতে হয়)
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
  static Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print("✅ All Notifications Cancelled");
  }

  static Future<void> scheduleAll() async {
    // ১. নামাজের সময় ডাটা নিন
    final prayerTimes = await PrayerLogic.getPrayerTimes();
    if (prayerTimes == null) return;

    // ২. একটি লিস্ট তৈরি করুন নামাজের নাম ও সময়ের
    Map<String, DateTime> prayers = {
      "Fajr": prayerTimes.fajr,
      "Dhuhr": prayerTimes.dhuhr,
      "Asr": prayerTimes.asr,
      "Maghrib": prayerTimes.maghrib,
      "Isha": prayerTimes.isha,
    };

    // ৩. লুপ চালিয়ে প্রতিটি নামাজের জন্য নোটিফিকেশন সেট করুন
    int id = 0;
    prayers.forEach((name, time) async {
      if (time.isAfter(DateTime.now())) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id++,
          'Prayer Time',
          'It is time for $name',
          tz.TZDateTime.from(time, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_zone', 'Prayers',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    });
    print("✅ Prayers Scheduled");
  }
}