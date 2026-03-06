import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QariProvider with ChangeNotifier {
  String _selectedQariId = 'ar.alafasy';
  String _selectedQariName = 'Mishary Rashid Alafasy';

  String get selectedQariId => _selectedQariId;
  String get selectedQariName => _selectedQariName;

  QariProvider() {
    _loadSavedQari();
  }

  void updateQari(String id, String name) async {
    _selectedQariId = id;
    _selectedQariName = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('qari_id', id);
    await prefs.setString('qari_name', name);
  }

  void _loadSavedQari() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedQariId = prefs.getString('qari_id') ?? 'ar.alafasy';
    _selectedQariName = prefs.getString('qari_name') ?? 'Mishary Rashid Alafasy';
    notifyListeners();
  }
}