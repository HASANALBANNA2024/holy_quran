import 'package:share_plus/share_plus.dart';

class ShareLogic {
  static void shareAyah({
    required dynamic arabicText,
    required dynamic englishTranslation,
    required dynamic surahName,
    required dynamic ayahNumber,
  }) {
    final String message =
        "🕋 *Holy Quran*\n\n"
        "📖 ${arabicText.toString()}\n\n"
        "🇬🇧 *English:* ${englishTranslation.toString()}\n\n"
        "📌 Surah: ${surahName.toString()} | Ayah: ${ayahNumber.toString()}\n\n"
        "✨ Share and gain Sadaqah Jariyah.";

    Share.share(message);
  }
}
