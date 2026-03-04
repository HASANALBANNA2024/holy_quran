// import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';
//
// class ShareAppItem extends StatelessWidget {
//   final bool isDrawer;
//
//   const ShareAppItem({Key? key, this.isDrawer = true}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       type: MaterialType.transparency,
//       child: ListTile(
//         leading: Icon(Icons.share_rounded, color: Color(0xFF2E7D32)),
//         title: Text(
//           'Share App',
//           style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//         ),
//         subtitle: Text('Invite friends to download'),
//         onTap: () {
//           // ✅ প্রথমে ড্রয়ার বন্ধ করুন
//           Navigator.pop(context);
//
//           // ✅ তারপর সরাসরি Share করুন (কোন Screen ছাড়া)
//           _shareAppDirectly();
//         },
//       ),
//     );
//   }
//
//   void _shareAppDirectly() {
//     final String appName = 'Islamic App';
//     final String packageName = 'com.example.islamic_app';
//     final String playStoreUrl = 'https://play.google.com/store/apps/details?id=$packageName';
//
//     final String shareText = '''
// 📱 *$appName*
//
// Assalamu Alaikum! I am using this Islamic app.
// You can also download and benefit from it:
//
// 🔹 Quran Recitation
// 🔹 Bengali Translation
// 🔹 Qibla Direction
// 🔹 Prayer Times
//
// 📲 Android: $playStoreUrl
//
// Jazakallah Khairan 🤲
// ''';
//
//     // ✅ শুধু এই লাইন - সরাসরি Share Options খুলবে
//     Share.share(shareText, subject: 'Download $appName');
//
//     // ❌ কোন Navigator.push, কোন Dialog, কোন Screen নেই
//     // ✅ Black Screen আসার কোন কারণ নেই
//   }
// }