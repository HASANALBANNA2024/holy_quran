import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class TasbihProvider with ChangeNotifier {
  int _count = 0;
  int _target = 33;
  String _selectedDhikr = "SubhanAllah";

  int get count => _count;
  int get target => _target;
  String get selectedDhikr => _selectedDhikr;

  TasbihProvider() {
    _loadData();
  }

  void increment() {
    _count++;
    if (_target > 0 && _count == _target) {
      HapticFeedback.vibrate(); // টার্গেট পূরণ হলে বিশেষ ভাইব্রেশন
    } else {
      HapticFeedback.lightImpact(); // প্রতি ক্লিকে হালকা ভাইব্রেশন
    }
    _saveData();
    notifyListeners();
  }

  void reset() {
    _count = 0;
    _saveData();
    notifyListeners();
  }

  // জিকির এবং টার্গেট একসাথে সেট করার ফাংশন
  void setDhikr(String name, int targetVal) {
    _selectedDhikr = name;
    _target = targetVal;
    _count = 0; // নতুন জিকির শুরু করলে কাউন্ট রিসেট হবে
    _saveData();
    notifyListeners();
  }

  void setOnlyTarget(int val) {
    _target = val;
    notifyListeners();
  }

  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('tasbih_count', _count);
    prefs.setString('selected_dhikr', _selectedDhikr);
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _count = prefs.getInt('tasbih_count') ?? 0;
    _selectedDhikr = prefs.getString('selected_dhikr') ?? "SubhanAllah";
    notifyListeners();
  }
}