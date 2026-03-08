import 'package:flutter/material.dart';
import 'package:holy_quran/providers/alarm_provider.dart';
import 'package:holy_quran/providers/bookmark_provider.dart';
import 'package:holy_quran/providers/notification_provider.dart';
import 'package:holy_quran/providers/qari_provider.dart';
import 'package:holy_quran/providers/quran_provider.dart'; // 🔹 এটি মিসিং ছিল
import 'package:holy_quran/providers/tasbih_provider.dart';
import 'package:holy_quran/providers/view_mode_provider.dart';
import 'package:holy_quran/screens/splash_screen.dart';
import 'package:holy_quran/themes/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async { // এখানে async যোগ করুন

  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => QariProvider()),
        ChangeNotifierProvider(create: (_) => TasbihProvider()),
        ChangeNotifierProvider(create: (_) => ViewModeProvider()),

        // future update feature this
        // ChangeNotifierProvider(create: (_) =>AlarmProvider())
        // ChangeNotifierProvider(create: (_) => LastReadProvider()),

        // ২. এখানে শুধু প্রোভাইডার তৈরি করা হচ্ছে, ডাটা লোড হবে স্প্ল্যাশ স্ক্রিনে
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ৩. থিম প্রোভাইডার ওয়াচ করা
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: "Al Quran",
      debugShowCheckedModeBanner: false,

      // ✅ এটি এখন সরাসরি প্রোভাইডার থেকে সুইচ অনুযায়ী মোড বদলাবে
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // ✅ প্রোভাইডারের কাস্টম থিমগুলো এখানে লোড করা হয়েছে
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,

      home: const SplashScreen(),
    );
  }
}