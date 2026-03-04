// import 'package:flutter/material.dart';
// import 'package:in_app_review/in_app_review.dart';
//
// class RateApp extends StatelessWidget {
//   final bool isDrawer;
//
//   const RateApp({Key? key, this.isDrawer = true}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     if (isDrawer) {
//       return ListTile(
//         leading: Icon(Icons.star, color: Colors.amber),
//         title: Text('Rate App'),
//         subtitle: Text('Give us 5 stars'),
//         onTap: () => _rateApp(context),
//       );
//     }
//     return Container();
//   }
//
//   Future<void> _rateApp(BuildContext context) async {
//     final InAppReview inAppReview = InAppReview.instance;
//
//     try {
//       if (await inAppReview.isAvailable()) {
//         // ইন-অ্যাপ রেটিং পপ-আপ দেখাবে
//         await inAppReview.requestReview();
//       } else {
//         // না হলে স্টোর খুলবে
//         await inAppReview.openStoreListing(
//           appStoreId: '123456789', // আপনার iOS অ্যাপ আইডি
//         );
//       }
//     } catch (e) {
//       debugPrint('Error: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Could not open rating')));
//     }
//   }
// }
