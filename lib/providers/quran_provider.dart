// lib/providers/quran_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuranProvider extends ChangeNotifier {
  List<dynamic> _surahs = [];
  Map<String, List<dynamic>> _allTranslations = {}; // সব ভাষার অনুবাদ
  String _currentLang = "en"; // ডিফল্ট ইংরেজি
  bool _isLoading = true;

  List<dynamic> get surahs => _surahs;
  List<dynamic> get translations => _allTranslations[_currentLang] ?? [];
  String get currentLang => _currentLang;
  bool get isLoading => _isLoading;

  // সাপোর্টেড ভাষার তালিকা
  List<Map<String, String>> get supportedLanguages => [
    {'code': 'en', 'name': 'English'},
    {'code': 'bn', 'name': 'বাংলা'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'id', 'name': 'Indonesian'},
    {'code': 'ru', 'name': 'Russian'},
    {'code': 'sv', 'name': 'Swedish'},
    {'code': 'tr', 'name': 'Turkish'},
    {'code': 'ur', 'name': 'Urdu'},
    {'code': 'zh', 'name': 'Chinese'},
  ];

  Future<void> initQuran() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      // ১. আরবী ফাইল লোড
      print("📖 Loading Arabic Quran...");
      final String arabicRes = await rootBundle.loadString(
        'assets/data/quran_arabic.json',
      );
      final Map<String, dynamic> arabicMap = json.decode(arabicRes);
      _surahs = _processArabicData(arabicMap);
      print("✅ Arabic loaded: ${_surahs.length} surahs");

      // ২. সব ভাষার অনুবাদ লোড
      await _loadAllTranslations();

      _isLoading = false;
      print("🎉 All data loaded successfully!");

    } catch (e) {
      _isLoading = false;
      print("❌ Error loading data: $e");
    }
    // ডাটা লোড শেষে UI আপডেট করার নিরাপদ উপায়
    Future.microtask(() => notifyListeners());
  }

  List<dynamic> _processArabicData(Map<String, dynamic> json) {
    List<Map<String, dynamic>> surahList = [];

    for (int i = 1; i <= 114; i++) {
      String surahKey = i.toString();
      if (json.containsKey(surahKey)) {
        List ayahs = json[surahKey] as List;

        List<Map<String, dynamic>> ayahList = [];
        for (int j = 0; j < ayahs.length; j++) {
          ayahList.add({
            'number': ayahs[j]['verse'] ?? (j + 1),
            'text': ayahs[j]['text'] ?? '',
            'numberInSurah': ayahs[j]['verse'] ?? (j + 1),
          });
        }

        surahList.add({
          'number': i,
          'name': _getArabicName(i),
          'englishName': _getEnglishName(i),
          'englishNameTranslation': _getEnglishName(i),
          'revelationType': _getRevelationType(i),
          'ayahs': ayahList,
          'numberOfAyahs': ayahList.length,
        });
      }
    }
    return surahList;
  }

  Future<void> _loadAllTranslations() async {
    List<String> languageCodes = ['en', 'bn', 'es', 'fr', 'id', 'ru', 'sv', 'tr', 'ur', 'zh'];

    for (String code in languageCodes) {
      try {
        print("🔄 Loading $code translation...");

        final String jsonString = await rootBundle.loadString(
          'assets/data/${code}_quran.json',
        );

        final Map<String, dynamic> jsonMap = json.decode(jsonString);

        List<Map<String, dynamic>> translationList = [];

        for (int i = 1; i <= 114; i++) {
          String surahKey = i.toString();
          if (jsonMap.containsKey(surahKey)) {
            List ayahs = jsonMap[surahKey] as List;

            List<Map<String, dynamic>> ayahList = [];
            for (int j = 0; j < ayahs.length; j++) {
              ayahList.add({
                'number': j + 1,
                'text': ayahs[j]['text'] ?? '',
              });
            }

            translationList.add({
              'number': i,
              'ayahs': ayahList,
            });
          }
        }

        _allTranslations[code] = translationList;
        print("✅ $code loaded: ${translationList.length} surahs");

      } catch (e) {
        print("❌ Error loading $code: $e");
        _allTranslations[code] = [];
      }
    }
  }

  Future<void> changeLanguage(String langCode) async {
    if (_currentLang == langCode) return;

    // চেক করুন এই ভাষার অনুবাদ আছে কিনা
    if (_allTranslations[langCode] == null || _allTranslations[langCode]!.isEmpty) {
      print("⚠️ $langCode translation not available");
      return;
    }

    _currentLang = langCode;
    notifyListeners();
    print("🔄 Language changed to: $langCode");
  }

  // হেল্পার মেথড - নির্দিষ্ট সূরার অনুবাদ
  List<Map<String, dynamic>> getSurahTranslation(int surahIndex) {
    if (surahIndex >= translations.length) return [];
    return translations[surahIndex]['ayahs'] ?? [];
  }

  // হেল্পার মেথড - নির্দিষ্ট আয়াতের অনুবাদ
  String getAyahTranslation(int surahIndex, int ayahIndex) {
    try {
      return translations[surahIndex]['ayahs'][ayahIndex]['text'] ?? '';
    } catch (e) {
      return '';
    }
  }

  // চেক করুন ভাষার অনুবাদ আছে কিনা
  bool hasTranslationFor(String languageCode) {
    return _allTranslations[languageCode] != null &&
        _allTranslations[languageCode]!.isNotEmpty;
  }

  // সূরার নাম (আরবী)
  String _getArabicName(int number) {
    Map<int, String> names = {
      1: "الفَاتِحَةُ", 2: "البَقَرَةُ", 3: "آلِ عِمْرَانَ", 4: "النِّسَاءِ", 5: "المَائِدَةُ",
      6: "الأَنْعَامُ", 7: "الأَعْرَافُ", 8: "الأَنْفَالُ", 9: "التَّوْبَةُ", 10: "يُونُسُ",
      11: "هُودٌ", 12: "يُوسُفُ", 13: "الرَّعْدُ", 14: "إِبْرَاهِيمُ", 15: "الحِجْرُ",
      16: "النَّحْلُ", 17: "الإِسْرَاءُ", 18: "الكَهْفُ", 19: "مَرْيَمُ", 20: "طه",
      21: "الأَنْبِيَاءُ", 22: "الحَجُّ", 23: "المُؤْمِنُونَ", 24: "النُّورُ", 25: "الفُرْقَانُ",
      26: "الشُّعَرَاءُ", 27: "النَّمْلُ", 28: "القَصَصُ", 29: "العَنْكَبُوتُ", 30: "الرُّومُ",
      31: "لُقْمَانُ", 32: "السَّجْدَةُ", 33: "الأَحْزَابُ", 34: "سَبَإٍ", 35: "فَاطِرُ",
      36: "يس", 37: "الصَّافَّاتُ", 38: "ص", 39: "الزُّمَرُ", 40: "غَافِرُ",
      41: "فُصِّلَتْ", 42: "الشُّورَى", 43: "الزُّخْرُفُ", 44: "الدُّخَانُ", 45: "الجَاثِيَةُ",
      46: "الأَحْقَافُ", 47: "مُحَمَّدٌ", 48: "الفَتْحُ", 49: "الحُجُرَاتُ", 50: "ق",
      51: "الذَّارِيَاتُ", 52: "الطُّورُ", 53: "النَّجْمُ", 54: "القَمَرُ", 55: "الرَّحْمَنُ",
      56: "الوَاقِعَةُ", 57: "الحَدِيدُ", 58: "المُجَادَلَةُ", 59: "الحَشْرُ", 60: "المُمْتَحَنَةُ",
      61: "الصَّفُّ", 62: "الجُمُعَةُ", 63: "المُنَافِقُونَ", 64: "التَّغَابُنُ", 65: "الطَّلَاقُ",
      66: "التَّحْرِيمُ", 67: "المُلْকُ", 68: "القَلَمُ", 69: "الحَاقَّةُ", 70: "المَعَارِجُ",
      71: "نُوحٌ", 72: "الجِنُّ", 73: "المُزَّمِّلُ", 74: "المُدَّثِّرُ", 75: "القِيَامَةُ",
      76: "الإِنْسَانُ", 77: "المُرْسَلَاتُ", 78: "النَّبَأُ", 79: "النَّازِعَاتُ", 80: "عَبَسَ",
      81: "التَّكْوِيرُ", 82: "الإِنْفِطَارُ", 83: "المُطَفِّفِينَ", 84: "الإِنْشِقَاقُ", 85: "البُرُوجُ",
      86: "الطَّارِقُ", 87: "الأَعْلَى", 88: "الغَاشِيَةُ", 89: "الفَجْرُ", 90: "البَلَدُ",
      91: "الشَّمْسُ", 92: "اللَّيْلُ", 93: "الضُّحَى", 94: "الشَّرْحُ", 95: "التِّينُ",
      96: "العَلَقُ", 97: "القَدْرُ", 98: "البَيِّنَةُ", 99: "الزَّلْزَلَةُ", 100: "العَادِيَاتُ",
      101: "القَارِعَةُ", 102: "التَّكَاثُرُ", 103: "العَصْرُ", 104: "الهُمَزَةُ", 105: "الفِيلُ",
      106: "قُرَيْشٌ", 107: "المَاعُونُ", 108: "الكَوْثَرُ", 109: "الكافِرُونَ", 110: "النَّصْرُ",
      111: "اللَّهَبُ", 112: "الإِخْلَاصُ", 113: "الفَلَقُ", 114: "النَّاسُ",
    };
    return names[number] ?? "";
  }

  // সূরার নাম (ইংরেজি)
  String _getEnglishName(int number) {
    Map<int, String> names = {
      1: "Al-Fatihah", 2: "Al-Baqarah", 3: "Aal-Imran", 4: "An-Nisa", 5: "Al-Ma'idah",
      6: "Al-An'am", 7: "Al-A'raf", 8: "Al-Anfal", 9: "At-Tawbah", 10: "Yunus",
      11: "Hud", 12: "Yusuf", 13: "Ar-Ra'd", 14: "Ibrahim", 15: "Al-Hijr",
      16: "An-Nahl", 17: "Al-Isra", 18: "Al-Kahf", 19: "Maryam", 20: "Taha",
      21: "Al-Anbiya", 22: "Al-Hajj", 23: "Al-Mu'minun", 24: "An-Nur", 25: "Al-Furqan",
      26: "Ash-Shu'ara", 27: "An-Naml", 28: "Al-Qasas", 29: "Al-Ankabut", 30: "Ar-Rum",
      31: "Luqman", 32: "As-Sajdah", 33: "Al-Ahzab", 34: "Saba", 35: "Fatir",
      36: "Ya-Sin", 37: "As-Saffat", 38: "Sad", 39: "Az-Zumar", 40: "Ghafir",
      41: "Fussilat", 42: "Ash-Shura", 43: "Az-Zukhruf", 44: "Ad-Dukhan", 45: "Al-Jathiyah",
      46: "Al-Ahqaf", 47: "Muhammad", 48: "Al-Fath", 49: "Al-Hujurat", 50: "Qaf",
      51: "Adh-Dhariyat", 52: "At-Tur", 53: "An-Najm", 54: "Al-Qamar", 55: "Ar-Rahman",
      56: "Al-Waqi'ah", 57: "Al-Hadid", 58: "Al-Mujadilah", 59: "Al-Hashr", 60: "Al-Mumtahanah",
      61: "As-Saff", 62: "Al-Jumu'ah", 63: "Al-Munafiqun", 64: "At-Taghabun", 65: "At-Talaq",
      66: "At-Tahrim", 67: "Al-Mulk", 68: "Al-Qalam", 69: "Al-Haqqah", 70: "Al-Ma'arij",
      71: "Nuh", 72: "Al-Jinn", 73: "Al-Muzzammil", 74: "Al-Muddaththir", 75: "Al-Qiyamah",
      76: "Al-Insan", 77: "Al-Mursalat", 78: "An-Naba", 79: "An-Nazi'at", 80: "Abasa",
      81: "At-Takwir", 82: "Al-Infitar", 83: "Al-Mutaffifin", 84: "Al-Inshiqaq", 85: "Al-Buruj",
      86: "At-Tariq", 87: "Al-A'la", 88: "Al-Ghashiyah", 89: "Al-Fajr", 90: "Al-Balad",
      91: "Ash-Shams", 92: "Al-Layl", 93: "Ad-Duha", 94: "Ash-Sharh", 95: "At-Tin",
      96: "Al-Alaq", 97: "Al-Qadr", 98: "Al-Bayyinah", 99: "Az-Zalzalah", 100: "Al-Adiyat",
      101: "Al-Qari'ah", 102: "At-Takathur", 103: "Al-Asr", 104: "Al-Humazah", 105: "Al-Fil",
      106: "Quraysh", 107: "Al-Ma'un", 108: "Al-Kawthar", 109: "Al-Kafirun", 110: "An-Nasr",
      111: "Al-Lahab", // ✅ Al-Masad এর বদলে জনপ্রিয় নাম 'Al-Lahab' দেওয়া হয়েছে
      112: "Al-Ikhlas", 113: "Al-Falaq", 114: "An-Nas",
    };
    return names[number] ?? "";
  }

  String _getRevelationType(int number) {
    Map<int, String> types = {
      1: "Meccan", 2: "Medinan", 3: "Medinan", 4: "Medinan", 5: "Medinan",
      6: "Meccan", 7: "Meccan", 8: "Medinan", 9: "Medinan", 10: "Meccan",
      11: "Meccan", 12: "Meccan", 13: "Medinan", 14: "Meccan", 15: "Meccan",
      16: "Meccan", 17: "Meccan", 18: "Meccan", 19: "Meccan", 20: "Meccan",
      21: "Meccan", 22: "Medinan", 23: "Meccan", 24: "Medinan", 25: "Meccan",
      26: "Meccan", 27: "Meccan", 28: "Meccan", 29: "Meccan", 30: "Meccan",
      31: "Meccan", 32: "Meccan", 33: "Medinan", 34: "Meccan", 35: "Meccan",
      36: "Meccan", 37: "Meccan", 38: "Meccan", 39: "Meccan", 40: "Meccan",
      41: "Meccan", 42: "Meccan", 43: "Meccan", 44: "Meccan", 45: "Meccan",
      46: "Meccan", 47: "Medinan", 48: "Medinan", 49: "Medinan", 50: "Meccan",
      51: "Meccan", 52: "Meccan", 53: "Meccan", 54: "Meccan", 55: "Medinan",
      56: "Meccan", 57: "Medinan", 58: "Medinan", 59: "Medinan", 60: "Medinan",
      61: "Medinan", 62: "Medinan", 63: "Medinan", 64: "Medinan", 65: "Medinan",
      66: "Medinan", 67: "Meccan", 68: "Meccan", 69: "Meccan", 70: "Meccan",
      71: "Meccan", 72: "Meccan", 73: "Meccan", 74: "Meccan", 75: "Meccan",
      76: "Medinan", 77: "Meccan", 78: "Meccan", 79: "Meccan", 80: "Meccan",
      81: "Meccan", 82: "Meccan", 83: "Meccan", 84: "Meccan", 85: "Meccan",
      86: "Meccan", 87: "Meccan", 88: "Meccan", 89: "Meccan", 90: "Meccan",
      91: "Meccan", 92: "Meccan", 93: "Meccan", 94: "Meccan", 95: "Meccan",
      96: "Meccan", 97: "Meccan", 98: "Medinan", 99: "Medinan", 100: "Meccan",
      101: "Meccan", 102: "Meccan", 103: "Meccan", 104: "Meccan", 105: "Meccan",
      106: "Meccan", 107: "Meccan", 108: "Meccan", 109: "Meccan", 110: "Medinan",
      111: "Meccan", 112: "Meccan", 113: "Meccan", 114: "Meccan",
    };
    return types[number] ?? "Meccan";
  }
}