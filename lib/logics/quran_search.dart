// lib/logics/quran_search.dart

import 'package:flutter/material.dart';
import 'package:holy_quran/screens/surah_detail_screen.dart';
import 'package:provider/provider.dart';

import '../providers/quran_provider.dart';

class QuranSearch extends SearchDelegate {
  // ডাটা স্ট্যাটিক রাখা হয়েছে যাতে স্ক্রিন রিলোড হলেও না হারায়
  static List<Map<String, dynamic>> _searchHistory = [];
  static Map<int, int> _searchCountMap =
      {}; // কোন সূরা কতবার সার্চ হয়েছে তা রাখার জন্য
  static List<Map<String, dynamic>> _popularSurahs = [];

  @override
  String get searchFieldLabel => "Search Surah...";

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

    if (quran.surahs == null || quran.surahs!.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF81C784)),
      );
    }

    if (query.isEmpty) {
      return _buildHome(context);
    }

    final searchTerm = query.toLowerCase().trim();
    final results = quran.surahs!.where((surah) {
      final enName = (surah['englishName'] ?? '').toString().toLowerCase();
      final arName = (surah['arabicName'] ?? surah['name'] ?? '').toString();
      return enName.contains(searchTerm) || arName.contains(searchTerm);
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: Colors.white38, size: 50),
            SizedBox(height: 10),
            Text("No surah found", style: TextStyle(color: Colors.white38)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (ctx, index) {
        return _buildTile(context, results[index]);
      },
    );
  }

  Widget _buildHome(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return ListView(
          children: [
            // Recent Searches (সর্বোচ্চ ৫টি)
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
                (surah) =>
                    _buildTile(context, surah, onSearch: () => setState(() {})),
              ),
            ],

            // Popular Surahs (সর্বোচ্চ ৩টি, যারা ৩ বারের বেশি সার্চ হয়েছে)
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
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF81C784),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (onClear != null)
            TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: Colors.white38,
              ),
              child: const Text(
                "Clear All",
                style: TextStyle(
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    Map<String, dynamic> surah, {
    bool isPopular = false,
    VoidCallback? onSearch,
  }) {
    final int surahId = surah['number'] ?? surah['id'] ?? 0;
    final String enName = surah['englishName'] ?? 'Unknown';
    final int totalAyahs = surah['numberOfAyahs'] ?? surah['totalAyahs'] ?? 0;
    final String arName = surah['arabicName'] ?? surah['name'] ?? '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF81C784).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Text(
          "$surahId",
          style: const TextStyle(
            color: Color(0xFF81C784),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      title: Text(
        enName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '$totalAyahs Ayahs',
        style: const TextStyle(color: Colors.white38, fontSize: 13),
      ),
      trailing: Text(
        arName,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Color(0xFF81C784),
          fontSize: 22,
          fontFamily: 'Scheherazade',
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        // ১. সার্চ কাউন্ট বাড়ানো লজিক
        _searchCountMap[surahId] = (_searchCountMap[surahId] ?? 0) + 1;

        // ২. যদি ৩ বার সার্চ হয় তবে পপুলারে অ্যাড করা
        if (_searchCountMap[surahId] == 3) {
          if (!_popularSurahs.any((e) => (e['number'] ?? e['id']) == surahId)) {
            _popularSurahs.add(surah);
            if (_popularSurahs.length > 3) _popularSurahs.removeAt(0);
          }
        }

        // ৩. রিসেন্ট সার্চে অ্যাড করা (সর্বোচ্চ ৫টি)
        _searchHistory.removeWhere((e) => (e['number'] ?? e['id']) == surahId);
        _searchHistory.insert(0, surah);
        if (_searchHistory.length > 5) _searchHistory.removeLast();

        // ৪. সার্চ বার বন্ধ করা
        close(context, null);

        // ✅ ৫. সূরা ডিটেইল স্ক্রিনে নিয়ে যাওয়া (সরাসরি পুশ লজিক)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurahDetailScreen(
              surahIndex: surahId - 1, // ইনডেক্স ঠিক রাখা হয়েছে
              surahName: enName,
              initialAyahIndex: null, // ডিফল্ট শুরু থেকে
            ),
          ),
        );
      },
    );
  }
}
