import 'package:flutter/material.dart';
import 'package:holy_quran/screens/surah_detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';

class QuranSearch extends SearchDelegate {
  static List<Map<String, dynamic>> _searchHistory = [];
  static Map<int, int> _searchCountMap = {};
  static List<Map<String, dynamic>> _popularSurahs = [];

  @override
  String get searchFieldLabel => "Search Surah or Ayah...";

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1B241A),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white70),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white38, fontSize: 16),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 18),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFF81C784),
      ),
      scaffoldBackgroundColor: const Color(0xFF1B241A),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.white70),
          onPressed: () {
            query = "";
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildBody(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildBody(context);

  Widget _buildBody(BuildContext context) {
    final quran = Provider.of<QuranProvider>(context, listen: false);

    if (quran.surahs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF81C784)),
      );
    }

    if (query.isEmpty) {
      return _buildHome(context);
    }

    final searchTerm = query.toLowerCase().trim();

    // ১. সূরা ফিল্টার (আগের লজিক)
    final surahResults = quran.surahs.where((surah) {
      final enName = (surah['englishName'] ?? '').toString().toLowerCase();
      final arName = (surah['name'] ?? '').toString();
      return enName.contains(searchTerm) || arName.contains(searchTerm);
    }).toList();

    // ২. আয়াতের ভেতর ফিল্টার (ইউজারের সিলেক্ট করা ল্যাঙ্গুয়েজ অনুযায়ী)
    List<Map<String, dynamic>> ayahResults = [];
    final currentTranslations = quran.translations; // প্রোভাইডার থেকে বর্তমান অনুবাদ

    for (var surah in currentTranslations) {
      final List ayahs = surah['ayahs'] ?? [];
      for (var ayah in ayahs) {
        if (ayah['text'].toString().toLowerCase().contains(searchTerm)) {
          ayahResults.add({
            'surahIndex': surah['number'] - 1,
            'ayahNumber': ayah['number'],
            'text': ayah['text'],
            'surahName': quran.surahs[surah['number'] - 1]['englishName'],
          });
        }
      }
    }

    if (surahResults.isEmpty && ayahResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: Colors.white38, size: 50),
            SizedBox(height: 10),
            Text("No results found", style: TextStyle(color: Colors.white38)),
          ],
        ),
      );
    }

    return ListView(
      children: [
        if (surahResults.isNotEmpty) ...[
          _buildSectionTitle("Surahs"),
          ...surahResults.map((surah) => _buildTile(context, surah)),
        ],
        if (ayahResults.isNotEmpty) ...[
          _buildSectionTitle("Ayahs (${quran.currentLang.toUpperCase()})"),
          ...ayahResults.take(30).map((ayah) => _buildAyahTile(context, ayah)),
        ],
      ],
    );
  }

  // আয়াতের জন্য আলাদা টাইল উইজেট
  Widget _buildAyahTile(BuildContext context, Map<String, dynamic> ayah) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: const Icon(Icons.format_align_left, color: Color(0xFF81C784), size: 18),
      title: Text(
        ayah['text'],
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      subtitle: Text(
        "${ayah['surahName']} : Ayah ${ayah['ayahNumber']}",
        style: const TextStyle(color: Colors.white38, fontSize: 11),
      ),
      onTap: () {
        close(context, null);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurahDetailScreen(
              surahIndex: ayah['surahIndex'],
              surahName: ayah['surahName'],
              initialAyahIndex: ayah['ayahNumber'] - 1,
            ),
          ),
        );
      },
    );
  }

  // আপনার আগের বাকি ফাংশনগুলো (_buildHome, _buildSectionTitle, _buildTile) এখানে হুবহু থাকবে
  Widget _buildHome(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return ListView(
          children: [
            if (_searchHistory.isNotEmpty) ...[
              _buildSectionTitle(
                "Recent Searches",
                onClear: () {
                  setState(() {
                    _searchHistory.clear();
                  });
                },
              ),
              ..._searchHistory.map(
                    (surah) => _buildTile(context, surah, onSearch: () => setState(() {})),
              ),
            ],
            if (_popularSurahs.isNotEmpty) ...[
              _buildSectionTitle("Popular Surahs"),
              ..._popularSurahs.map(
                    (surah) => _buildTile(context, surah, isPopular: true),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onClear}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF81C784), fontWeight: FontWeight.bold, fontSize: 13)),
          if (onClear != null)
            InkWell(
              onTap: onClear,
              child: const Text("Clear All", style: TextStyle(color: Colors.white38, fontSize: 12, decoration: TextDecoration.underline)),
            ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, Map<String, dynamic> surah, {bool isPopular = false, VoidCallback? onSearch}) {
    final int surahId = surah['number'] ?? 0;
    final String enName = surah['englishName'] ?? 'Unknown';
    final int totalAyahs = surah['numberOfAyahs'] ?? 0;
    final String arName = surah['name'] ?? '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFF81C784).withOpacity(0.1),
        child: Text("$surahId", style: const TextStyle(color: Color(0xFF81C784), fontSize: 12, fontWeight: FontWeight.bold)),
      ),
      title: Text(enName, style: const TextStyle(color: Colors.white, fontSize: 16)),
      subtitle: Text('$totalAyahs Ayahs', style: const TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: Text(arName, style: const TextStyle(color: Color(0xFF81C784), fontSize: 18, fontWeight: FontWeight.bold)),
      onTap: () {
        _searchCountMap[surahId] = (_searchCountMap[surahId] ?? 0) + 1;
        if (_searchCountMap[surahId] == 3) {
          if (!_popularSurahs.any((e) => e['number'] == surahId)) {
            _popularSurahs.add(surah);
            if (_popularSurahs.length > 3) _popularSurahs.removeAt(0);
          }
        }
        _searchHistory.removeWhere((e) => e['number'] == surahId);
        _searchHistory.insert(0, surah);
        if (_searchHistory.length > 5) _searchHistory.removeLast();

        close(context, null);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurahDetailScreen(
              surahIndex: surahId - 1,
              surahName: enName,
              initialAyahIndex: null,
            ),
          ),
        );
      },
    );
  }
}