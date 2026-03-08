import 'dart:async';
import 'dart:io';
import 'package:holy_quran/data/guidance_data.dart';
import 'package:flutter/material.dart';
import 'package:holy_quran/widgets/show_sadakah_overlay.dart'; // আপনার ফোল্ডার পাথ অনুযায়ী
import 'package:holy_quran/logics/quran_search.dart';
import 'package:holy_quran/providers/quran_provider.dart';
import 'package:holy_quran/screens/language_ui.dart';
import 'package:holy_quran/screens/main_drawer.dart';
import 'package:holy_quran/screens/surah_detail_screen.dart';
import 'package:holy_quran/themes/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holy_quran/widgets/quick_action_card.dart';
import 'package:provider/provider.dart';
import 'package:holy_quran/providers/qari_provider.dart';
import 'package:holy_quran/screens/qari_selection_screen.dart';
import 'package:holy_quran/providers/view_mode_provider.dart';
import 'package:holy_quran/providers/notification_provider.dart';
import 'package:holy_quran/screens/notification_screen.dart';
import 'package:holy_quran/services/notification_service.dart';
import 'package:holy_quran/widgets/guidance_overlay_card.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool isNotificationEnabled = true;
  // function call to bridge of notification
  void triggerDailyGuidance(String category, String text, String surahName, int surahIdx, int ayahNum) {
    // ১. ফোনে সাউন্ডসহ নোটিফিকেশন পাঠানো
    NotificationService.showInstantNotification(
        title: category,
        body: text,
        payload: "$category|$text|$surahName|$surahIdx|$ayahNum"
    );

    // ২. অ্যাপের ইনবক্সে সেভ করা
    Provider.of<NotificationProvider>(context, listen: false).addNotification(
        NotificationModel(
          id: DateTime.now().toString(),
          category: category,
          text: text,
          surahName: surahName,
          surahIndex: surahIdx,
          ayahNumber: ayahNum,
          time: DateTime.now(),
        )
    );
  }

  @override
  // ১. ক্লাসের শুরুতে এই ভেরিয়েবলগুলো থাকতে হবে (নাহলে লাল দাগ আসবে)
  Timer? _timer;
// PrayerTimes বা আপনার ডাটা টাইপ অনুযায়ী ভেরিয়েবল
  var _prayerTimes;

  @override
  void initState() {
    super.initState();

    // WidgetsBinding এর ভেতরে সব লজিক রাখুন
    WidgetsBinding.instance.addPostFrameCallback((_) async {

      // ১. অ্যান্ড্রয়েড নোটিফিকেশন পারমিশন রিকোয়েস্ট
      if (Platform.isAndroid) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }

      // ২. নোটিফিকেশন সার্ভিস ইনিশিয়ালাইজ (Handler সহ)
      await NotificationService.init((payload) {
        if (payload != null && mounted) {
          handleNotificationClick(payload, context);
        }
      });

      // ৩. ডাটা লোড করার ফাংশন কল
      _loadData();

      // ৪. টাইমার সেট করা (Prayer times কাউন্টারের জন্য)
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_prayerTimes != null && mounted) {
          _updateCounter();
        }
      });
    });
  }

  void _loadData() async {
    print("🔄 Loading initial data and scheduling notifications...");

    // ১. SharedPreferences থেকে নোটিফিকেশন সেটিংস লোড করা (নতুন যুক্ত)
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        isNotificationEnabled = prefs.getBool('isNotificationEnabled') ?? true;
      });
    }

    // ২. কুরআন প্রোভাইডার থেকে ডাটা লোড নিশ্চিত করা (আপনার আগের লজিক)
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);
    if (quranProvider.surahs.isEmpty) {
      await quranProvider.initQuran();
    }

    // ৩. ডাটা লোড হওয়ার পর নোটিফিকেশন শিডিউল করা (আপনার আগের লজিক)
    if (isNotificationEnabled) {
      await NotificationService.scheduleAll();
      print("✅ Notifications scheduled successfully!");
      await NotificationService.scheduleDailyGuidance(GuidanceData.categories);
    }

    // ৪. সাদাকাহ ওভারলে সাইকেল লজিক (আপনার আগের লজিক)
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

    // ৫. শর্ত পূরণ হলে ২ সেকেন্ড পর ওভারলে কল (আপনার আগের লজিক)
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


  void _updateCounter() {
    setState(() {
      // কাউন্টার আপডেট করার কোড
    });
  }
  // নোটিফিকেশন ক্লিক হ্যান্ডেল করার ফাংশন
  void handleNotificationClick(String payload, BuildContext context) {
    List<String> parts = payload.split('|');

    // ৫ নম্বর ফিচারের সেই সুন্দর ওভারলে কার্ডটি এখানে কল হবে
    showGuidanceOverlay(
      context: context,
      category: parts[0],
      translation: parts[1],
      surahName: parts[2],
      ayahNumber: int.parse(parts[4]),
      onTap: () {
        Navigator.pop(context); // কার্ড বন্ধ করা

        // এখানে সরাসরি সূরা ডিটেইলসে যাওয়ার লজিক দিন
        // উদাহরণ:
        // Navigator.push(context, MaterialPageRoute(builder: (context) => SurahDetails(index: parts[4])));
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => SurahDetailScreen(
            surahIndex: int.parse(parts[3]), // index 3 e holo Surah index
            surahName: parts[2],
          ),
        ));
      },
    );
  }


  //

   @override
  Widget build(BuildContext context) {
     // future update feature alarm
     // //alarm function call started
     // final alarmProvider = Provider.of<AlarmProvider>(context);
     //
     // // ২. যদি অ্যালার্ম বাজতে শুরু করে, তবে অটোমেটিক স্ক্রিন চেঞ্জ হবে
     // if (alarmProvider.isAlarmPlaying) {
     //   WidgetsBinding.instance.addPostFrameCallback((_) {
     //     Navigator.push(
     //       context,
     //       MaterialPageRoute(
     //         builder: (context) => IslamicAlarmScreen(
     //           alarmTitle: alarmProvider.currentPrayerName,
     //           surahName: alarmProvider.selectedSurahName ?? "Adhan",
     //           translation: "নিশ্চয় কষ্টের সাথে স্বস্তি আছে।",
     //           isAzan: alarmProvider.isUsingAzan,
     //           onStop: () {
     //             alarmProvider.stopAlarm();
     //             Navigator.pop(context);
     //           },
     //           onReadQuran: () {
     //             alarmProvider.stopAlarm();
     //             Navigator.pop(context);
     //             // আপনার কুরআন লিস্ট পেজে যাওয়ার কোড
     //           },
     //         ),
     //       ),
     //     );
     //   });
     // }
     // // alarm function call end
     //
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
              fontFamily: 'Translation'
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
            IconButton(
              icon: Icon(Icons.notifications_active_outlined, color: Colors.white70),
              onPressed: () {
                context.read<NotificationProvider>().markAsRead();
                Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationScreen()));
              },
            ),
            if (context.watch<NotificationProvider>().unreadCount > 0)
              Positioned(
                right: 10, top: 10,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                  constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text('${context.watch<NotificationProvider>().unreadCount}',
                      style: TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                ),
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
        body:  NestedScrollView(
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
                              fontFamily: 'Translation'
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
                              fontFamily: 'Translation'
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
                        fontWeight: FontWeight.w500
                    ),
                    unselectedLabelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Translation'
                    ),
                    indicatorColor: const Color(0xFF1B5E20),
                    labelColor: const Color(0xFF1B5E20),
                    unselectedLabelColor: Colors.grey[600], // grey[1000] হয় না, ৬০০ বা ৭০০ দিন
                    indicatorWeight: 2,
                    tabs: const [
                      Tab(text: "Surah"),
                      // Juz কমেন্ট করা আছে, তাই এখানে এখন ২টি ট্যাব
                      Tab(text: "Settings"),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildSurahListWithApi(),
              // _buildJuzList(),
              _buildSettingsList(),
            ],
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
            Text("Loading Surahs...",
                style: TextStyle(
                  color: Colors.grey,


                )),
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
                image: AssetImage(
                  "assets/images/surah_icon_image.png",
                ),
                opacity: 0.3,
              ),
            ),
            child: Center(
              child: Text("${surah['number'] ?? index + 1}"),
            )
          ),
          title: Text(
            surah['englishName'] ?? "Unknown", // ✅ ইংরেজি নাম দেখাবে
            style:TextStyle(
                fontWeight: FontWeight.bold,
              height: 1.5,
              color: Colors.blueGrey[700], // প্রফেশনাল গ্রে কালার
              fontFamily: 'Translation',
            ),
          ),
          subtitle: Text(
            "${(surah['revelationType'] ?? 'MECCAN').toString().toUpperCase()} • ${surah['ayahs']?.length ?? 0} VERSES",
            style: TextStyle(fontSize: 12,
              color: Colors.blueGrey[700], // প্রফেশনাল গ্রে কালার
              fontFamily: 'Translation',
            ),
          ),
          trailing: Directionality(
            textDirection: TextDirection.rtl, // আরবি লেখার জন্য এটি যোগ করুন
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
                  surahName:
                      surah['englishName'] ?? "Surah", // ✅ ইংরেজি নাম পাঠানো
                ),
              ),
            );
          },
        );
      },
    );
  }
 // Future Feature Add
  // Widget _buildJuzList() {
  //   return ListView.builder(
  //     padding: const EdgeInsets.all(20),
  //     itemCount: 30,
  //     itemBuilder: (context, index) => ListTile(
  //       leading: CircleAvatar(
  //         backgroundColor: Colors.green[50],
  //         child: Text("${index + 1}"),
  //       ),
  //       title: Text("Juz ${index + 1}"),
  //       subtitle: const Text("Starts from Surah details..."),
  //       trailing: const Icon(Icons.arrow_forward_ios, size: 14),
  //     ),
  //   );
  // }

  Widget _buildSettingsList() {

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "Preferences",
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16, fontFamily: 'Translation'),
        ),
        const SizedBox(height: 10),
        ListTile(
          leading: const Icon(
              Icons.language,
              color: Colors.green),
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
        //Future Feature add of Font Size input of user
        // ListTile(
        //   leading: const Icon(Icons.format_size, color: Colors.green),
        //   title: const Text("Arabic Font Size"),
        //   trailing: const Icon(Icons.chevron_right),
        //   onTap: () {},
        // ),
        ListTile(
          title: const Text("Change Qari"),
          subtitle: Text(context.watch<QariProvider>().selectedQariName),
          leading: const Icon(Icons.mic, color: Colors.green),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const QariSelectionScreen()));
          },
        ),
        // show and hide of arabic and translation
        ListTile(
          leading: const Icon(Icons.remove_red_eye, color: Colors.green),
          title: const Text("Display Options"),
          subtitle: Text(
              context.watch<ViewModeProvider>().mode == 0
                  ? "Showing Both"
                  : (context.watch<ViewModeProvider>().mode == 1 ? "Arabic Only" : "Translation Only")
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showViewModeDialog(context),
        ),


        ListTile(
          title: const Text(
            "Notifications",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            isNotificationEnabled ? "On" : "Off",
            style: TextStyle(color: isNotificationEnabled ? Colors.green[700] : Colors.grey),
          ),
          leading: Icon(
            isNotificationEnabled ? Icons.notifications_active : Icons.notifications_off,
            color: Colors.green, // আপনার প্রিয় ডার্ক গ্রিন কালার
          ),
          trailing: Switch(
            value: isNotificationEnabled,
            activeColor: const Color(0xFF1B5E20),
            onChanged: (bool value) async {
              setState(() {
                isNotificationEnabled = value;
              });

              // সরাসরি সার্ভিস ক্লাস কল করুন (এতে হোম স্ক্রিনে আলাদা ফাংশন লাগবে না)
              if (value == false) {
                await NotificationService.cancelAll();
              } else {
                await NotificationService.scheduleAll();
              }

              // সেটিংস সেভ করার জন্য (SharedPreferences)
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isNotificationEnabled', value);
            },
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode, color: Colors.green),
          title: const Text("Dark Mode"),
          value: Provider.of<ThemeProvider>(context).isDarkMode,
          onChanged: (value) {
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          },
        ),
      ],
    );
  }
}

// 🔹 TabBar Pinned রাখার জন্য হেল্পার ক্লাস
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


// show view mode Dialog Message Widget
void _showViewModeDialog(BuildContext context) {
  // এখানে context.read ব্যবহার করা হয়েছে কারণ শুধু ডেটা পাঠাচ্ছি, লিসেন করার দরকার নেই
  final provider = Provider.of<ViewModeProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Display Options", style: TextStyle(fontWeight: FontWeight.bold)),
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