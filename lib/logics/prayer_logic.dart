// import 'package:adhan/adhan.dart';
// import 'package:geolocator/geolocator.dart';
//
// class PrayerLogic {
//   // নামাজের সময় বের করার মেইন ফাংশন
//   static Future<PrayerTimes> getPrayerTimes() async {
//     // ১. ইউজারের কারেন্ট লোকেশন নেওয়া
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.low);
//
//     // ২. স্থানাঙ্ক সেট করা
//     final coordinates = Coordinates(position.latitude, position.longitude);
//
//     // ৩. মেথড সেট করা (বাংলাদেশের জন্য Karachi/Islamic Society of North America সাধারণত মিলে)
//     final params = CalculationMethod.karachi.getParameters();
//     params.madhab = Madhab.hanafi;
//
//     // ৪. বর্তমান তারিখের Prayer Times রিটার্ন করা
//     return PrayerTimes.today(coordinates, params);
//   }
//
//   // পরবর্তী নামাজের নাম এবং বাকি সময় বের করা
//   static String getNextPrayerName(PrayerTimes prayerTimes) {
//     final next = prayerTimes.nextPrayer();
//     if (next == Prayer.fajr) return "FAJR";
//     if (next == Prayer.dhuhr) return "DHUHR";
//     if (next == Prayer.asr) return "ASR";
//     if (next == Prayer.maghrib) return "MAGHRIB";
//     if (next == Prayer.isha) return "ISHA";
//     return "FAJR";
//   }
// }

import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class PrayerLogic {
  static Future<PrayerTimes> getPrayerTimes() async {
    // ইউজারের বর্তমান লোকেশন নেওয়া
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);

    final coordinates = Coordinates(position.latitude, position.longitude);

    // বাংলাদেশ ও এশিয়ার জন্য সাধারণত করাচি মেথড এবং হানাফি মাযহাব ব্যবহার হয়
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;

    return PrayerTimes.today(coordinates, params);
  }

  static String getRemainingTime(DateTime targetTime) {
    DateTime now = DateTime.now();

    // যদি টার্গেট টাইম বর্তমান সময়ের আগে হয় (যেমন রাত ১২টার পর ফজর), তবে ১ দিন যোগ হবে
    if (targetTime.isBefore(now)) {
      targetTime = targetTime.add(const Duration(days: 1));
    }

    final remaining = targetTime.difference(now);

    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');

    return "$hours:$minutes:$seconds";
  }
}