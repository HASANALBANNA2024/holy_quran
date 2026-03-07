//future update feature this section

// import 'package:flutter/material.dart';
// import 'package:holy_quran/logics/qibla_logic.dart';
// import 'dart:math' as math;
// import 'dart:async';
// import 'package:flutter/services.dart';
//
// class QiblaScreen extends StatefulWidget {
//   const QiblaScreen({super.key});
//
//   @override
//   State<QiblaScreen> createState() => _QiblaScreenState();
// }
//
// class _QiblaScreenState extends State<QiblaScreen> with SingleTickerProviderStateMixin {
//   double _qiblaDirection = 0.0;
//   double _deviceHeading = 0.0;
//   double _angleDifference = 0.0;
//   bool _isLoading = true;
//   String? _errorMessage;
//   String _directionName = "";
//
//   Timer? _compassTimer;
//   late AnimationController _animationController;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _loadQiblaData();
//   }
//
//   Future<void> _loadQiblaData() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//
//     final result = await QiblaLogic.getQiblaDirection();
//
//     if (result['success'] == true && mounted) {
//       setState(() {
//         _qiblaDirection = result['qibla'];
//         _directionName = result['directionName'];
//         _isLoading = false;
//       });
//
//       // কম্পাস সিমুলেশন শুরু
//       _startCompassSimulation();
//
//       debugPrint("🕋 Qibla: ${result['qibla']}°");
//       debugPrint("📍 Location: ${result['latitude']}, ${result['longitude']}");
//     } else {
//       setState(() {
//         _errorMessage = result['error'];
//         _isLoading = false;
//       });
//     }
//   }
//
//   void _startCompassSimulation() {
//     // বাস্তব অ্যাপে sensors_plus প্যাকেজ ব্যবহার করবেন
//     double angle = 0;
//     _compassTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
//       if (mounted) {
//         angle = (angle + 1) % 360;
//         double difference = QiblaLogic.getAngleDifference(_qiblaDirection, angle);
//
//         setState(() {
//           _deviceHeading = angle;
//           _angleDifference = difference;
//         });
//
//         // অ্যানিমেশন
//         _animationController.forward(from: 0);
//       }
//     });
//   }
//
//   String _getDirectionInstruction() {
//     if (_angleDifference < 5) {
//       return "✅ সঠিক দিকে আছেন!";
//     } else if (_qiblaDirection > _deviceHeading) {
//       double diff = (_qiblaDirection - _deviceHeading + 360) % 360;
//       if (diff <= 180) {
//         return "👉 ডান দিকে ঘুরুন (${diff.toStringAsFixed(0)}°)";
//       } else {
//         return "👈 বাম দিকে ঘুরুন (${(360 - diff).toStringAsFixed(0)}°)";
//       }
//     } else {
//       double diff = (_deviceHeading - _qiblaDirection + 360) % 360;
//       if (diff <= 180) {
//         return "👈 বাম দিকে ঘুরুন (${diff.toStringAsFixed(0)}°)";
//       } else {
//         return "👉 ডান দিকে ঘুরুন (${(360 - diff).toStringAsFixed(0)}°)";
//       }
//     }
//   }
//
//   String _getDeviceDirectionName() {
//     double heading = _deviceHeading;
//     if (heading >= 337.5 || heading < 22.5) return "উত্তর";
//     if (heading >= 22.5 && heading < 67.5) return "উত্তর-পূর্ব";
//     if (heading >= 67.5 && heading < 112.5) return "পূর্ব";
//     if (heading >= 112.5 && heading < 157.5) return "দক্ষিণ-পূর্ব";
//     if (heading >= 157.5 && heading < 202.5) return "দক্ষিণ";
//     if (heading >= 202.5 && heading < 247.5) return "দক্ষিণ-পশ্চিম";
//     if (heading >= 247.5 && heading < 292.5) return "পশ্চিম";
//     if (heading >= 292.5 && heading < 337.5) return "উত্তর-পশ্চিম";
//     return "";
//   }
//
//   @override
//   void dispose() {
//     _compassTimer?.cancel();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1B241A),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text(
//           "কিবলা দিক নির্ণয়",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: _isLoading
//           ? _buildLoadingState()
//           : _errorMessage != null
//           ? _buildErrorState()
//           : _buildQiblaCompass(),
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               color: const Color(0xFF2E7D32).withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: const Center(
//               child: CircularProgressIndicator(
//                 color: Color(0xFF2E7D32),
//                 strokeWidth: 3,
//               ),
//             ),
//           ),
//           const SizedBox(height: 30),
//           const Text(
//             "আপনার অবস্থান চিহ্নিত করা হচ্ছে...",
//             style: TextStyle(
//               color: Colors.white70,
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildErrorState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.location_off,
//                 size: 60,
//                 color: Colors.red,
//               ),
//             ),
//             const SizedBox(height: 30),
//             Text(
//               _errorMessage ?? "Unknown error occurred",
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white70,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: _loadQiblaData,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF2E7D32),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               child: const Text(
//                 "পুনরায় চেষ্টা করুন",
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQiblaCompass() {
//     double compassRotation = _deviceHeading * math.pi / 180;
//     double qiblaRotation = (_qiblaDirection - _deviceHeading) * math.pi / 180;
//     bool isAligned = _angleDifference < 5;
//
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // নির্দেশনা কার্ড (সবার উপরে)
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: isAligned
//                     ? const Color(0xFF2E7D32).withOpacity(0.2)
//                     : const Color(0xFF243023),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: isAligned
//                       ? const Color(0xFF81C784)
//                       : Colors.transparent,
//                   width: 2,
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Icon(
//                     isAligned ? Icons.check_circle : Icons.navigation,
//                     color: isAligned
//                         ? const Color(0xFF81C784)
//                         : Colors.orange,
//                     size: 40,
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     _getDirectionInstruction(),
//                     style: TextStyle(
//                       color: isAligned
//                           ? const Color(0xFF81C784)
//                           : Colors.orange,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   if (!isAligned) ...[
//                     const SizedBox(height: 10),
//                     Text(
//                       "পার্থক্য: ${_angleDifference.toStringAsFixed(1)}°",
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // কম্পাস কার্ড
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF243023),
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: Column(
//                 children: [
//                   // হেডার তথ্য
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "কিবলা দিক",
//                             style: TextStyle(color: Colors.white70, fontSize: 14),
//                           ),
//                           Text(
//                             "${_qiblaDirection.toStringAsFixed(1)}° $_directionName",
//                             style: const TextStyle(
//                               color: Color(0xFF81C784),
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           "${_deviceHeading.toStringAsFixed(0)}°",
//                           style: const TextStyle(
//                             color: Colors.blue,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 30),
//
//                   // কম্পাস
//                   SizedBox(
//                     height: 280,
//                     width: 280,
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         // কম্পাস বেস
//                         CustomPaint(
//                           size: const Size(280, 280),
//                           painter: CompassBasePainter(),
//                         ),
//
//                         // উত্তর নির্দেশক (লাল)
//                         Transform.rotate(
//                           angle: compassRotation,
//                           child: CustomPaint(
//                             size: const Size(280, 280),
//                             painter: NorthPointerPainter(),
//                           ),
//                         ),
//
//                         // কিবলা নির্দেশক (সবুজ)
//                         Transform.rotate(
//                           angle: qiblaRotation,
//                           child: CustomPaint(
//                             size: const Size(280, 280),
//                             painter: QiblaPointerPainter(),
//                           ),
//                         ),
//
//                         // সেন্টার ডট
//                         Container(
//                           width: 16,
//                           height: 16,
//                           decoration: const BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//
//                   // লিজেন্ড
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _buildLegend(Colors.red, "উত্তর"),
//                       const SizedBox(width: 30),
//                       _buildLegend(const Color(0xFF81C784), "কিবলা"),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // টিপস কার্ড
//             Container(
//               padding: const EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF1B3D2A),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.tips_and_updates,
//                     color: Color(0xFF81C784),
//                     size: 24,
//                   ),
//                   const SizedBox(width: 15),
//                   const Expanded(
//                     child: Text(
//                       "লাল মার্কার উত্তর দিক নির্দেশ করে। সবুজ মার্কার কিবলা দিক নির্দেশ করে। দুই মার্কার একই লাইনে এলে আপনি সঠিক দিকে থাকবেন।",
//                       style: TextStyle(
//                         color: Colors.white70,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLegend(Color color, String label) {
//     return Row(
//       children: [
//         Container(
//           width: 20,
//           height: 20,
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           label,
//           style: const TextStyle(color: Colors.white70),
//         ),
//       ],
//     );
//   }
// }
//
// // কম্পাস বেস পেইন্টার
// class CompassBasePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;
//
//     // আউটার সার্কেল
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.2)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2;
//
//     canvas.drawCircle(center, radius - 2, paint);
//
//     // ডিগ্রী মার্কিং (প্রতি ৩০°)
//     for (int i = 0; i < 360; i += 30) {
//       double angle = i * math.pi / 180;
//       double startX = center.dx + (radius - 15) * math.sin(angle);
//       double startY = center.dy - (radius - 15) * math.cos(angle);
//       double endX = center.dx + (radius - 5) * math.sin(angle);
//       double endY = center.dy - (radius - 5) * math.cos(angle);
//
//       canvas.drawLine(
//         Offset(startX, startY),
//         Offset(endX, endY),
//         Paint()..color = Colors.white.withOpacity(0.3)..strokeWidth = 1,
//       );
//     }
//
//     // মূল দিকনির্দেশ (N, E, S, W)
//     const directions = ['N', 'E', 'S', 'W'];
//     for (int i = 0; i < 4; i++) {
//       double angle = i * 90 * math.pi / 180;
//       double x = center.dx + (radius - 25) * math.sin(angle);
//       double y = center.dy - (radius - 25) * math.cos(angle);
//
//       TextSpan span = TextSpan(
//         style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
//         text: directions[i],
//       );
//       TextPainter tp = TextPainter(
//         text: span,
//         textAlign: TextAlign.center,
//         textDirection: TextDirection.ltr,
//       );
//       tp.layout();
//       tp.paint(canvas, Offset(x - 5, y - 8));
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
//
// // উত্তর নির্দেশক পেইন্টার
// class NorthPointerPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.red
//       ..style = PaintingStyle.fill;
//
//     var path = Path();
//     path.moveTo(size.width / 2, 10);
//     path.lineTo(size.width / 2 - 12, 35);
//     path.lineTo(size.width / 2, 25);
//     path.lineTo(size.width / 2 + 12, 35);
//     path.close();
//
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
//
// // কিবলা নির্দেশক পেইন্টার
// class QiblaPointerPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFF81C784)
//       ..style = PaintingStyle.fill;
//
//     var path = Path();
//     path.moveTo(size.width / 2, 10);
//     path.lineTo(size.width / 2 - 10, 30);
//     path.lineTo(size.width / 2, 20);
//     path.lineTo(size.width / 2 + 10, 30);
//     path.close();
//
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }