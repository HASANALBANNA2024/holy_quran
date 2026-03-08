// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:holy_quran/models/last_read_model.dart';
//
// class LastReadController {
//   static Future<LastReadModel> fetchLastRead() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     String? surahName = prefs.getString('last_surah_name');
//     int? surahIndex = prefs.getInt('last_surah_index');
//     int? ayahNum = prefs.getInt('last_ayah_num');
//     String? arabic = prefs.getString('last_arabic');
//     String? translation = prefs.getString('last_translation');
//
//     if (surahName == null) {
//       return LastReadModel(
//         surahName: "Al-Muzzammil",
//         surahIndex: 73,
//         ayahNumber: 4,
//         arabicText: "أَوْ زِدْ عَلَيْهِ وَرَتِّلِ الْقُرْآنَ تَرْتِيلًا",
//         translation: "And recite the Qur'an with measured recitation.",
//       );
//     }
//
//     return LastReadModel(
//       surahName: surahName ?? "Al-Fatihah",
//       surahIndex: surahIndex ?? 1,
//       ayahNumber: ayahNum ?? 1,
//       arabicText: arabic ?? "",
//       translation: translation ?? "",
//     );
//   }
// }