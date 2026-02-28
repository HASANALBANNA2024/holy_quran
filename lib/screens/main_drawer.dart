import 'package:flutter/material.dart';

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
              // TODO: বুকমার্ক স্ক্রিনে যাওয়ার লজিক
            }),
            // _buildDrawerItem(context, Icons.history_rounded, "Last Read", () {
            //   Navigator.pop(context);
            // }),
            _buildDrawerItem(context, Icons.explore_rounded, "Qibla Direction", () {
              Navigator.pop(context);
            }),
            _buildDrawerItem(context, Icons.access_time_filled_rounded, "Prayer Times", () {
              Navigator.pop(context);
            }),

            const Divider(color: Colors.grey, indent: 20, endIndent: 20),

            // _buildDrawerItem(context, Icons.settings_rounded, "Settings", () {
            //   Navigator.pop(context);
            // }),
            _buildDrawerItem(context, Icons.share_rounded, "Share App", () {
              Navigator.pop(context);
            }),
            _buildDrawerItem(context, Icons.star_rounded, "Rate Us", () {
              Navigator.pop(context);
            }),
            _buildDrawerItem(context, Icons.info_rounded, "About Us", () {
              Navigator.pop(context);
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
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // --- ড্রয়ার আইটেম মেথড ---
  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
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
}