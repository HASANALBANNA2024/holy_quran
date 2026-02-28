import 'package:flutter/material.dart';
import 'package:holy_quran/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // স্ক্রিনের সাইজ নেওয়া হচ্ছে
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
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          /// 🔹 Content (Responisve using Center & SingleChildScrollView)
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ক্যালোগ্রাফি (ডেস্কটপের জন্য সর্বোচ্চ ৪৫০ পিক্সেল লিমিট করে দেওয়া হলো)
                  Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Image.asset(
                      "assets/images/bismillah.png",
                      width: size.width * 0.5,
                      fit: BoxFit.contain,
                      // color: Colors.white.withOpacity(0.6),
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 50),

                  const CircularProgressIndicator(
                    color: Colors.white,
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