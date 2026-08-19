import 'dart:async';

import 'package:flutter/material.dart';
import 'package:holy_quran/logics/quran_search.dart';
import 'package:holy_quran/providers/qari_provider.dart';
import 'package:holy_quran/providers/quran_provider.dart';
import 'package:holy_quran/providers/view_mode_provider.dart';
import 'package:holy_quran/screens/language_ui.dart';
import 'package:holy_quran/screens/main_drawer.dart';
import 'package:holy_quran/screens/qari_selection_screen.dart';
import 'package:holy_quran/screens/surah_detail_screen.dart';
import 'package:holy_quran/widgets/guidance_overlay_card.dart';
import 'package:holy_quran/widgets/quick_action_card.dart';
import 'package:holy_quran/widgets/show_sadakah_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore_for_file: deprecated_member_use
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadData();
    });
  }

  void _loadData() async {
    // debugPrint("🔄 Loading initial data...");
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);
    if (quranProvider.surahs.isEmpty) {
      await quranProvider.initQuran();
    }

    /// notification related code space
    /*
    if (isNotificationEnabled) {
      await NotificationService.scheduleAll();
      debugdebugPrint("✅ Notifications scheduled successfully!");
      await NotificationService.scheduleDailyGuidance();
    }
    */

    String? lastActionStr = prefs.getString('last_sadakah_action');
    int nextShowDays = prefs.getInt('next_show_days') ?? 0;

    bool shouldShow = false;

    if (lastActionStr == null) {
      shouldShow = true;
    } else {
      DateTime lastActionDate = DateTime.parse(lastActionStr);
      DateTime today = DateTime.now();
      int differenceInDays = today.difference(lastActionDate).inDays;

      if (differenceInDays >= nextShowDays) {
        shouldShow = true;
      }
    }

    /// condition of overlay call
    if (shouldShow) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && quranProvider.translations.isNotEmpty) {
          showSadakahOverlay(
            context,
            quranProvider.currentLang,
            quranProvider.translations,
          );
        }
      });
    }
  }

  // void _updateCounter() {
  //   setState(() {
  //     /// counter update
  //   });
  // }
  void handleNotificationClick(String payload, BuildContext context) {
    List<String> parts = payload.split('|');
    showGuidanceOverlay(
      context: context,
      category: parts[0],
      translation: parts[1],
      surahName: parts[2],
      ayahNumber: int.parse(parts[4]),
      onTap: () {
        if (!context.mounted) return;
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurahDetailScreen(
              surahIndex: int.parse(parts[3]), // index 3 e holo Surah index
              surahName: parts[2],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const MainDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.green,
          elevation: 0,
          title: const Text(
            "AL-QURAN",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontFamily: 'Translation',
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white70),
              onPressed: () {
                showSearch(context: context, delegate: QuranSearch());
              },
            ),
          ],
          leading: Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.menu, color: Colors.white70),
              );
            },
          ),
        ),

        //body Started
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
                      Center(
                        child: Text(
                          "Assalamu Alaikum",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            fontFamily: 'Translation',
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Center(
                        child: Text(
                          "Learn Quran Every Day",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                            fontFamily: 'Translation',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Quick Action Button
                      QuickActionCard(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Translation',
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Translation',
                    ),
                    indicatorColor: const Color(0xFF1B5E20),
                    labelColor: const Color(0xFF1B5E20),
                    unselectedLabelColor: Colors.grey[600],
                    indicatorWeight: 2,
                    tabs: const [
                      Tab(text: "Surah"),
                      Tab(text: "Settings"),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [_buildSurahListWithApi(), _buildSettingsList()],
          ),
        ),
        //body Ended
      ),
    );
  }

  Widget _buildSurahListWithApi() {
    final quranProvider = Provider.of<QuranProvider>(context);
    final surahList = quranProvider.surahs;

    if (surahList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF1B5E20)),
            SizedBox(height: 15),
            Text("Loading Surahs...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: surahList.length,
      separatorBuilder: (context, index) => Divider(color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final surah = surahList[index];

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/surah_icon_image.png"),
                opacity: 0.3,
              ),
            ),
            child: Center(child: Text("${surah['number'] ?? index + 1}")),
          ),
          title: Text(
            surah['englishName'] ?? "Unknown",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              height: 1.5,
              color: Colors.blueGrey[700],
              fontFamily: 'Translation',
            ),
          ),
          subtitle: Text(
            "${(surah['revelationType'] ?? 'MECCAN').toString().toUpperCase()} • ${surah['ayahs']?.length ?? 0} VERSES",
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueGrey[700],
              fontFamily: 'Translation',
            ),
          ),
          trailing: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              surah['name'] ?? "",
              style: const TextStyle(
                color: Color(0xFF1B5E20),
                fontSize: 24,
                fontFamily: 'QuranFont',
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SurahDetailScreen(
                  surahIndex: index,
                  surahName: surah['englishName'] ?? "Surah",
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "Preferences",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            fontFamily: 'Translation',
          ),
        ),
        const SizedBox(height: 10),
        ListTile(
          leading: const Icon(Icons.language, color: Colors.green),
          title: const Text("Translation Language"),
          subtitle: Text(
            Provider.of<QuranProvider>(context).currentLang.toUpperCase(),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LanguageScreen()),
            );
          },
        ),
        ListTile(
          title: const Text("Change Qari"),
          subtitle: Text(context.watch<QariProvider>().selectedQariName),
          leading: const Icon(Icons.mic, color: Colors.green),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QariSelectionScreen(),
              ),
            );
          },
        ),
        // show and hide of arabic and translation
        ListTile(
          leading: const Icon(Icons.remove_red_eye, color: Colors.green),
          title: const Text("Display Options"),
          subtitle: Text(
            context.watch<ViewModeProvider>().mode == 0
                ? "Showing Both"
                : (context.watch<ViewModeProvider>().mode == 1
                      ? "Arabic Only"
                      : "Translation Only"),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showViewModeDialog(context),
        ),

        // SwitchListTile(
        //   secondary: const Icon(Icons.dark_mode, color: Colors.green),
        //   title: const Text("Dark Mode"),
        //   value: Provider.of<ThemeProvider>(context).isDarkMode,
        //   onChanged: (value) {
        //     Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
        //   },
        // ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

void _showViewModeDialog(BuildContext context) {
  final provider = Provider.of<ViewModeProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Display Options",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<int>(
            title: const Text("Both (Arabic & Translation)"),
            value: 0,
            groupValue: provider.mode,
            activeColor: Colors.green,
            onChanged: (val) {
              provider.setViewMode(val!);
              Navigator.pop(context);
            },
          ),
          RadioListTile<int>(
            title: const Text("Arabic Only"),
            value: 1,
            groupValue: provider.mode,
            activeColor: Colors.green,
            onChanged: (val) {
              provider.setViewMode(val!);
              Navigator.pop(context);
            },
          ),
          RadioListTile<int>(
            title: const Text("Translation Only"),
            value: 2,
            groupValue: provider.mode,
            activeColor: Colors.green,
            onChanged: (val) {
              provider.setViewMode(val!);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}
