// future update alarm feature

// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'dart:async';
//
// class AlarmProvider with ChangeNotifier {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//
//   // State Variables
//   String? _selectedSurahName;
//   String? _selectedSurahUrl;
//   String _currentPrayerName = "Alarm";
//   bool _isUsingAzan = true;
//   bool _isAlarmPlaying = false;
//   Timer? _alarmTimer;
//
//   // Getters
//   String? get selectedSurahName => _selectedSurahName;
//   bool get isUsingAzan => _isUsingAzan;
//   bool get isAlarmPlaying => _isAlarmPlaying;
//   String get currentPrayerName => _currentPrayerName;
//
//   // ✅ ১. অ্যালার্ম কনফিগার করার মেথড (ইউজার যেটা সেট করবে)
//   void setAlarmConfig({String? sName, String? sUrl, bool useAzan = true}) {
//     _selectedSurahName = sName;
//     _selectedSurahUrl = sUrl;
//     _isUsingAzan = useAzan;
//     notifyListeners();
//   }
//
//   // ✅ ২. নামাজের সময়ের জন্য স্মার্ট টাইমার (Background Check)
//   void schedulePrayerAlarm(TimeOfDay time, String prayerName) {
//     _currentPrayerName = prayerName;
//     _alarmTimer?.cancel(); // আগের টাইমার থাকলে বন্ধ করবে
//
//     _alarmTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
//       final now = TimeOfDay.now();
//       if (now.hour == time.hour && now.minute == time.minute) {
//         triggerAlarm(); // সময় মিলে গেলে অ্যালার্ম বাজবে
//         timer.cancel(); // একবার বেজে গেলে টাইমার বন্ধ
//       }
//     });
//   }
//
//   // ✅ ৩. অ্যালার্ম বাজার মেইন লজিক
//   Future<void> triggerAlarm() async {
//     var connectivity = await (Connectivity().checkConnectivity());
//     bool hasInternet = !connectivity.contains(ConnectivityResult.none);
//
//     try {
//       if (_isUsingAzan || !hasInternet || _selectedSurahUrl == null) {
//         // আজান বাজবে (অফলাইন ব্যাকআপ)
//         await _audioPlayer.setAsset('assets/audio/azan.mp3');
//       } else {
//         // ইউজারের পছন্দের সূরা বাজবে (অনলাইন)
//         await _audioPlayer.setUrl(_selectedSurahUrl!);
//       }
//
//       _audioPlayer.setLoopMode(LoopMode.one);
//       await _audioPlayer.play();
//       _isAlarmPlaying = true;
//       notifyListeners();
//     } catch (e) {
//       debugPrint("Alarm Play Error: $e");
//     }
//   }
//
//   // ✅ ৪. অ্যালার্ম বন্ধ করা
//   void stopAlarm() {
//     _audioPlayer.stop();
//     _isAlarmPlaying = false;
//     notifyListeners();
//   }
//
//   @override
//   void dispose() {
//     _alarmTimer?.cancel();
//     _audioPlayer.dispose();
//     super.dispose();
//   }
// }