import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String category;
  final String text;
  final String surahName;
  final int surahIndex;
  final int ayahNumber;
  final DateTime time;
  bool isRead;

  NotificationModel({
    required this.id, required this.category, required this.text,
    required this.surahName, required this.surahIndex,
    required this.ayahNumber, required this.time, this.isRead = false,
  });
}

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _list = [];
  List<NotificationModel> get list => _list;

  int get unreadCount => _list.where((n) => !n.isRead).length;

  void addNotification(NotificationModel notification) {
    _list.insert(0, notification);
    notifyListeners();
  }

  void markAsRead() {
    for (var n in _list) { n.isRead = true; }
    notifyListeners();
  }

  void clearAll() {
    _list.clear();
    notifyListeners();
  }

  void removeOne(String id) {
    _list.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}