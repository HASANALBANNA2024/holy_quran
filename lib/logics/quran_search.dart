import 'package:flutter/material.dart';

class QuranSearch extends SearchDelegate {
  // ১. আপনার অ্যাপের সব ডেটা এখানে থাকবে (ভবিষ্যতে সূরা বা দোয়ার লিস্ট এখানে বাড়াবেন)
  final List<Map<String, dynamic>> searchData = [
    {"name": "Al-Fatihah", "type": "Surah", "id": 1},
    {"name": "Al-Baqarah", "type": "Surah", "id": 2},
    {"name": "Ya-Sin", "type": "Surah", "id": 36},
    {"name": "Tasbih Counter", "type": "Tool", "id": "tasbih"},
    {"name": "Prayer Times", "type": "Tool", "id": "prayer"},
    {"name": "Asma-ul-Husna", "type": "Names", "id": 99},
  ];

  @override
  String get searchFieldLabel => "Search Surah, Dua, Tool...";

  // ২. ডার্ক থিম কাস্টমাইজেশন (আপনার ড্যাশবোর্ডের সাথে ম্যাচিং)
  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1B241A),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white38, fontSize: 16),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 18),
      ),
      // নিচে লিস্টের ব্যাকগ্রাউন্ড কালার
      scaffoldBackgroundColor: const Color(0xFF1B241A),
    );
  }

  // ৩. সার্চ ক্লিয়ার বাটন
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.white70),
          onPressed: () => query = "",
        )
    ];
  }

  // ৪. ব্যাক বাটন
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
      onPressed: () => close(context, null),
    );
  }

  // ৫. সার্চ রেজাল্ট (এন্টার চাপলে যা হবে)
  @override
  Widget buildResults(BuildContext context) {
    return _showSearchResults();
  }

  // ৬. টাইপ করার সময় সাজেশন (সবচেয়ে গুরুত্বপূর্ণ অংশ)
  @override
  Widget buildSuggestions(BuildContext context) {
    return _showSearchResults();
  }

  // রেজাল্ট দেখানোর কমন ফাংশন
  Widget _showSearchResults() {
    final suggestions = searchData.where((element) {
      return element['name'].toLowerCase().contains(query.toLowerCase()) ||
          element['type'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (suggestions.isEmpty) {
      return const Center(
        child: Text("No results found", style: TextStyle(color: Colors.white38)),
      );
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: Icon(
            item['type'] == 'Surah' ? Icons.menu_book : Icons.auto_awesome,
            color: const Color(0xFF81C784),
          ),
          title: Text(item['name'], style: const TextStyle(color: Colors.white)),
          subtitle: Text(item['type'], style: const TextStyle(color: Colors.white38, fontSize: 12)),
          onTap: () {
            // এখানে নেভিগেশন লজিক (আপনার পেজ অনুযায়ী পরিবর্তন করবেন)
            if (item['id'] == "prayer") {
              // Prayer Screen এ যাবে
              Navigator.pushReplacementNamed(context, '/prayer');
            } else if (item['id'] == "tasbih") {
              // Tasbih Screen এ যাবে
              Navigator.pushReplacementNamed(context, '/tasbih');
            } else {
              // আপাতত ক্লোজ করে দিচ্ছি
              close(context, item);
            }
          },
        );
      },
    );
  }
}