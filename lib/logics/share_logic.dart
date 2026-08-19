import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareLogic {
  static Future<void> shareAyah({
    required String arabicText,
    required String englishTranslation,
    required String surahName,
    required int ayahNumber,
    BuildContext? context,
  }) async {
    try {
      String shareText = "";

      shareText += "$arabicText\n\n";

      if (englishTranslation.trim().isNotEmpty) {
        shareText += "$englishTranslation\n\n";
      }
      shareText += "$surahName - Ayah $ayahNumber\n";
      shareText += "Holy Quran";

      // debugPrint("Sharing: $shareText");

      final ShareResult result = await Share.share(shareText);
      // debugdebugPrint("Share result: ${result.status}");
      if (result.status == ShareResultStatus.unavailable && context != null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Share is not available"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // debugPrint("Share error: $e");
      if (context != null) {
        if (!context.mounted) return;
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
