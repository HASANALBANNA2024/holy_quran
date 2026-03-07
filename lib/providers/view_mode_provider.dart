import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewModeProvider with ChangeNotifier {
  // ০ = Both (আরবী ও অনুবাদ), ১ = Arabic Only (শুধু আরবী), ২ = Translation Only (শুধু অনুবাদ)
  int _mode = 0;
  int get mode => _mode;

  ViewModeProvider() {
    _loadViewMode();
  }

  // ইউজার অপশন চেঞ্জ করলে এটি কল হবে
  void setViewMode(int newMode) async {
    _mode = newMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran_view_mode', newMode);
  }

  // অ্যাপ ওপেন হলে আগের সেভ করা ডাটা লোড হবে
  void _loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    _mode = prefs.getInt('quran_view_mode') ?? 0;
    notifyListeners();
  }
}