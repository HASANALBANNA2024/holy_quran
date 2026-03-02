import 'package:flutter/material.dart';
import 'package:holy_quran/logics/quran_sync.dart';
import 'package:holy_quran/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
// নিশ্চিত করুন এই পাথটি ঠিক আছে

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // ডাউনলোডের অবস্থা দেখানোর জন্য একটি মেসেজ ভেরিয়েবল
  String _loadingMessage = "Preparing your experience...";

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Shared Preferences থেকে চেক করা হচ্ছে আগে ডাউনলোড হয়েছে কি না
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDownloaded = prefs.getBool('isDownloaded') ?? false;

    if (!isDownloaded) {
      setState(() {
        _loadingMessage =
            "Downloading Quran for the first time...\nPlease wait, it won't take long.";
      });

      // প্রথমবার ইনস্টলে English (en.sahih) ডিফল্ট হিসেবে ডাউনলোড হবে
      bool success = await QuranSync.syncQuran("en.sahih");

      if (success) {
        await prefs.setBool('isDownloaded', true);
        await prefs.setString('currentLang', "en.sahih");
        _navigateToHome();
      } else {
        // যদি ইন্টারনেট না থাকে বা এরর হয়
        setState(() {
          _loadingMessage =
              "Connection Error!\nPlease check internet and restart.";
        });
      }
    } else {
      // যদি আগে থেকেই ডাউনলোড থাকে, তবে ৩ সেকেন্ড অপেক্ষা করে হোম স্ক্রিনে যাবে
      await Future.delayed(const Duration(seconds: 3));
      _navigateToHome();
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
      body: Stack(
        children: [
          /// 🔹 Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/final_background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 Dark Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          /// 🔹 Content
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Image.asset(
                      "assets/images/bismillah.png",
                      width: size.width * 0.5,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Text(
                        "﷽",
                        style: TextStyle(color: Colors.white, fontSize: 50),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Al Quran",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Read • Listen • Learn",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),

                  const SizedBox(height: 50),

                  const CircularProgressIndicator(color: Colors.white),

                  const SizedBox(height: 20),

                  /// 🔹 Dynamic Loading Message
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      _loadingMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
