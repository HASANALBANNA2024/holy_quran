import 'dart:async';
import 'package:flutter/material.dart';
import 'package:holy_quran/logics/share_logic.dart';
import 'package:holy_quran/providers/bookmark_provider.dart';
import 'package:holy_quran/providers/quran_provider.dart';
import 'package:holy_quran/providers/view_mode_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:holy_quran/providers/qari_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();

  int _currentlyPlayingAyah = -1;
  bool _isAudioLoading = false;
  List<Map<String, dynamic>> _cachedAyahs = [];
  bool _isDataLoaded = false;

  // ✅ অ্যাপবার টাইটেল শো করানোর জন্য নতুন ভেরিয়েবল
  bool _showTitleInAppBar = false;

  @override
  void initState() {
    super.initState();

    // ✅ স্ক্রল লিসেনার: এটিই হেডার হাইড করবে এবং অ্যাপবারে নাম দেখাবে
    itemPositionsListener.itemPositions.addListener(() {
      final positions = itemPositionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        final firstItem = positions.first;

        // যদি প্রথম আয়াতটি স্ক্রিনের ওপরে চলে যায় (index > 0) অথবা সামান্য স্ক্রল হয়
        bool shouldShowTitle = firstItem.index > 0 || firstItem.itemLeadingEdge < 0;

        if (_showTitleInAppBar != shouldShowTitle) {
          setState(() {
            _showTitleInAppBar = shouldShowTitle;
          });
        }

        // হেডার কার্ড এবং বিসমিল্লাহকে ওপরে ঠেলে দেওয়ার জন্য ScrollController আপডেট
        if (_scrollController.hasClients) {
          if (shouldShowTitle) {
            _scrollController.jumpTo(280.0); // ExpandedHeight এর সমান
          } else {
            _scrollController.jumpTo(0.0);
          }
        }
      }
    });

    // আপনার অরিজিনাল অডিও লজিক
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && _cachedAyahs.isNotEmpty && mounted) {
        _autoScrollToIndex(index);
        int surahNumber = widget.surahIndex + 1;
        if (surahNumber == 1 || surahNumber == 9) {
          if (index >= 0 && index < _cachedAyahs.length) {
            setState(() => _currentlyPlayingAyah = _cachedAyahs[index]['globalAyahId']);
          }
        } else {
          if (index == 0) {
            setState(() => _currentlyPlayingAyah = -1);
          } else {
            int ayahIndex = index - 1;
            if (ayahIndex >= 0 && ayahIndex < _cachedAyahs.length) {
              setState(() => _currentlyPlayingAyah = _cachedAyahs[ayahIndex]['globalAyahId']);
            }
          }
        }
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playNextSurah();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialAyahIndex != null) {
        _scrollToAyah(widget.initialAyahIndex!);
        if (widget.initialAyahIndex == 0) {
          _playFullSurahAudio(0);
        }
      }
    });
  }

  void _scrollToAyah(int index) {
    itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _autoScrollToIndex(int index) {
    if (!itemScrollController.isAttached) return;
    int surahNumber = widget.surahIndex + 1;
    int targetIndex = (surahNumber != 1 && surahNumber != 9) ? (index == 0 ? 0 : index - 1) : index;
    itemScrollController.scrollTo(
      index: targetIndex,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  void _playNextSurah() {
    if (widget.surahIndex < 113) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SurahDetailScreen(
            surahIndex: widget.surahIndex + 1,
            surahName: "Next Surah",
            initialAyahIndex: 0,
          ),
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      final quran = Provider.of<QuranProvider>(context, listen: false);
      _cachedAyahs = getAyahs(quran);
      setState(() => _isDataLoaded = true);
    }
  }

  List<Map<String, dynamic>> getAyahs(QuranProvider quran) {
    if (quran.surahs.isEmpty || quran.translations.isEmpty) return [];
    try {
      final arabicSurah = quran.surahs[widget.surahIndex];
      final translationSurah = quran.translations[widget.surahIndex];
      final arabicAyahs = arabicSurah['ayahs'] as List;
      final translationAyahs = translationSurah['ayahs'] as List;

      return List.generate(arabicAyahs.length, (index) {
        return {
          'id': index + 1,
          'arabic': arabicAyahs[index]['text'] ?? "",
          'trans': index < translationAyahs.length ? translationAyahs[index]['text'] ?? "" : "",
          'globalAyahId': _getGlobalAyahId(arabicSurah['number'] ?? (widget.surahIndex + 1), arabicAyahs[index]['number'] ?? (index + 1)),
        };
      });
    } catch (e) { return []; }
  }

  int _getGlobalAyahId(int surahNumber, int ayahNumber) {
    Map<int, int> ayahCounts = {1: 7, 2: 286, 3: 200, 4: 176, 5: 120, 6: 165, 7: 206, 8: 75, 9: 129, 10: 109, 11: 123, 12: 111, 13: 43, 14: 52, 15: 99, 16: 128, 17: 111, 18: 110, 19: 98, 20: 135, 21: 112, 22: 78, 23: 118, 24: 64, 25: 77, 26: 227, 27: 93, 28: 88, 29: 69, 30: 60, 31: 34, 32: 30, 33: 73, 34: 54, 35: 45, 36: 83, 37: 182, 38: 88, 39: 75, 40: 85, 41: 54, 42: 53, 43: 89, 44: 59, 45: 37, 46: 35, 47: 38, 48: 29, 49: 18, 50: 45, 51: 60, 52: 49, 53: 62, 54: 55, 55: 78, 56: 96, 57: 29, 58: 22, 59: 24, 60: 13, 61: 14, 62: 11, 63: 11, 64: 18, 65: 12, 66: 12, 67: 30, 68: 52, 69: 52, 70: 44, 71: 28, 72: 28, 73: 20, 74: 56, 75: 40, 76: 31, 77: 50, 78: 40, 79: 46, 80: 42, 81: 29, 82: 19, 83: 36, 84: 25, 85: 22, 86: 17, 87: 19, 88: 26, 89: 30, 90: 20, 91: 15, 92: 21, 93: 11, 94: 8, 95: 8, 96: 19, 97: 5, 98: 8, 99: 8, 100: 11, 101: 11, 102: 8, 103: 3, 104: 9, 105: 5, 106: 4, 107: 7, 108: 3, 109: 6, 110: 3, 111: 5, 112: 4, 113: 5, 114: 6};
    int total = 0;
    for (int i = 1; i < surahNumber; i++) { total += ayahCounts[i] ?? 0; }
    return total + ayahNumber;
  }

  Future<void> _playFullSurahAudio(int startAyahIndex) async {
    if (_isAudioLoading) return;
    setState(() => _isAudioLoading = true);
    final qariProvider = Provider.of<QariProvider>(context, listen: false);
    String qariId = qariProvider.selectedQariId;

    try {
      final List<AudioSource> playlist = [];
      int surahNumber = widget.surahIndex + 1;
      if (surahNumber != 1 && surahNumber != 9) {
        playlist.add(AudioSource.uri(Uri.parse("https://cdn.islamic.network/quran/audio/128/$qariId/1.mp3")));
      }
      for (int i = 0; i < _cachedAyahs.length; i++) {
        int globalId = _cachedAyahs[i]['globalAyahId'];
        playlist.add(AudioSource.uri(Uri.parse("https://cdn.islamic.network/quran/audio/128/$qariId/$globalId.mp3")));
      }
      int playIndex = (surahNumber == 1 || surahNumber == 9) ? startAyahIndex : (startAyahIndex == 0 ? 0 : startAyahIndex + 1);
      await _audioPlayer.setAudioSource(ConcatenatingAudioSource(children: playlist), initialIndex: playIndex);
      _audioPlayer.play();
      setState(() => _isAudioLoading = false);
    } catch (e) {
      setState(() => _isAudioLoading = false);
    }
  }

  Future<void> _togglePlayPause() async {
    if (_audioPlayer.audioSource == null) _playFullSurahAudio(0);
    else _audioPlayer.playing ? await _audioPlayer.pause() : await _audioPlayer.play();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _shouldShowBismillah(int surahNumber) => surahNumber != 9 && surahNumber != 1;

  @override
  Widget build(BuildContext context) {
    final viewMode = context.watch<ViewModeProvider>().mode;

    return Consumer<QuranProvider>(
      builder: (context, quran, _) {
        final currentSurahData = quran.surahs[widget.surahIndex];
        final ayahs = _cachedAyahs;

        return Scaffold(
          bottomNavigationBar: _buildAudioPlayerBar(),
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                centerTitle: true,
                expandedHeight: 280,
                pinned: true,
                backgroundColor: const Color(0xFF1B5E20),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: _showTitleInAppBar ? Colors.white : Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
                // ✅ এখন স্ক্রল করলে সঠিকভাবে নাম শো হবে
                title: _showTitleInAppBar
                    ? Text(widget.surahName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                    : null,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        _buildSurahHeaderCard(currentSurahData),
                        if (_shouldShowBismillah(currentSurahData['number'] ?? 0))
                          Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text("﷽", style: TextStyle(fontSize: 35, color: Color(0xFF1B5E20), fontFamily: 'Amiri')),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                height: 1.5, width: 200,
                                color: const Color(0xFF1B5E20).withOpacity(0.3),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: ayahs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ScrollablePositionedList.builder(
              // ✅ এই Physics টি মাস্ট লাগবে
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: ayahs.length,
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemBuilder: (context, index) => _buildAyahItem(ayahs[index], index, viewMode),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahHeaderCard(Map<String, dynamic> surah) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20), width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)])),
      child: Column(
        children: [
          Text(surah['englishName'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(surah['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Amiri')),
          const Divider(color: Colors.white54),
          Text("${(surah['revelationType'] ?? 'MECCAN').toString().toUpperCase()} • ${surah['ayahs']?.length ?? 0} VERSES", style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAyahItem(Map<String, dynamic> ayah, int index, int viewMode) {
    final int globalAyahId = ayah['globalAyahId'] ?? 0;
    final bool isPlaying = _currentlyPlayingAyah == globalAyahId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 15),
        if (viewMode == 0 || viewMode == 1)
          Text(ayah['arabic'] ?? '',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 30, fontFamily: 'QuranFont', height: 1.8, color: Color(0xFF1A1A1A), fontWeight: FontWeight.w500)),
        if (viewMode == 0) const SizedBox(height: 10),
        if (viewMode == 0 || viewMode == 2)
          Align(alignment: Alignment.centerLeft,
              child: Text(ayah['trans'] ?? '',
                  style: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w400, color: Colors.blueGrey[800], fontFamily: 'Translation'))),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              CircleAvatar(radius: 14, backgroundColor: const Color(0xFF1B5E20), child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontSize: 10))),
              const Spacer(),
              IconButton(icon: const Icon(Icons.share_outlined, size: 20, color: Color(0xFF1B5E20)), onPressed: () => ShareLogic.shareAyah(arabicText: ayah['arabic'], englishTranslation: ayah['trans'], surahName: widget.surahName, ayahNumber: index + 1, context: context)),
              const SizedBox(width: 15),
              _isAudioLoading && isPlaying
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B5E20))))
                  : IconButton(icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow_outlined, color: const Color(0xFF1B5E20), size: 24), onPressed: isPlaying ? _togglePlayPause : () => _playFullSurahAudio(index)),
              const SizedBox(width: 15),
              Consumer<BookmarkProvider>(
                builder: (context, provider, child) {
                  final data = {'id': globalAyahId, 'surahName': widget.surahName, 'ayahNumber': index + 1, 'arabic': ayah['arabic'], 'trans': ayah['trans']};
                  return IconButton(icon: Icon(provider.isBookmarked(data) ? Icons.bookmark : Icons.bookmark_border_rounded, color: const Color(0xFF1B5E20)), onPressed: () => provider.toggleBookmark(data));
                },
              ),
            ],
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
          height: 70, padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.skip_previous, color: Color(0xFF1B5E20)), onPressed: () => _audioPlayer.seekToPrevious()),
              GestureDetector(onTap: _togglePlayPause, child: CircleAvatar(backgroundColor: const Color(0xFF1B5E20), child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white))),
              IconButton(icon: const Icon(Icons.skip_next, color: Color(0xFF1B5E20)), onPressed: () => _audioPlayer.seekToNext()),
              IconButton(icon: const Icon(Icons.stop, color: Colors.red), onPressed: () { _audioPlayer.stop(); setState(() => _currentlyPlayingAyah = -1); }),
            ],
          ),
        );
      },
    );
  }
}