import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareLogic {
  /// একটি আয়াত শেয়ার করার জন্য সিম্পল ফাংশন
  static Future<void> shareAyah({
    required String arabicText,
    required String englishTranslation,
    required String surahName,
    required int ayahNumber,
    BuildContext? context, // ঐচ্ছিক context
  }) async {
    try {
      // শেয়ার করার টেক্সট তৈরি
      String shareText = "";

      // আরবী টেক্সট যোগ করুন
      shareText += arabicText + "\n\n";

      // ইংরেজি ট্রান্সলেশন যোগ করুন (যদি খালি না হয়)
      if (englishTranslation.trim().isNotEmpty) {
        shareText += englishTranslation + "\n\n";
      }

      // সূরা ও আয়াতের তথ্য যোগ করুন
      shareText += "$surahName - Ayah $ayahNumber\n";
      shareText += "Holy Quran";

      print("Sharing: $shareText");

      // শেয়ার করুন এবং ফলাফল চেক করুন
      final ShareResult result = await Share.share(shareText);

      // ডিবাগ করার জন্য
      print("Share result: ${result.status}");

      // ইউজারকে মেসেজ দেখান (শুধু error হলে)
      if (result.status == ShareResultStatus.unavailable && context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Share is not available"),
            backgroundColor: Colors.orange,
          ),
        );
      }

      // dismissed হলে কিছু দেখাবেন না (এটা নরমাল)
    } catch (e) {
      print("Share error: $e");

      // শুধু রিয়েল error হলে দেখান
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not share: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
