import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:holy_quran/providers/bookmark_provider.dart';
import 'dart:convert'; // JSON decoding এর জন্য এটি লাগবে
// import 'package:http/http.dart' as http; // TODO: pubspec.yaml এ http এড করে এটি আনকমেন্ট করবেন

class SurahDetailScreen extends StatefulWidget {
  final Map<String, dynamic> surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {

  // ---------------------------------------------------------
  // 🔹 API Section: আয়াতের লিস্ট ফেচ করার ফাংশন
  // ---------------------------------------------------------
  Future<List<dynamic>> fetchAyahs() async {
    try {
      /* // ভবিষ্যতে অরিজিনাল API কল করার জন্য নিচের কোডটি আনকমেন্ট করুন:

      final String apiUrl = "https://api.alquran.cloud/v1/surah/${widget.surah['number']}/editions/quran-uthmani,en.sahih";
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // ডাটা স্ট্রাকচার অনুযায়ী রিটার্ন করবেন (সাধারণত data['data']['ayahs'] থাকে)
        return data['data'][0]['ayahs'];
      } else {
        throw Exception('Failed to load ayahs');
      }
      */

      // আপাতত ডামি ডাটা দিয়ে ১১৪টি সূরার জন্য লজিক সেট করা আছে
      await Future.delayed(const Duration(seconds: 1));
      return List.generate(
        widget.surah['numberOfAyahs'],
            (index) => {
          "number": index + 1,
          "text": "بِسْم.ِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", // API থেকে আসা আরবি টেক্সট এখানে বসবে
          "translation": "Translation of ayah number ${index + 1} will appear here.", // অনুবাদ এখানে বসবে
        },
      );
    } catch (e) {
      throw Exception("Error fetching Ayahs: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
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
                icon: Icon(Icons.arrow_back_ios,
                    color: innerBoxIsScrolled ? Colors.white : Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
              title: innerBoxIsScrolled
                  ? Text(widget.surah['englishName'],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
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
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              "﷽",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28, // সাইজ আপনার পছন্দমতো বাড়াতে বা কমাতে পারেন
                                color: const Color(0xFF1B5E20),
                                fontFamily: 'QuranFont', // আপনার সেট করা আরবি ফন্ট
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
        body: FutureBuilder<List<dynamic>>(
          future: fetchAyahs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No Ayahs Found"));
            }

            final ayahs = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: ayahs.length,
              itemBuilder: (context, index) {
                return _buildAyahItem(ayahs[index]);
              },
            );
          },
        ),
      ),
    );
  }

  // --- 🔹 UI Widgets (No Change in Design) ---

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
          Text(widget.surah['englishName'],
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(
            widget.surah['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'QuranFont', // এখানেও ফন্টটি যোগ করুন
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

  // Ayah Item code and details feature
  Widget _buildAyahItem(Map<String, dynamic> ayah) {
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
                child: Text("${ayah['number']}", style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const Spacer(),
              const Icon(Icons.share_outlined, color: Color(0xFF1B5E20), size: 20),
              const SizedBox(width: 15),
              const Icon(Icons.play_arrow_outlined, color: Color(0xFF1B5E20), size: 24),
              const SizedBox(width: 15),
              // bookmark
              // const Icon(Icons.bookmark_border_outlined, color: Color(0xFF1B5E20), size: 20),

              // IconButton দিয়ে রিপ্লেস করুন
              Consumer<BookmarkProvider>(
                builder: (context, bookmarkProvider, child) {
                  bool bookmarked = bookmarkProvider.isBookmarked(ayah['number']);

                  return IconButton(
                    icon: Icon(
                      bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: const Color(0xFF1B5E20),
                      size: 24,
                    ),
                    onPressed: () {
                      bookmarkProvider.toggleBookmark(ayah);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(bookmarked ? "Removed from Bookmarks" : "Saved to Bookmarks"),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
              ),

            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          ayah['text'],
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 28,             // আরবি সাইজ বাড়িয়ে ২৮-৩২ এর মধ্যে রাখুন
            fontWeight: FontWeight.normal,
            fontFamily: 'QuranFont',  // আপনার ফন্ট নাম
            height: 2.0,              // লাইনের মাঝে গ্যাপ যাতে হরকত স্পষ্ট থাকে
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            ayah['translation'],
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
        const Divider(height: 40),
      ],
    );
  }



  // Audio Player
  Widget _buildAudioPlayerBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.skip_previous, color: Color(0xFF1B5E20)),
          const CircleAvatar(
            backgroundColor: Color(0xFF1B5E20),
            child: Icon(Icons.play_arrow, color: Colors.white),
          ),
          const Icon(Icons.skip_next, color: Color(0xFF1B5E20)),
          const Icon(Icons.volume_up, color: Colors.grey),
        ],
      ),
    );
  }
}