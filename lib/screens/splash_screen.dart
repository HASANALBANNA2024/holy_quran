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
  String _loadingMessage = "Preparing your experience...";

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // ১. প্রোভাইডার চেক করা
      final quranProvider = Provider.of<QuranProvider>(context, listen: false);

      // ২. ডাটা লোড করা শুরু
      await quranProvider.initQuran();

      // ৩. ডাটা লোড হওয়ার পর চেক করা যে সবকিছু ঠিক আছে কি না
      if (mounted) {
        if (quranProvider.surahs.isNotEmpty) {
          setState(() {
            _loadingMessage = "Quranic Data Loaded!";
          });

          // ৪. সফলভাবে লোড হলে সামান্য বিরতি দিয়ে হোমে যাওয়া
          await Future.delayed(const Duration(milliseconds: 800));
          _navigateToHome();
        } else {
          // যদি ডাটা খালি থাকে (ফাইল না পাওয়া গেলে)
          setState(() {
            _loadingMessage = "Data not found! Checking assets...";
          });
        }
      }
    } catch (e) {
      // ৫. এরর হ্যান্ডেলিং
      if (mounted) {
        setState(() {
          _loadingMessage = "Error: $e";
        });
        debugPrint("Initialization Error: $e");
      }
    }
  }

  // ফিক্স: এখানে শুধু একটি ফাংশন রাখা হয়েছে এবং রেড লাইন দূর করা হয়েছে
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
