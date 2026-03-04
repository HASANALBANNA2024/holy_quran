import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class PrayerLogic {
  static Future<PrayerTimes?> getPrayerTimes() async {
    try {
      // ১. পারমিশন চেক করুন
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("📍 Location service is disabled");
        // লোকেশন সার্ভিস বন্ধ থাকলে ঢাকার টাইম দেখান
        return _getDefaultDhakaTime();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("📍 Location permission denied");
          return _getDefaultDhakaTime();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("📍 Location permission permanently denied");
        return _getDefaultDhakaTime();
      }

      // ২. টাইমআউট সহ লোকেশন নিন
      Position position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low, // Low দ্রুত কাজ করে
            timeLimit: const Duration(seconds: 5), // ৫ সেকেন্ডের বেশি না
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print("📍 Location timeout - using default");
              throw TimeoutException('Location timeout');
            },
          );

      print("📍 Location: ${position.latitude}, ${position.longitude}");

      final coordinates = Coordinates(position.latitude, position.longitude);

      // বাংলাদেশ ও এশিয়ার জন্য করাচি মেথড
      final params = CalculationMethod.karachi.getParameters();
      params.madhab = Madhab.hanafi;

      // অ্যাডজাস্টমেন্ট যোগ করুন (বাংলাদেশের জন্য)
      params.adjustments = PrayerAdjustments(
        fajr: 4, // ফজর +৪ মিনিট
        sunrise: 0,
        dhuhr: 0,
        asr: 0,
        maghrib: 2, // মাগরিব +২ মিনিট
        isha: 4, // ইশা +৪ মিনিট
      );

      return PrayerTimes.today(coordinates, params);
    } catch (e) {
      print("❌ Error getting prayer times: $e");
      // কোনো এরর হলে ঢাকার টাইম দেখান
      return _getDefaultDhakaTime();
    }
  }

  // ডিফল্ট ঢাকার টাইম
  static PrayerTimes _getDefaultDhakaTime() {
    print("📍 Using default Dhaka time");
    final dhaka = Coordinates(23.8103, 90.4125);
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;

    return PrayerTimes.today(dhaka, params);
  }

  static String getRemainingTime(DateTime targetTime) {
    DateTime now = DateTime.now();

    if (targetTime.isBefore(now)) {
      targetTime = targetTime.add(const Duration(days: 1));
    }

    final remaining = targetTime.difference(now);

    // নেগেটিভ টাইম হলে ০০:০০:০০ দেখান
    if (remaining.isNegative) {
      return "00:00:00";
    }

    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');

    return "$hours:$minutes:$seconds";
  }
}
