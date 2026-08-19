import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF2E7D32),
    scaffoldBackgroundColor: const Color(0xFF1B262C),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F4C75),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'QuranFont',
        fontSize: 20,
        color: Colors.white,
      ),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF3282B8).withValues(alpha: 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    fontFamily: 'QuranFont',
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Color(0xFFBBE1FA)),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1B5E20),
    scaffoldBackgroundColor: Colors.white,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF1B5E20)),
      titleTextStyle: TextStyle(
        fontFamily: 'QuranFont',
        fontSize: 20,
        color: Color(0xFF1B5E20),
      ),
    ),

    cardTheme: CardThemeData(
      color: Colors.grey[100],
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    fontFamily: 'QuranFont',
  );

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
