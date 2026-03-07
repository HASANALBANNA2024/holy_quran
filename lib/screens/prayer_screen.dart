import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:holy_quran/logics/prayer_logic.dart';
import 'package:intl/intl.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  Timer? _timer;
  PrayerTimes? _prayerTimes;
  String _countdown = "00:00:00";

  String? selectedName;
  DateTime? selectedTime;

  @override
  void initState() {
    super.initState();
    _loadData();
    // ১ সেকেন্ড পর পর রিয়েল-টাইম কাউন্টডাউন আপডেট
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_prayerTimes != null) {
        _updateCounter();
      }
    });
  }

  void _updateCounter() {
    if (_prayerTimes == null) return;

    DateTime? target;
    if (selectedTime != null) {
      target = selectedTime;
    } else {
      final nextP = _prayerTimes!.nextPrayer();
      if (nextP == Prayer.none) {
        // ইশার পর নেক্সট প্রেয়ার হবে পরের দিনের ফজর
        target = _prayerTimes!.fajr.add(const Duration(days: 1));
      } else {
        target = _prayerTimes!.timeForPrayer(nextP);
      }
    }

    if (target != null) {
      setState(() {
        _countdown = PrayerLogic.getRemainingTime(target!);
      });
    }
  }

  Future<void> _loadData() async {
    try {
      final data = await PrayerLogic.getPrayerTimes();

      if (data != null) {
        setState(() {
          _prayerTimes = data;
        });
        _updateCounter();

        // ডিবাগ করার জন্য প্রিন্ট করুন
        print("🕐 Fajr: ${data.fajr}");
        print("🕐 Sunrise: ${data.sunrise}");
        print("🕐 Dhuhr: ${data.dhuhr}");
        print("🕐 Asr: ${data.asr}");
        print("🕐 Maghrib: ${data.maghrib}");
        print("🕐 Isha: ${data.isha}");
      } else {
        // ডাটা না পেলে লোডিং চালু রাখবেন না
        setState(() {
          _prayerTimes = null;
        });
      }
    } catch (e) {
      print("❌ Error loading prayer times: $e");
      // এরর হলে লোডিং বন্ধ করুন
      setState(() {
        _prayerTimes = null;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_prayerTimes == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFE8F5E9),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF81C784)),
        ),
      );
    }

    final pt = _prayerTimes!;

    // ওপরের ডিসপ্লে নাম ও সময়ের লজিক
    String displayName;
    DateTime displayTime;

    if (selectedName != null) {
      displayName = selectedName!;
      displayTime = selectedTime!;
    } else {
      final nextP = pt.nextPrayer();
      if (nextP == Prayer.none) {
        displayName = "FAJR";
        displayTime = pt.fajr.add(const Duration(days: 1));
      } else {
        displayName = nextP.name.toUpperCase();
        displayTime = pt.timeForPrayer(nextP) ?? pt.fajr;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1B241A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 40,
        title: const Text(
          "Daily Prayers",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white54, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          // ১. টপ সেকশন (গ্যাপ কম এবং ওভারল্যাপ প্রোটেকশনসহ)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 10,),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    DateFormat.jm().format(displayTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF81C784).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    selectedName == null
                        ? "NEXT IN: $_countdown"
                        : "REMAINING: $_countdown",
                    style: const TextStyle(
                      color: Color(0xFF81C784),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ২. নিচের স্ক্রলেবল সেকশন
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // সেহরি ও ইফতার কার্ড
                  Row(
                    children: [
                      _fastCard("SEHRI ENDS", pt.fajr, Icons.wb_twilight),
                      const SizedBox(width: 12),
                      _fastCard("IFTAR STARTS", pt.maghrib, Icons.wb_sunny),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // প্রেয়ার গ্রিড
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.85,
                    children: [
                      _prayerCard("FAJR", pt.fajr, Icons.wb_twilight),
                      _prayerCard(
                        "SUNRISE",
                        pt.sunrise,
                        Icons.wb_sunny_outlined,
                      ),
                      _prayerCard("DHUHR", pt.dhuhr, Icons.wb_cloudy_outlined),
                      _prayerCard("ASR", pt.asr, Icons.filter_list),
                      _prayerCard("MAGHRIB", pt.maghrib, Icons.eco_outlined),
                      _prayerCard("ISHA", pt.isha, Icons.nightlight_round),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fastCard(String name, DateTime time, IconData icon) {
    bool isSelected = selectedName == name;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedName = null;
              selectedTime = null;
            } else {
              selectedName = name;
              selectedTime = time;
            }
          });
          _updateCounter();
        },
        child: Container(
          // প্যাডিং ১২ থেকে বাড়িয়ে ১৬ করা হয়েছে যাতে হাইট বাড়ে
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF131B12)
                : const Color(0xFF243023),
            borderRadius: BorderRadius.circular(15), // একটু বেশি রাউন্ড করা হয়েছে
            border: isSelected
                ? Border.all(color: const Color(0xFF81C784), width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              // আইকন সাইজ ২০ থেকে বাড়িয়ে ২৪ করা হয়েছে
              Icon(icon, color: const Color(0xFF81C784), size: 24),
              const SizedBox(width: 10), // গ্যাপ কিছুটা বাড়ানো হয়েছে
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // কলামটিকে মাঝখানে রাখার জন্য
                  children: [
                    FittedBox(
                      child: Text(
                        name,
                        style: TextStyle(
                          // isSelected হলে টেক্সট উজ্জ্বল দেখাবে
                          color: isSelected ? Colors.white : Colors.white60,
                          fontSize: 11, // ৯ থেকে বাড়িয়ে ১১ করা হয়েছে
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2), // টেক্সট দুটির মাঝে গ্যাপ
                    Text(
                      DateFormat.jm().format(time),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14, // ১২ থেকে বাড়িয়ে ১৪ করা হয়েছে
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
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

  Widget _prayerCard(String name, DateTime time, IconData icon) {
    bool isSelected = selectedName == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedName = null;
            selectedTime = null;
          } else {
            selectedName = name;
            selectedTime = time;
          }
        });
        _updateCounter();
      },
      child: Container(
        // এখানে height এবং width সেট করে কার্ডের সাইজ নিয়ন্ত্রণ করা হয়েছে
        height: 150, // আপনি চাইলে এটি বাড়িয়ে ১৪০ বা ১৫০ করতে পারেন
        padding: const EdgeInsets.symmetric(vertical: 10), // ভেতরের স্পেসের জন্য
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF131B12) : const Color(0xFF243023),
          borderRadius: BorderRadius.circular(20), // কোণাগুলো একটু বেশি রাউন্ড করলাম
          border: isSelected
              ? Border.all(color: const Color(0xFF81C784), width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // ইলিমেন্টগুলোকে সমান দূরত্বে রাখবে
          children: [
            // আইকন সাইজ ২৬ থেকে বাড়িয়ে ৩২ করা হয়েছে
            Icon(icon, color: const Color(0xFF81C784), size: 32),

            Column(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 14, // ১১ থেকে বাড়িয়ে ১৪ করা হয়েছে
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat.jm().format(time),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13, // ১০ থেকে বাড়িয়ে ১৩ করা হয়েছে
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            // নিচের স্টার আইকনটি একটু বড় করা হয়েছে
            Icon(
              isSelected ? Icons.star : Icons.star_border,
              color: isSelected ? const Color(0xFF81C784) : Colors.white24,
              size: 20, // ১৬ থেকে বাড়িয়ে ২০ করা হয়েছে
            ),
          ],
        ),
      ),
    );
  }
}
