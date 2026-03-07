import 'package:flutter/material.dart';
import 'package:holy_quran/screens/bookmark_screen.dart';
import 'package:holy_quran/screens/donation_screen.dart';
import 'package:holy_quran/screens/islamic_alarm_screen.dart';
import 'package:holy_quran/screens/prayer_screen.dart';
import 'package:holy_quran/screens/qibla_screen.dart';
import 'package:holy_quran/screens/tasbih_screen.dart';
import 'package:holy_quran/widgets/about_us.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:holy_quran/providers/alarm_provider.dart';
// import 'package:holy_quran/screens/qibla_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        // ডার্ক মোড সাপোর্ট করার জন্য থিম কালার ব্যবহার করা হয়েছে
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ১. কাস্টম ড্রয়ার হেডার
            _buildHeader(context),

            const SizedBox(height: 10),

            // ২. ড্রয়ার আইটেমগুলো
            _buildDrawerItem(context, Icons.bookmark_rounded, "Bookmarks", () {
              Navigator.pop(context); // ড্রয়ার বন্ধ হবে
              // TODO: bookmark logic call
              // open to bookmar screen
              // ড্রয়ার বন্ধ হবে
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookmarksScreen(),
                ),
              );
            }),
            // _buildDrawerItem(context, Icons.history_rounded, "Last Read", () {
            //   Navigator.pop(context);
            // }),
            // future ai feature update hisabe ashbe
            // _buildDrawerItem(
            //   context,
            //   Icons.explore_rounded,
            //   "Qibla Direction",
            //   () {
            //     Navigator.pop(context);
            //
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => QiblaScreen()),
            //     );
            //
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(builder: (context) =>const QiblaScreen()),
            //     // );
            //   },
            // ),
            _buildDrawerItem(
              context,
              Icons.access_time_filled_rounded,
              "Prayer Times",
              () {
                Navigator.pop(context);

                // call to prayer screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrayerScreen()),
                );
              },
            ),

            _buildDrawerItem(context, Icons.fingerprint,"Tasbih Counter", (){
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => TasbihScreen()));
            }),

            //future update feature alarm
            // islamic alarm
            // _buildDrawerItem(
            //   context,
            //   Icons.alarm,
            //   'Islamic Alarm',
            //       () {
            //     Navigator.pop(context); // ড্রয়ার বন্ধ করবে
            //
            //     // আমরা Provider থেকে বর্তমান অ্যালার্মের ডেটাগুলো নেব
            //     final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
            //
            //     Navigator.push(context, MaterialPageRoute(builder: (context) =>
            //         IslamicAlarmScreen(
            //             alarmTitle: alarmProvider.currentPrayerName, // 'Fajr', 'Dhuhr' ইত্যাদি দেখাবে
            //             surahName: alarmProvider.selectedSurahName ?? "None",
            //             translation: "Verily, with hardship comes ease.", // এটি আপনি ডাইনামিক করতে পারেন
            //             isAzan: alarmProvider.isUsingAzan,
            //             onStop: () {
            //               alarmProvider.stopAlarm();
            //               Navigator.pop(context);
            //             },
            //             onReadQuran: () {
            //               alarmProvider.stopAlarm();
            //               Navigator.pop(context);
            //               // এখানে আপনার কুরআন পেজে যাওয়ার কোড দিন
            //             }
            //         )
            //     ));
            //   },
            // ),



            const Divider(color: Colors.grey, indent: 20, endIndent: 20),

            // _buildDrawerItem(context, Icons.settings_rounded, "Settings", () {
            //   Navigator.pop(context);
            // }),
            _buildDrawerItem(context, Icons.share_rounded, "Share App", () {
              Navigator.pop(context);

              _shareApp(context);


            }),
            _buildDrawerItem(context, Icons.star_rounded, "Rate Us", () {
              Navigator.pop(context);
              _rateApp(context);
            }),
            _buildDrawerItem(context, Icons.volunteer_activism, "Donation", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DonationScreen()),
              );
            }),
            _buildDrawerItem(context, Icons.info_rounded, "About Us", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AboutUsScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  // --- ড্রয়ার হেডার মেথড ---
  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book_rounded, size: 50, color: Colors.white),
          const SizedBox(height: 10),
          const Text(
            "AL-QURAN",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          Text(
            "Learn Quran Every Day",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // --- ড্রয়ার আইটেম মেথড ---
  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E7D32)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }

  // Share App
  void _shareApp(BuildContext context) {
    final String appName = 'Islamic App';
    final String packageName = 'com.example.islamic_app';
    final String playStoreUrl = 'https://play.google.com/store/apps/details?id=$packageName';

    final String shareText = '''
📱 *$appName*

Assalamu Alaikum! I am using this Islamic app. 
You can also download and benefit from it:

🔹 Quran Recitation
🔹 Bengali Translation
🔹 Qibla Direction
🔹 Prayer Times

📲 Android: $playStoreUrl

Jazakallah Khairan 🤲
''';

    // সরাসরি Share করবে
    Share.share(shareText, subject: 'Download $appName');
  }


  // Rate us
  void _rateApp(BuildContext context) async {
    final String appId = 'com.example.islamic_app';  // আপনার প্যাকেজ নাম
    final String playStoreUrl = 'https://play.google.com/store/apps/details?id=$appId';

    try {
      // ✅ Try to launch Play Store app first
      final Uri playStoreUri = Uri.parse('market://details?id=$appId');

      if (await canLaunchUrl(playStoreUri)) {
        // Play Store app installed, open there
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
        // Play Store app not installed, open in browser
        await launchUrl(Uri.parse(playStoreUrl), mode: LaunchMode.externalApplication);
      } else {
        // Nothing works
        debugPrint('❌ Could not launch any URL');
        _showSnackBar(context, 'Could not open Play Store');
      }
    } catch (e) {
      debugPrint('Error opening Play Store: $e');
      _showSnackBar(context, 'Could not open Play Store');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }



}
