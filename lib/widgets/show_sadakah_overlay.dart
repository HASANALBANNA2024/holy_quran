import 'package:flutter/material.dart';
import 'package:holy_quran/screens/donation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showSadakahOverlay(BuildContext context, String currentLang, List<dynamic> translations) {
  String lang = (currentLang == null || currentLang.isEmpty) ? "en" : currentLang;
  String ayatTranslation = "";

  String title = lang == "bn" ? "সাদাকাহ জারিয়া" : "Sadaqah Jariyah";
  String btnText = lang == "bn" ? "দান করুন" : "DONATE";
  String skipText = lang == "bn" ? "পরে" : "LATER";
  String refText = lang == "bn" ? "বাক্বারাহ: ২৬১" : "Baqarah: 261";

  try {
    ayatTranslation = translations[1]['ayahs'][260]['text'];
  } catch (e) {
    ayatTranslation = lang == "bn"
        ? "দান করা যেন একটি বীজ, যা থেকে সাতটি শীষ জন্মায়..."
        : "Charity is like a seed that grows seven spikes...";
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        // কার্ডের হাইট কন্ট্রোল করতে constraints ব্যবহার করা হয়েছে
        constraints: const BoxConstraints(maxHeight: 450),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [Color(0xFF004D40), Color(0xFF002924)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
        ),
        child: Stack(
          children: [
            // ১. ব্যাকগ্রাউন্ড ওয়াটারমার্ক থিম (গাছের আইকনগুলো ব্যাকগ্রাউন্ডে থাকবে)
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(Icons.park_rounded, size: 200, color: Colors.white.withOpacity(0.05)),
            ),
            Positioned(
              left: -10,
              top: 20,
              child: Icon(Icons.spa, size: 100, color: Colors.white.withOpacity(0.03)),
            ),

            // ২. মেইন কন্টেন্ট
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // হাইট ছোট রাখার জন্য
                children: [
                  // ছোট আইকন উপরে
                  const Icon(Icons.volunteer_activism, color: Colors.amber, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                        letterSpacing: 1.2
                    ),
                  ),
                  const SizedBox(height: 20),

                  // আয়াত বক্স
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            ayatTranslation,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            refText,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade200,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ৩. বাটন রো (Donate আগে, Later পরে)
                  Row(
                    children: [
                      // Donate Button (বামে)
                      Expanded(
                        flex: 1, // আগে ২ ছিল, এখন ১ করাতে দুই বাটন সমান সাইজ হবে
                        child: ElevatedButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            // Ajker date save kora (21 din porer jonno)
                            await prefs.setString('last_sadakah_action', DateTime.now().toString());
                            await prefs.setInt('next_show_days', 20);

                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => DonationScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: const Color(0xFF004D40),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                          ),
                          child: Text(
                            btnText,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1, // লেখা বড় হলে যেন ভেঙে না যায়
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Maybe Later Button (ডানে)
                      Expanded(
                        flex: 1, // সমান সাইজ রাখার জন্য ১
                        child: TextButton(
                          onPressed: () async{
                            final prefs = await SharedPreferences.getInstance();
                            // Ajker date save kora (7 din porer jonno)
                            await prefs.setString('last_sadakah_action', DateTime.now().toString());
                            await prefs.setInt('next_show_days', 5);

                            Navigator.pop(context);

                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.white.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: const BorderSide(color: Colors.white24)
                            ),
                          ),
                          child: Text(
                            skipText,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}