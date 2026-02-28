import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:holy_quran/screens/splash_screen.dart';
import 'package:holy_quran/themes/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget
{
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      title: "Al Quran",
      debugShowCheckedModeBanner:  false,
      home: SplashScreen(),
    );
  }
}
