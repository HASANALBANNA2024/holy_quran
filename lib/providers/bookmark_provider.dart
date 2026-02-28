import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookmarkProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _bookmarks = [];
  List<Map<String, dynamic>> get bookmarks => _bookmarks;

  BookmarkProvider() {
    loadBookmarks(); // অ্যাপ শুরুতেই সেভ করা ডেটা লোড করবে
  }

  // বুকমার্ক লোড করা
  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    String? encodedData = prefs.getString('saved_bookmarks');
    if (encodedData != null) {
      _bookmarks = List<Map<String, dynamic>>.from(json.decode(encodedData));
      notifyListeners();
    }
  }

  // বুকমার্ক যোগ বা রিমুভ করা (Toggle)
  Future<void> toggleBookmark(Map<String, dynamic> ayah) async {
    final index = _bookmarks.indexWhere((item) => item['number'] == ayah['number']);

    if (index >= 0) {
      _bookmarks.removeAt(index); // থাকলে ডিলিট করবে
    } else {
      _bookmarks.add(ayah); // না থাকলে সেভ করবে
    }

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('saved_bookmarks', json.encode(_bookmarks));
  }

  // কোনো আয়াত বুকমার্ক করা আছে কি না চেক করা
  bool isBookmarked(int ayahNumber) {
    return _bookmarks.any((item) => item['number'] == ayahNumber);
  }
}