import 'package:flutter/material.dart';
import 'package:holy_quran/screens/donation_screen.dart';

void showSadakahOverlay(BuildContext context, String currentLang, List<dynamic> translations) {
  // ১. ইউজার কিছু সিলেক্ট না করলে ডিফল্ট 'en', আর থাকলে সেটাই হবে
  String lang = (currentLang == null || currentLang.isEmpty) ? "en" : currentLang;

  String ayatTranslation = "";

  // ল্যাঙ্গুয়েজ অনুযায়ী টাইটেল ও বাটনের টেক্সট
  String title = lang == "bn" ? "সর্বোত্তম সাদাকাহ" : "Best Charity";
  String btnText = lang == "bn" ? "সাদাকাহ করুন" : "DONATE NOW";
  String skipText = lang == "bn" ? "পরে করবো" : "Maybe Later";

  try {
    // আপনার QuranProvider এর স্ট্রাকচার অনুযায়ী:
    // translations[1] -> সুরা বাকারা
    // ['ayahs'][260] -> ২৬১ নম্বর আয়াত
    ayatTranslation = translations[1]['ayahs'][260]['text'];
  } catch (e) {
    // ডাটা লোড না হলে ব্যাকআপ টেক্সট (ইউজারের ভাষা অনুযায়ী)
    ayatTranslation = lang == "bn"
        ? "যারা আল্লাহর রাস্তায় নিজেদের সম্পদ ব্যয় করে, তাদের উপমা একটি বীজের মতো, যা থেকে সাতটি শীষ জন্মায় এবং প্রতিটি শীষে থাকে ১০০টি দানা।"
        : "The example of those who spend their wealth in the way of Allah is like a seed [of grain] which grows seven spikes; in each spike is a hundred grains.";
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [Color(0xFF004D40), Color(0xFF00695C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.amber.shade300, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // টপ ডিজাইন (গাছ আইকন)
            Container(
              height: 90,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22), topRight: Radius.circular(22)),
              ),
              child: const Icon(Icons.park_rounded, size: 55, color: Colors.amber),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                      title,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          letterSpacing: 1.1
                      )
                  ),
                  const SizedBox(height: 15),
                  // আয়াতের টেক্সট এরিয়া
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      ayatTranslation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          height: 1.5,
                          fontStyle: FontStyle.italic
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Donate Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // পেমেন্ট গেটওয়ে লজিক এখানে হবে
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DonationScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: const Color(0xFF004D40),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    child: Text(
                        btnText,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                  ),

                  // Skip Button
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                      // call to donation
                    },
                    child: Text(
                        skipText,
                        style: const TextStyle(color: Colors.white70, fontSize: 13)
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}