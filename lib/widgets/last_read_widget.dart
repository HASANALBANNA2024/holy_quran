// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:holy_quran/controller/last_read_controller.dart';
// import 'package:holy_quran/models/last_read_model.dart';
//
// class LastReadWidget extends StatefulWidget {
//   const LastReadWidget({super.key});
//
//   @override
//   State<LastReadWidget> createState() => _LastReadWidgetState();
// }
//
// class _LastReadWidgetState extends State<LastReadWidget> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   Timer? _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _startAutoScroll();
//   }
//
//   void _startAutoScroll() {
//     _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
//       if (_currentPage < 2) {
//         _currentPage++;
//       } else {
//         _currentPage = 0;
//       }
//       if (_pageController.hasClients) {
//         _pageController.animateToPage(
//           _currentPage,
//           duration: const Duration(milliseconds: 800),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<LastReadModel>(
//       future: LastReadController.fetchLastRead(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const SizedBox(height: 120);
//         final data = snapshot.data!;
//
//         return Container(
//           height: 130,
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           decoration: BoxDecoration(
//             color: const Color(0xFF607D8B),
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//             child: PageView(
//               controller: _pageController,
//               children: [
//                 // ১. আরবিক আয়াত স্লাইড
//                 _buildSlide(data.arabicText, "Arabic Ayah", Icons.auto_awesome),
//                 // ২. অনুবাদ স্লাইড
//                 _buildSlide(data.translation, "Translation", Icons.translate),
//                 // ৩. সূরা ও আয়াত ইনফো স্লাইড
//                 _buildSlide("Surah ${data.surahName}\nAyah No: ${data.ayahNumber}", "Location", Icons.location_on),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildSlide(String text, String label, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: Colors.white54, size: 16),
//               const SizedBox(width: 8),
//               Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Expanded(
//             child: Center(
//               child: Text(
//                 text,
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }