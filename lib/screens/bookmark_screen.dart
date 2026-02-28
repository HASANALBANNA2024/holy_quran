import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:holy_quran/providers/bookmark_provider.dart';
class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final bookmarks = bookmarkProvider.bookmarks;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Bookmarks", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
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

  // যদি কোনো বুকমার্ক না থাকে
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border_rounded, size: 80, color: Colors.grey.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text("No bookmarks yet", style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }

  // ইমেজ অনুযায়ী কার্ড ডিজাইন
  Widget _buildBookmarkCard(BuildContext context, Map<String, dynamic> ayah, BookmarkProvider provider) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B3D2A) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // সূরার নাম ও নম্বর
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Surah ${ayah['surahName'] ?? 'Unknown'} : ${ayah['numberInSurah']}",
                    style: TextStyle(
                      color: isDark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text("Translation included", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              // বুকমার্ক রিমুভ বাটন
              IconButton(
                icon: const Icon(Icons.bookmark_rounded, color: Color(0xFF2E7D32)),
                onPressed: () => provider.toggleBookmark(ayah),
              ),
            ],
          ),
          const Divider(height: 20, color: Colors.white10),
          // আরবি টেক্সট
          Text(
            ayah['text'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'QuranFont',
              fontSize: 26,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 12),
          // অনুবাদ টেক্সট
          Text(
            ayah['translation'] ?? '',
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