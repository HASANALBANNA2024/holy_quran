import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewModeProvider with ChangeNotifier {
  /// ০ = Both (arabic and arabic translation), ১ = Arabic Only (arabic), ২ = Translation Only (only arabic)
  int _mode = 0;
  int get mode => _mode;

  ViewModeProvider() {
    _loadViewMode();
  }

  /// when user option change for view
  void setViewMode(int newMode) async {
    _mode = newMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran_view_mode', newMode);
  }

  /// when app open previous data load
  void _loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    _mode = prefs.getInt('quran_view_mode') ?? 0;
    notifyListeners();
  }
}
