//feature update alarm

// import 'package:flutter/material.dart';
//
// class IslamicAlarmScreen extends StatelessWidget {
//   final String alarmTitle;    // যেমন: Fajr, Dhuhr বা Custom Alarm
//   final String surahName;     // ইউজারের সিলেক্ট করা সূরার নাম
//   final String translation;   // স্ক্রিনে দেখানোর জন্য আয়াত
//   final bool isAzan;          // এটি কি আজান বাজছে নাকি সূরা?
//   final VoidCallback onStop;
//   final VoidCallback onReadQuran;
//
//   const IslamicAlarmScreen({
//     super.key,
//     required this.alarmTitle,
//     required this.surahName,
//     required this.translation,
//     required this.onStop,
//     required this.onReadQuran,
//     this.isAzan = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF001F11), // Deep Islamic Green
//       body: Stack(
//         children: [
//           // ১. ব্যাকগ্রাউন্ড প্যাটার্ন
//           Center(
//             child: Opacity(
//               opacity: 0.1,
//               child: Image.asset(
//                 'assets/images/672.jpg',
//                 width: size.width * 0.9,
//                 color: Colors.white,
//                 colorBlendMode: BlendMode.srcIn,
//                 errorBuilder: (context, error, stackTrace) => const SizedBox(), // ইমেজ না থাকলে এরর দেবে না
//               ),
//             ),
//           ),
//
//           SafeArea(
//             child: SizedBox(
//               width: double.infinity,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // ২. ডায়নামিক টাইটেল (নামাজের নাম বা অ্যালার্ম টাইটেল)
//                   Text(
//                     alarmTitle.toUpperCase(),
//                     style: const TextStyle(
//                       color: Color(0xFFC5A059),
//                       letterSpacing: 2,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Icon(Icons.wb_twilight, color: Color(0xFFC5A059), size: 50),
//                   const SizedBox(height: 20),
//                   const Text(
//                       "Assalamu Alaikum",
//                       style: TextStyle(color: Colors.white70, fontSize: 18)
//                   ),
//                   const SizedBox(height: 10),
//
//                   // ৩. স্ট্যাটাস (আজান নাকি তিলাওয়াত)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Text(
//                       isAzan ? "Playing: Adhan" : "Tilawat: $surahName",
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         color: Color(0xFFC5A059),
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: 'Translation',
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 40),
//
//                   // ৪. ইন্সপিরেশনাল আয়াত
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 30),
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.05),
//                         borderRadius: BorderRadius.circular(15),
//                         border: Border.all(color: const Color(0xFFC5A059).withOpacity(0.3)),
//                       ),
//                       child: Column(
//                         children: [
//                           const Text(
//                               "Today's Inspiration:",
//                               style: TextStyle(color: Color(0xFFC5A059), fontWeight: FontWeight.bold)
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             translation,
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontStyle: FontStyle.italic
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 60),
//
//                   // ৫. অ্যাকশন বাটনসমূহ
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildActionButton(
//                           Icons.alarm_off,
//                           "Stop",
//                           Colors.redAccent,
//                           onStop
//                       ),
//                       // যদি শুধু আজান বাজে, তবে কুরআন পড়ার বাটনের বদলে অন্য কিছু দিতে পারেন,
//                       // তবে আপনার রিকোয়েস্ট অনুযায়ী এটি অপরিবর্তিত রাখা হলো।
//                       _buildActionButton(
//                           Icons.menu_book,
//                           "Read Quran",
//                           Colors.green,
//                           onReadQuran
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(15),
//             decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: color,
//                 boxShadow: [
//                   BoxShadow(
//                     color: color.withOpacity(0.4),
//                     blurRadius: 10,
//                     spreadRadius: 2,
//                   )
//                 ]
//             ),
//             child: Icon(icon, color: Colors.white, size: 30),
//           ),
//           const SizedBox(height: 10),
//           Text(
//               label,
//               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)
//           ),
//         ],
//       ),
//     );
//   }
// }