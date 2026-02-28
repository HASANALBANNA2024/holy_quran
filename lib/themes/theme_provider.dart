import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // 🔹 আপনার পছন্দের সফট ডার্ক থিম (Slate Blue/Charcoal)
  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF2E7D32), // গাঢ় সবুজ

    // এটি একদম কালো নয়, চোখের জন্য আরামদায়ক ডার্ক শেড
    scaffoldBackgroundColor: const Color(0xFF1B262C),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F4C75),
      elevation: 0,
      titleTextStyle: TextStyle(fontFamily: 'QuranFont', fontSize: 20, color: Colors.white),
    ),

    // কার্ড বা লিস্ট টাইলের জন্য হালকা আলাদা শেড
    cardColor: const Color(0xFF3282B8).withOpacity(0.1),

    fontFamily: 'QuranFont',
    textTheme: const TextTheme(
      // ডার্ক মোডে টেক্সটগুলো হালকা অফ-হোয়াইট বা হালকা আকাশী দিলে ভালো দেখায়
      bodyLarge: TextStyle(color: Color(0xFFBBE1FA)),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );

  // 🔹 লাইট মোড থিম
  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1B5E20),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(fontFamily: 'QuranFont', fontSize: 20, color: Color(0xFF1B5E20)),
    ),
    fontFamily: 'QuranFont',
  );

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}