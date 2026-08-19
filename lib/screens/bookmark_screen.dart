import 'package:flutter/material.dart';
import 'package:holy_quran/providers/bookmark_provider.dart';
import 'package:provider/provider.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final bookmarks = bookmarkProvider.bookmarks;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Bookmarks",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        actions: [
          if (bookmarks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _showClearAllDialog(context, bookmarkProvider);
              },
            ),
        ],
      ),
      body: bookmarks.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final ayah = bookmarks[index];
                return _buildBookmarkCard(context, ayah, bookmarkProvider);
              },
            ),
    );
  }

  void _showClearAllDialog(BuildContext context, BookmarkProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Bookmarks'),
        content: const Text('Are you sure you want to remove all bookmarks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAllBookmarks();
              Navigator.pop(ctx);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 80,
            color: Colors.grey.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            "No bookmarks yet",
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap the bookmark icon on any ayah to save it",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  ///card design (null-safe)
  Widget _buildBookmarkCard(
    BuildContext context,
    Map<String, dynamic> ayah,
    BookmarkProvider provider,
  ) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    /// null-check default value set
    String surahName = ayah['surahName'] ?? 'Unknown';
    int? numberInSurah =
        ayah['numberInSurah'] ?? ayah['ayahNumber'] ?? ayah['id'];
    String ayahNumberText = numberInSurah != null
        ? numberInSurah.toString()
        : '';

    String arabicText = ayah['text'] ?? ayah['arabic'] ?? '';
    String translationText = ayah['translation'] ?? ayah['trans'] ?? '';

    /// debugdebugPrint("Building bookmark card: ${ayah.toString()}");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B3D2A) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// surah name and number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Surah $surahName${ayahNumberText.isNotEmpty ? ' : $ayahNumberText' : ''}",
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFA5D6A7)
                            : const Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              /// bookmark remove  ব
              IconButton(
                icon: const Icon(
                  Icons.bookmark_rounded,
                  color: Color(0xFF2E7D32),
                ),
                onPressed: () => provider.toggleBookmark(ayah),
              ),
            ],
          ),
          const Divider(height: 20, color: Colors.white10),

          if (arabicText.isNotEmpty)
            Text(
              arabicText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'QuranFont',
                fontSize: 26,
                height: 1.8,
              ),
            )
          else
            const SizedBox(height: 20),

          const SizedBox(height: 12),

          /// translation text only
          if (translationText.isNotEmpty)
            Text(
              translationText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
