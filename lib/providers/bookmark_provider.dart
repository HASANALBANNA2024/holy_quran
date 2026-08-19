import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _bookmarks = [];
  List<Map<String, dynamic>> get bookmarks => _bookmarks;

  BookmarkProvider() {
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? encodedData = prefs.getString('saved_bookmarks');
      if (encodedData != null) {
        _bookmarks = List<Map<String, dynamic>>.from(json.decode(encodedData));
        // debugdebugPrint("Loaded ${_bookmarks.length} bookmarks");
      }
      notifyListeners();
    } catch (e) {
      // debugdebugPrint("Error loading bookmarks: $e");
      _bookmarks = [];
    }
  }

  Future<void> toggleBookmark(Map<String, dynamic> ayah) async {
    // debugdebugPrint(
    //   "Toggling bookmark: ${ayah['surahName']} - Ayah ${ayah['numberInSurah']}",
    // );

    /// unique id search
    String surahName = ayah['surahName'] ?? '';
    int? numberInSurah =
        ayah['numberInSurah'] ?? ayah['ayahNumber'] ?? ayah['id'];

    final index = _bookmarks.indexWhere(
      (item) =>
          item['surahName'] == surahName &&
          (item['numberInSurah'] == numberInSurah ||
              item['id'] == numberInSurah),
    );

    if (index >= 0) {
      _bookmarks.removeAt(index);
      // debugdebugPrint("Bookmark removed");
    } else {
      // নিশ্চিত করা যে সব ফিল্ড আছে
      Map<String, dynamic> bookmarkData = {
        'surahName': surahName,
        'numberInSurah': numberInSurah,
        'ayahNumber': numberInSurah,
        'id': ayah['id'] ?? numberInSurah,
        'number': ayah['number'] ?? numberInSurah,
        'text': ayah['text'] ?? ayah['arabic'] ?? '',
        'arabic': ayah['arabic'] ?? ayah['text'] ?? '',
        'translation': ayah['translation'] ?? ayah['trans'] ?? '',
        'trans': ayah['trans'] ?? ayah['translation'] ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _bookmarks.add(bookmarkData);
      // debugdebugPrint("Bookmark added");
    }

    notifyListeners();
    await _saveBookmarks();
  }

  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('saved_bookmarks', json.encode(_bookmarks));
    } catch (e) {
      // debugdebugPrint("Error saving bookmarks: $e");
    }
  }

  bool isBookmarked(Map<String, dynamic> ayah) {
    String surahName = ayah['surahName'] ?? '';
    int? numberInSurah =
        ayah['numberInSurah'] ?? ayah['ayahNumber'] ?? ayah['id'];

    return _bookmarks.any(
      (item) =>
          item['surahName'] == surahName &&
          (item['numberInSurah'] == numberInSurah ||
              item['id'] == numberInSurah),
    );
  }

  bool isBookmarkedByNumber(int ayahNumber) {
    return _bookmarks.any(
      (item) => item['id'] == ayahNumber || item['number'] == ayahNumber,
    );
  }

  Future<void> clearAllBookmarks() async {
    _bookmarks.clear();
    notifyListeners();
    await _saveBookmarks();
    // debugdebugPrint("All bookmarks cleared");
  }
}
