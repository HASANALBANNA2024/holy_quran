import 'package:flutter/material.dart';
import 'dart:convert'; // JSON decoding এর জন্য
// import 'package:http/http.dart' as http; // TODO: pubspec.yaml এ http এড করে এটা আনকমেন্ট করবেন

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // ---------------------------------------------------------
  // 🔹 API Section: সূরার লিস্ট ফেচ করার ফাংশন
  // ---------------------------------------------------------
  Future<List<dynamic>> fetchSurahList() async {
    // উদাহরণ হিসেবে আল-কুরআন ক্লাউড API ব্যবহার করা হয়েছে
    // final String apiUrl = "https://api.alquran.cloud/v1/surah";

    // final response = await http.get(Uri.parse(apiUrl));

    // if (response.statusCode == 200) {
    //   final Map<String, dynamic> data = json.decode(response.body);
    //   return data['data']; // API এর ডাটা লিস্ট রিটার্ন করবে
    // } else {
    //   throw Exception('Failed to load surahs');
    // }

    // আপাতত টেস্ট করার জন্য ২ সেকেন্ড ডিলে দিয়ে ডামি ডাটা রিটার্ন করছি
    await Future.delayed(const Duration(seconds: 2));
    return List.generate(114, (index) => {
      "number": index + 1,
      "englishName": "Surah Name ${index + 1}",
      "revelationType": index % 2 == 0 ? "Meccan" : "Medinan",
      "numberOfAyahs": 7,
      "name": "سورة"
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.grey),
            onPressed: () {},
          ),
          title: const Text(
            "AL-QURAN",
            style: TextStyle(
              color: Color(0xFF1B5E20),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.grey),
              onPressed: () {},
            ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text("Assalamu Alaikum",
                          style: TextStyle(fontSize: 16, color: Colors.grey[600],)),
                      const SizedBox(height: 5),
                      const Text(
                        "Learn Quran Every Day",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20)),
                      ),
                      const SizedBox(height: 20),
                      _buildLastReadCard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    indicatorColor: Color(0xFF1B5E20),
                    labelColor: Color(0xFF1B5E20),
                    unselectedLabelColor: Colors.grey,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: "Surah"),
                      Tab(text: "Juz"),
                      Tab(text: "Settings"),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              // 🔹 ১. Surah List with FutureBuilder (API ready)
              _buildSurahListWithApi(),
              _buildJuzList(),
              _buildSettingsList(),
            ],
          ),
        ),
      ),
    );
  }

  // --- 🔹 ১ নম্বর সেকশন: API থেকে ডাটা নিয়ে আসার উইজেট ---
  Widget _buildSurahListWithApi() {
    return FutureBuilder<List<dynamic>>(
      future: fetchSurahList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // ডাটা লোড হওয়ার সময় লোডিং দেখাবে
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
          );
        } else if (snapshot.hasError) {
          // কোনো এরর হলে সেটা দেখাবে
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // ডাটা না থাকলে
          return const Center(child: Text("No Surahs found"));
        }

        // ডাটা চলে আসলে লিস্ট দেখাবে
        final surahs = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: surahs.length,
          separatorBuilder: (context, index) => Divider(color: Colors.grey[200]),
          itemBuilder: (context, index) {
            final surah = surahs[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                height: 40, width: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage("https://img.icons8.com/ios/50/2e7d32/star--v1.png"),
                      opacity: 0.3
                  ),
                ),
                child: Text("${surah['number']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text(surah['englishName'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                "${surah['revelationType'].toUpperCase()} • ${surah['numberOfAyahs']} VERSES",
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Text(
                surah['name'],
                style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // এখানে ক্লিক করলে সূরার ডিটেইলস পেজে যাবে
              },
            );
          },
        );
      },
    );
  }

  // --- ২ নম্বর সেকশন: Last Read Card ---
  Widget _buildLastReadCard() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20, bottom: -20,
            child: Icon(Icons.menu_book, size: 150, color: Colors.white.withOpacity(0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: const [
                    Icon(Icons.history, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text("Last Read", style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Al-Fatihah",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const Text("Ayah No: 1", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ৩ নম্বর সেকশন: Juz List View ---
  Widget _buildJuzList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 30,
      itemBuilder: (context, index) => ListTile(
        leading: CircleAvatar(backgroundColor: Colors.green[50], child: Text("${index+1}")),
        title: Text("Juz ${index + 1}"),
        subtitle: const Text("Starts from Surah details..."),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  // --- Settings View ---
  Widget _buildSettingsList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("Preferences", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        ListTile(
          leading: const Icon(Icons.language, color: Colors.green),
          title: const Text("Translation Language"),
          subtitle: const Text("English"),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.format_size, color: Colors.green),
          title: const Text("Arabic Font Size"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode, color: Colors.green),
          title: const Text("Dark Mode"),
          value: false,
          onChanged: (v) {},
        ),
      ],
    );
  }
}

// TabBar Fixed rakhar delegate class
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }
  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}