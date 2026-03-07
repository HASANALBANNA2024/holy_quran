import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ভাইব্রেশনের জন্য
import 'package:just_audio/just_audio.dart'; // সাউন্ডের জন্য

class TasbihProvider with ChangeNotifier {
  int _count = 0;
  int _target = 33;
  String _selectedDhikr = "سبحان الله";

  // সাউন্ড প্লেয়ার মেমোরিতে রাখা
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ১৫টি জনপ্রিয় জিকির (আরবি শর্ট ও ফুল টেক্সট)
  final List<Map<String, dynamic>> builtInDhikr = [
    {'short': 'سبحان الله', 'full': 'سبحان الله', 'target': 33},
    {'short': 'الحمد لله', 'full': 'الحمد لله', 'target': 33},
    {'short': 'الله أكبر', 'full': 'الله أكبر', 'target': 34},
    {'short': 'أستغفر الله', 'full': 'أستغفر الله وأتوب إليه', 'target': 100},
    {'short': 'صلوات', 'full': 'اللهم صل على محمد وعلى آل محمد كما صليت على إبراهيم وعلى آل إبراهيم إنك حميد مجيد', 'target': 100},
    {'short': 'لا إله إلا الله', 'full': 'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير', 'target': 100},
    {'short': 'لاحول ولاقوة', 'full': 'لا حول ولا قوة إلا بالله العلي العظيم', 'target': 100},
    {'short': 'سبحان الله وبحمده', 'full': 'سبحان الله وبحمده سبحان الله العظيم', 'target': 100},
    {'short': 'حسبنا الله', 'full': 'حسبنا الله ونعم الوكيل', 'target': 100},
    {'short': 'يا حي يا قيوم', 'full': 'يا حي يا قيوم برحمتك أستغيث أصلহ لي شأني كله ولا تكلني إلى نفسي طرفة عين', 'target': 100},
  ];

  int get count => _count;
  int get target => _target;
  String get selectedDhikr => _selectedDhikr;

  // কাউন্ট বাড়ানো এবং সাউন্ড-ভাইব্রেশন ট্রিগার করা
  void increment() async {
    if (_target > 0 && _count >= _target) return;

    _count++;

    if (_target > 0 && _count == _target) {
      // ✅ টার্গেট পূরণ হলে: লম্বা ভাইব্রেশন ও স্পেশাল WAV সাউন্ড
      HapticFeedback.vibrate();
      _playSound('assets/sounds/complete.wav');
    } else {
      // ✅ প্রতি ক্লিকে: হালকা ভাইব্রেশন ও ওজিজি (OGG) সাউন্ড
      HapticFeedback.lightImpact();
      _playSound('assets/sounds/click.ogg');
    }

    notifyListeners();
  }

  // সাউন্ড প্লে করার ইন্টারনাল ফাংশন
  void _playSound(String assetPath) async {
    try {
      await _audioPlayer.setAsset(assetPath);
      _audioPlayer.play();
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  // কাস্টম দোয়া ও টার্গেট সেট করা
  void setDhikr(String fullDhikr, int targetVal) {
    _selectedDhikr = fullDhikr;
    _target = targetVal;
    _count = 0;
    notifyListeners();
  }

  // রিসেট লজিক
  void reset() {
    _count = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // মেমোরি ক্লিয়ার করা
    super.dispose();
  }
}