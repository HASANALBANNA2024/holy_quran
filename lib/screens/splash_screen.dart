import 'package:flutter/material.dart';
import 'package:holy_quran/providers/quran_provider.dart';
import 'package:holy_quran/screens/home_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // আপনার আইকনের ব্যাকগ্রাউন্ডের সাথে হুবহু মিল রাখার জন্য এই কালার কোডটি ব্যবহার করুন
  final Color themeColor = const Color(0xFF607D8B);
  String _loadingMessage = "Preparing your experience...";

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final quranProvider = Provider.of<QuranProvider>(context, listen: false);
      await quranProvider.initQuran();

      if (mounted) {
        if (quranProvider.surahs.isNotEmpty) {
          setState(() {
            _loadingMessage = "Quranic Data Loaded!";
          });
          await Future.delayed(const Duration(milliseconds: 800));
          _navigateToHome();
        } else {
          setState(() {
            _loadingMessage = "Data not found! Checking assets...";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingMessage = "Error: $e";
        });
      }
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white, // এখানে সলিড ব্লু-গ্রে সেট করা হয়েছে
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 App Logo
              Container(
                constraints: const BoxConstraints(maxWidth: 450),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Image.asset(
                  "assets/images/app_icon.png", // এক্সটেনশন .png যোগ করা হয়েছে
                  width: size.width * 0.4, // লোগোর সাইজ কিছুটা ছোট করা হয়েছে যাতে সুন্দর লাগে
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    "﷽",
                    style: TextStyle(color: Colors.grey, fontSize: 60),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 🔹 App Title
              const Text(
                "Holy Quran",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Read • Listen • Learn",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 60),

              // 🔹 Loading Indicator
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: Colors.grey,
                  strokeWidth: 3,
                ),
              ),

              const SizedBox(height: 25),

              // 🔹 Loading Status
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  _loadingMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}