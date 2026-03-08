import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:adhan/adhan.dart';
import 'package:holy_quran/logics/prayer_logic.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class NotificationService {

  static Future<void> init(Function(String?) onNotificationClick) async {
    // ১. টাইমজোন ডাটা লোড করা
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    // ২. নোটিফিকেশন প্লাগইন ইনিশিয়ালাইজ করা
    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationClick(response.payload);
      },
    );

    // অ্যান্ড্রয়েড ১৩+ এর জন্য পারমিশন চেক (লাল দাগ দূর করা হয়েছে)
    if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      // এটি সরাসরি পারমিশন পপ-আপ দেখাবে
      await androidImplementation?.requestNotificationsPermission();

      // Exact Alarm পারমিশন চেক (অ্যান্ড্রয়েড ১৩ ও ১৪ এর এরর দূর করতে)
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'instant_notification_channel',
      'Instant Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
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
    final prayerTimes = await PrayerLogic.getPrayerTimes();
    if (prayerTimes == null) return;

    Map<String, DateTime> prayers = {
      "Fajr": prayerTimes.fajr,
      "Dhuhr": prayerTimes.dhuhr,
      "Asr": prayerTimes.asr,
      "Maghrib": prayerTimes.maghrib,
      "Isha": prayerTimes.isha,
    };

    int id = 100; // নামাজের জন্য আলাদা আইডি রেঞ্জ
    prayers.forEach((name, time) async {
      if (time.isAfter(DateTime.now())) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id++,
          'Prayer Time',
          'It is time for $name',
          tz.TZDateTime.from(time, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_zone',
              'Prayers',
              importance: Importance.max,
              priority: Priority.high,
              // sound: RawResourceAndroidNotificationSound('notification_sound'), // যদি সাউন্ড থাকে
              playSound: true, // এটি দিলে ফোনের ডিফল্ট সাউন্ড বাজবে
              fullScreenIntent: true,
            ),
          ),
          // আপনার ভার্সন অনুযায়ী সঠিক প্রপার্টি
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    });
    print("✅ Prayers Scheduled");
  }
}