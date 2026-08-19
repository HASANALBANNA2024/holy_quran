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
    required this.id,
    required this.category,
    required this.text,
    required this.surahName,
    required this.surahIndex,
    required this.ayahNumber,
    required this.time,
    this.isRead = false,
  });

  // JSON serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'text': text,
    'surahName': surahName,
    'surahIndex': surahIndex,
    'ayahNumber': ayahNumber,
    'time': time.toIso8601String(),
    'isRead': isRead,
  };

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'],
        category: json['category'],
        text: json['text'],
        surahName: json['surahName'],
        surahIndex: json['surahIndex'],
        ayahNumber: json['ayahNumber'],
        time: DateTime.parse(json['time']),
        isRead: json['isRead'],
      );
}

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _list = [];

  List<NotificationModel> get list => List.unmodifiable(_list);
  int get unreadCount => _list.where((n) => !n.isRead).length;

  void addNotification(NotificationModel notification) {
    _list.insert(0, notification);
    notifyListeners();
  }

  void markAsRead() {
    for (var n in _list) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void markAsReadById(String id) {
    final index = _list.indexWhere((n) => n.id == id);
    if (index != -1) {
      _list[index].isRead = true;
      notifyListeners();
    }
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
