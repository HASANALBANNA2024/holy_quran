import 'dart:async';

import 'package:flutter/material.dart';
import 'package:holy_quran/logics/share_logic.dart';
import 'package:holy_quran/providers/bookmark_provider.dart';
import 'package:holy_quran/providers/quran_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class SurahDetailScreen extends StatefulWidget {
  final String surahName;
  final int surahIndex;
  final int? initialAyahIndex;

  const SurahDetailScreen({
    super.key,
    required this.surahIndex,
    required this.surahName,
    this.initialAyahIndex,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();
  int _currentlyPlayingAyah = -1;
  bool _isAudioLoading = false;

  List<Map<String, dynamic>> _cachedAyahs = [];
  bool _isDataLoaded = false;

  Timer? _debounceTimer;
  int _lastSavedIndex = -1;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToInitialAyah();
    });
  }

  // surah_detail_screen.dart

  void _scrollToInitialAyah() {
    // নিশ্চিত করা হচ্ছে যে ইনডেক্স আছে এবং ডাটা লোড হয়েছে
    if (widget.initialAyahIndex != null &&
        widget.initialAyahIndex! >= 0 &&
        _cachedAyahs.isNotEmpty) {
      int targetIndex = widget.initialAyahIndex!;

      debugPrint(
        "📍 Scrolling to INDEX: $targetIndex (Ayah: ${targetIndex + 1})",
      );

      // ✅ কিছুটা বেশি সময় দেওয়া হয়েছে যাতে ListView পুরোপুরি বিল্ড হতে পারে
      Future.delayed(const Duration(milliseconds: 700), () {
        if (_scrollController.hasClients) {
          // আপনার প্রতিটি আয়াত আইটেমের আনুমানিক উচ্চতা (Height) অনুযায়ী offset বের করা
          // আপনার কার্ড + প্যাডিং মিলিয়ে এটি ১০০ এর আশেপাশে হওয়া নিরাপদ
          double targetOffset = targetIndex * 350.0;

          // তবে সর্বোচ্চ স্ক্রল লিমিট ক্রস না করার জন্য চেক
          if (targetOffset > _scrollController.position.maxScrollExtent) {
            targetOffset = _scrollController.position.maxScrollExtent;
          }

          _scrollController.animateTo(
            targetOffset,
            duration: const Duration(
              milliseconds: 1000,
            ), // একটু ধীরে স্ক্রল হবে যাতে ইউজার বুঝতে পারে
            curve: Curves.fastOutSlowIn,
          );
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      _loadAyahs();
    }
  }

  void _loadAyahs() {
    final quran = Provider.of<QuranProvider>(context, listen: false);
    _cachedAyahs = getAyahs(quran);
    setState(() {
      _isDataLoaded = true;
    });

    if (widget.initialAyahIndex != null && _cachedAyahs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToInitialAyah();
      });
    }
  }

  List<Map<String, dynamic>> getAyahs(QuranProvider quran) {
    if (quran.surahs.isEmpty || quran.translations.isEmpty) {
      return [];
    }

    if (widget.surahIndex >= quran.surahs.length ||
        widget.surahIndex >= quran.translations.length) {
      return [];
    }

    try {
      final arabicSurah = quran.surahs[widget.surahIndex];
      final translationSurah = quran.translations[widget.surahIndex];

      final arabicAyahs = arabicSurah['ayahs'] as List;
      final translationAyahs = translationSurah['ayahs'] as List;

      return List.generate(arabicAyahs.length, (index) {
        return {
          'id': index + 1, // ✅ সঠিক আয়াত নম্বর
          'arabic': arabicAyahs[index]['text'] ?? "",
          'trans': index < translationAyahs.length
              ? translationAyahs[index]['text'] ?? ""
              : "",
          'globalAyahId': _getGlobalAyahId(
            arabicSurah['number'] ?? (widget.surahIndex + 1),
            arabicAyahs[index]['number'] ?? (index + 1),
          ),
        };
      });
    } catch (e) {
      debugPrint("Error parsing ayahs: $e");
      return [];
    }
  }

  int _getGlobalAyahId(int surahNumber, int ayahNumber) {
    if (surahNumber == 1) return ayahNumber;

    Map<int, int> ayahCounts = {
      1: 7,
      2: 286,
      3: 200,
      4: 176,
      5: 120,
      6: 165,
      7: 206,
      8: 75,
      9: 129,
      10: 109,
      11: 123,
      12: 111,
      13: 43,
      14: 52,
      15: 99,
      16: 128,
      17: 111,
      18: 110,
      19: 98,
      20: 135,
      21: 112,
      22: 78,
      23: 118,
      24: 64,
      25: 77,
      26: 227,
      27: 93,
      28: 88,
      29: 69,
      30: 60,
      31: 34,
      32: 30,
      33: 73,
      34: 54,
      35: 45,
      36: 83,
      37: 182,
      38: 88,
      39: 75,
      40: 85,
      41: 54,
      42: 53,
      43: 89,
      44: 59,
      45: 37,
      46: 35,
      47: 38,
      48: 29,
      49: 18,
      50: 45,
      51: 60,
      52: 49,
      53: 62,
      54: 55,
      55: 78,
      56: 96,
      57: 29,
      58: 22,
      59: 24,
      60: 13,
      61: 14,
      62: 11,
      63: 11,
      64: 18,
      65: 12,
      66: 12,
      67: 30,
      68: 52,
      69: 52,
      70: 44,
      71: 28,
      72: 28,
      73: 20,
      74: 56,
      75: 40,
      76: 31,
      77: 50,
      78: 40,
      79: 46,
      80: 42,
      81: 29,
      82: 19,
      83: 36,
      84: 25,
      85: 22,
      86: 17,
      87: 19,
      88: 26,
      89: 30,
      90: 20,
      91: 15,
      92: 21,
      93: 11,
      94: 8,
      95: 8,
      96: 19,
      97: 5,
      98: 8,
      99: 8,
      100: 11,
      101: 11,
      102: 8,
      103: 3,
      104: 9,
      105: 5,
      106: 4,
      107: 7,
      108: 3,
      109: 6,
      110: 3,
      111: 5,
      112: 4,
      113: 5,
      114: 6,
    };

    int total = 0;
    for (int i = 1; i < surahNumber; i++) {
      total += ayahCounts[i] ?? 0;
    }
    return total + ayahNumber;
  }

  Future<void> _playAyahAudio(int globalId) async {
    if (_isAudioLoading) return;

    setState(() {
      _isAudioLoading = true;
    });

    try {
      if (_currentlyPlayingAyah != -1 && _audioPlayer.playing) {
        await _audioPlayer.stop();
      }

      String audioUrl =
          "https://cdn.islamic.network/quran/audio/128/ar.alafasy/$globalId.mp3";

      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();

      setState(() {
        _currentlyPlayingAyah = globalId;
        _isAudioLoading = false;
      });
    } catch (e) {
      setState(() {
        _isAudioLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Internet needed for audio streaming"),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  bool _shouldShowBismillah(int surahNumber) {
    if (surahNumber == 9) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuranProvider>(
      builder: (context, quran, _) {
        // ... (Loading এবং Error হ্যান্ডলিং আগের মতোই থাকবে)

        final currentSurahData = quran.surahs[widget.surahIndex];
        final ayahs = _cachedAyahs.isEmpty ? getAyahs(quran) : _cachedAyahs;

        return Scaffold(
          bottomNavigationBar: _buildAudioPlayerBar(),
          body: NotificationListener<ScrollNotification>(
            // SurahDetailScreen এর NotificationListener এর ভেতরে:
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                if (_scrollController.hasClients && _cachedAyahs.isNotEmpty) {
                  // ✅ এটি আরও সেফ লজিক:
                  // আপনার SliverAppBar এর উচ্চতা (২৮০) বাদ দিয়ে তারপর ভাগ করা
                  double appBarHeight = 280.0;
                  double currentOffset = _scrollController.offset;

                  if (currentOffset > appBarHeight) {
                    // স্ক্রিন থেকে AppBar এর অংশটুকু বাদ দিয়ে আয়াতের ইনডেক্স বের করা
                    int index = ((currentOffset - appBarHeight) / 250).floor();

                    if (index >= 0 && index < _cachedAyahs.length) {
                      // _debouncedSaveLastRead(index);
                    }
                  }
                }
              }
              return false;
            },
            child: NestedScrollView(
              controller: _scrollController,
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
                            widget.surahName,
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
                              _buildSurahHeaderCard(currentSurahData),
                              if (_shouldShowBismillah(
                                currentSurahData['number'] ?? 0,
                              ))
                                const Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Text(
                                    "﷽",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 28,
                                      color: Color(0xFF1B5E20),
                                      fontFamily: 'Amiri',
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
              body: ayahs.isEmpty
                  ? const Center(child: Text("No verses found"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: ayahs.length,
                      itemBuilder: (context, index) {
                        return _buildAyahItem(ayahs[index], index);
                      },
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahHeaderCard(Map<String, dynamic> surah) {
    int surahNumber = surah['number'] ?? 0;

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
            surah['englishName'] ?? 'Unknown',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            surah['name'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'Amiri',
            ),
          ),
          const Divider(color: Colors.white54, thickness: 1),
          Text(
            "${(surah['revelationType'] ?? 'MECCAN').toString().toUpperCase()} • ${surah['ayahs']?.length ?? 0} VERSES",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          if (surahNumber == 9)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                "(No Bismillah at the beginning)",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAyahItem(Map<String, dynamic> ayah, int index) {
    final int globalAyahId = ayah['globalAyahId'] ?? 0;
    final bool isPlaying = _currentlyPlayingAyah == globalAyahId;

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
                  "${ayah['id']}",
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
                onPressed: () async {
                  String arabic = ayah['arabic'] ?? '';
                  String trans = ayah['trans'] ?? '';

                  await ShareLogic.shareAyah(
                    arabicText: arabic,
                    englishTranslation: trans,
                    surahName: widget.surahName,
                    ayahNumber: ayah['id'] ?? 0, // ✅ ayah['id'] ব্যবহার করুন
                    context: context,
                  );
                },
              ),

              const SizedBox(width: 15),

              // Audio Button
              Stack(
                alignment: Alignment.center,
                children: [
                  if (_isAudioLoading && isPlaying)
                    const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF1B5E20),
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow_outlined,
                        color: const Color(0xFF1B5E20),
                        size: 24,
                      ),
                      onPressed: isPlaying
                          ? _togglePlayPause
                          : () => _playAyahAudio(globalAyahId),
                    ),
                ],
              ),

              const SizedBox(width: 15),

              // Bookmark Button
              Consumer<BookmarkProvider>(
                builder: (context, bookmarkProvider, child) {
                  Map<String, dynamic> bookmarkData = {
                    'id': globalAyahId,
                    'number': globalAyahId,
                    'surahName': widget.surahName,
                    'numberInSurah':
                        ayah['id'] ?? 0, // ✅ ayah['id'] ব্যবহার করুন
                    'ayahNumber': ayah['id'] ?? 0, // ✅ ayah['id'] ব্যবহার করুন
                    'text': ayah['arabic'] ?? '',
                    'arabic': ayah['arabic'] ?? '',
                    'translation': ayah['trans'] ?? '',
                    'trans': ayah['trans'] ?? '',
                  };

                  bool bookmarked = bookmarkProvider.isBookmarked(bookmarkData);

                  return IconButton(
                    icon: Icon(
                      bookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: const Color(0xFF1B5E20),
                      size: 24,
                    ),
                    onPressed: () {
                      bookmarkProvider.toggleBookmark(bookmarkData);
                    },
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // Arabic Text
        Text(
          ayah['arabic'] ?? '',
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 28,
            fontFamily: 'Amiri',
            height: 2.0,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 10),

        // Translation Text
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            ayah['trans'] ?? '',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),

        const Divider(height: 40),
      ],
    );
  }

  Widget _buildAudioPlayerBar() {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data?.playing ?? false;

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
                onTap: _togglePlayPause,
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF1B5E20),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.skip_next, color: Color(0xFF1B5E20)),
              const Icon(Icons.volume_up, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }
}
