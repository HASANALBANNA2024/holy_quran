import 'package:flutter/material.dart';
import 'package:holy_quran/logics/share_logic.dart';
import 'package:holy_quran/providers/bookmark_provider.dart';
import 'package:just_audio/just_audio.dart'; // অডিওর জন্য এটি লাগবে
import 'package:provider/provider.dart';

import '../services/database_helper.dart'; // আপনার ডাটাবেস হেল্পার

class SurahDetailScreen extends StatefulWidget {
  final String surahName;
  final Map<String, dynamic> surah;

  const SurahDetailScreen({
    super.key,
    required this.surah,
    required this.surahName,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final AudioPlayer _audioPlayer =
      AudioPlayer(); // অডিও প্লেয়ার ডিফাইন করা হলো

  // ---------------------------------------------------------
  // 🔹 API Section: এখন এটি SQLite থেকে অফলাইন ডাটা আনবে
  // ---------------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchAyahsFromOffline() async {
    try {
      // আপনার তৈরি করা ডাটাবেস হেল্পার থেকে ডাটা রিড করা হচ্ছে
      return await DatabaseHelper.getSurahFromLocal(widget.surah['number']);
    } catch (e) {
      throw Exception("Error loading offline Ayahs: $e");
    }
  }

  // অডিও প্লে করার ফাংশন (অনলাইন স্ট্রিমিং)
  void _playAyahAudio(int globalId) async {
    try {
      String audioUrl =
          "https://cdn.islamic.network/quran/audio/128/ar.alafasy/$globalId.mp3";
      await _audioPlayer.setUrl(audioUrl);
      _audioPlayer.play();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Internet needed for audio streaming")),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // স্ক্রিন থেকে বের হলে অডিও বন্ধ হবে
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildAudioPlayerBar(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFF1B5E20),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: innerBoxIsScrolled ? Colors.white : Colors.grey,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: innerBoxIsScrolled
                  ? Text(
                      widget.surah['englishName'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 80),
                        _buildSurahHeaderCard(),
                        if (widget.surah['number'] != 9)
                          const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Text(
                              "﷽",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                color: Color(0xFF1B5E20),
                                fontFamily: 'QuranFont',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchAyahsFromOffline(), // এখানে অফলাইন ফাংশন কল করা হলো
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No Offline Data Found! Check Sync."),
              );
            }

            final ayahs = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: ayahs.length,
              itemBuilder: (context, index) {
                return _buildAyahItem(ayahs[index], index);
              },
            );
          },
        ),
      ),
    );
  }

  // --- 🔹 UI Widgets (ডিজাইন একদম আগের মতোই আছে) ---

  Widget _buildSurahHeaderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.surah['englishName'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.surah['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'QuranFont',
            ),
          ),
          const Divider(color: Colors.white54, thickness: 1),
          Text(
            "${widget.surah['revelationType'].toUpperCase()} • ${widget.surah['numberOfAyahs']} VERSES",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahItem(Map<String, dynamic> ayah, int index) {
    // এখানে index যোগ করা হয়েছে
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF1B5E20),
                child: Text(
                  // এখন আর রেড লাইন আসবে না, index সরাসরি ব্যবহার করা যাবে
                  "${ayah['id'] != null ? (ayah['id'] % 1000) : index + 1}",
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              const Spacer(),

              // Share Button
              IconButton(
                icon: const Icon(
                  Icons.share_outlined,
                  size: 20,
                  color: Color(0xFF1B5E20),
                ),
                onPressed: () {
                  ShareLogic.shareAyah(
                    arabicText: ayah['arabic'] ?? "No Arabic",
                    englishTranslation: ayah['trans'] ?? "No Translation",
                    surahName: widget.surahName,
                    ayahNumber: ayah['globalAyahId'] ?? 0,
                  );
                },
              ),

              const SizedBox(width: 15),

              // Play Audio Button
              IconButton(
                icon: const Icon(
                  Icons.play_arrow_outlined,
                  color: Color(0xFF1B5E20),
                  size: 24,
                ),
                onPressed: () => _playAyahAudio(ayah['globalAyahId']),
              ),

              const SizedBox(width: 15),

              // Bookmark Button
              Consumer<BookmarkProvider>(
                builder: (context, bookmarkProvider, child) {
                  bool bookmarked = bookmarkProvider.isBookmarked(
                    ayah['globalAyahId'],
                  );
                  return IconButton(
                    icon: Icon(
                      bookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: const Color(0xFF1B5E20),
                      size: 24,
                    ),
                    onPressed: () {
                      bookmarkProvider.toggleBookmark(ayah);
                    },
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          ayah['arabic'],
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.normal,
            fontFamily: 'QuranFont',
            height: 2.0,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            ayah['trans'],
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
        const Divider(height: 40),
      ],
    );
  }

  Widget _buildAudioPlayerBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.skip_previous, color: Color(0xFF1B5E20)),
          GestureDetector(
            onTap: () {
              if (_audioPlayer.playing) {
                _audioPlayer.pause();
              } else {
                _audioPlayer.play();
              }
              setState(() {});
            },
            child: CircleAvatar(
              backgroundColor: const Color(0xFF1B5E20),
              child: Icon(
                _audioPlayer.playing ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ),
          const Icon(Icons.skip_next, color: Color(0xFF1B5E20)),
          const Icon(Icons.volume_up, color: Colors.grey),
        ],
      ),
    );
  }
}
