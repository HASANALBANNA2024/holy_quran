import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'dart:math';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:holy_quran/logics/prayer_logic.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class NotificationService {

  static Future<void> init(Function(String?) onNotificationClick) async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationClick(response.payload);
      },
    );

    if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      // ১. নোটিফিকেশন চ্যানেল তৈরি (মাস্ট)
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'daily_guidance_id',
        'Daily Guidance',
        description: 'Quranic wisdom and reminders',
        importance: Importance.max,
      );
      await androidImplementation?.createNotificationChannel(channel);

      // ২. পারমিশন রিকোয়েস্ট
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  // GuidanceData থেকে শিডিউল করার নতুন মেথড
  static Future<void> scheduleDailyGuidance(Map<String, List<String>> categories) async {
    final random = Random();
    String category = categories.keys.elementAt(random.nextInt(categories.length));
    List<String> ayats = categories[category]!;
    String ayatRef = ayats[random.nextInt(ayats.length)];

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_guidance_id',
      'Daily Guidance',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999,
      category,
      "আজকের আয়াত রেফারেন্স: $ayatRef. কোরআন থেকে আয়াতটি পড়ে নিন।",
      // daily message of ayah with reference
      _nextInstanceOfTime(16, 20), // প্রতিদিন সকাল ৯টায়
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
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

    int id = 100;
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
              playSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    });
  }
  static Future<void> showInstantNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'daily_guidance_id', // আগের চ্যানেলের সাথে মিল রাখা হয়েছে
      'Daily Guidance',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // আইডি
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> cancelAll() async => await flutterLocalNotificationsPlugin.cancelAll();
}
