import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  String _appVersion = "1.0.0";
  String _appName = "Islamic App";

  @override
  void initState() {
    super.initState();
    _getAppInfo();
  }

  Future<void> _getAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _appName = packageInfo.appName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // অ্যাপবারকে আরও উপরে তুলে দেওয়ার জন্য
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "About Us",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Pattern and Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF2E7D32), Colors.white.withOpacity(0.9)],
              ),
            ),
          ),

          // Pattern Image (Separate to avoid path double-up)
          Opacity(
            opacity: 0.05,
            child: Image.asset(
              'assets/islamic_pattern.png',
              repeat: ImageRepeat.repeat,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => const SizedBox(), // ইমেজ না থাকলে এরর দেখাবে না
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // ১. ইসলামিক আর্চ (ডায়নামিক হাইট সহ)
                    _buildIslamicArch(),
                    const SizedBox(height: 20),

                    // ২. প্রোফাইল কার্ড
                    _buildProfileCard(),
                    const SizedBox(height: 20),

                    // ৩. মিশন ও ভিশন
                    _buildMissionCard(),
                    const SizedBox(height: 20),

                    // ৪. টিম সেকশন
                    _buildTeamSection(),
                    const SizedBox(height: 20),

                    // ৫. কন্টাক্ট সেকশন
                    _buildContactSection(),
                    const SizedBox(height: 20),

                    // ৬. ক্রেডিট সেকশন
                    _buildCreditsSection(),
                    const SizedBox(height: 20),

                    // ৭. দোয়া সেকশন
                    _buildDuaSection(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIslamicArch() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomPaint(
        painter: IslamicArchPainter(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ওভারল্যাপ রোধ করতে কন্টেন্ট অনুযায়ী সাইজ নিবে
            children: [
              const Icon(Icons.mosque, color: Color(0xFFE1B55E), size: 45),
              const SizedBox(height: 15),
              const Text(
                'In the Name of Allah, the Most Gracious,\nthe Most Merciful',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1B5E20),
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFFE1B55E).withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF2E7D32),
            child: Icon(Icons.mosque, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 15),
          Text(
            _appName,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text('Version $_appVersion'),
            backgroundColor: const Color(0xFFE1B55E).withOpacity(0.2),
            labelStyle: const TextStyle(color: Color(0xFF8D6E63), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          const Text(
            'رَحْمَةٌ لِّلْعَالَمِينَ',
            style: TextStyle(fontSize: 24, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
          ),
          const Text(
            'A Mercy to the Worlds',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Color(0xFFE1B55E), size: 18),
              SizedBox(width: 10),
              Text('Our Mission', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(width: 10),
              Icon(Icons.star, color: Color(0xFFE1B55E), size: 18),
            ],
          ),
          SizedBox(height: 15),
          Text(
            'To create a comprehensive Islamic app based on the Quran and Sunnah, where every Muslim can easily fulfill all their daily Islamic needs.',
            style: TextStyle(color: Colors.white70, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection() => _cardWrapper(
    title: 'Development Team',
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTeamMember(name: 'MD. Hasan Al Banna', role: 'Lead Dev', icon: Icons.code),
        const SizedBox(width: 40),
        _buildTeamMember(name: 'Afsana Sultana', role: 'Designer', icon: Icons.palette),
      ],
    ),
  );

  Widget _buildContactSection() => _cardWrapper(
    title: 'Contact Us',
    child: Wrap(
      spacing: 20,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _buildSocialButton(Icons.email, Colors.red, 'mailto:support@islamicapp.com', 'Email'),
        _buildSocialButton(Icons.public, Colors.blue, 'https://www.islamicapp.com', 'Web'),
        _buildSocialButton(Icons.facebook, Colors.indigo, 'https://facebook.com/islamicapp', 'FB'),
      ],
    ),
  );

  Widget _buildCreditsSection() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFFF5F0E6), borderRadius: BorderRadius.circular(20)),
    child: const Column(
      children: [
        Icon(Icons.favorite, color: Colors.red),
        SizedBox(height: 10),
        Text('Special Thanks', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
        Text('Al-Quran, Al-Hadith, and all the Islamic scholars.', textAlign: TextAlign.center),
      ],
    ),
  );

  Widget _buildDuaSection() => const Column(
    children: [
      Text('رَبَّنَا تَقَبَّلْ مِنَّا ۖ إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ',
          style: TextStyle(fontSize: 18, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      Text('Our Lord! Accept from us. Indeed, You are the All-Hearing.',
          style: TextStyle(fontSize: 13, color: Colors.grey), textAlign: TextAlign.center),
    ],
  );

  // Helper Widgets
  Widget _cardWrapper({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
        const SizedBox(height: 15),
        child,
      ]),
    );
  }

  Widget _buildTeamMember({required String name, required String role, required IconData icon}) {
    return Column(children: [
      CircleAvatar(backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1), child: Icon(icon, color: const Color(0xFF2E7D32))),
      const SizedBox(height: 8),
      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      Text(role, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ]);
  }

  Widget _buildSocialButton(IconData icon, Color color, String url, String label) {
    return InkWell(
      onTap: () async => await launchUrl(Uri.parse(url)),
      child: Column(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ]),
    );
  }
}

class IslamicArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE1B55E).withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.5, -size.height * 0.8, size.width, size.height);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}