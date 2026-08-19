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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_prayerTimes != null && mounted) {
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
        // debugPrint("Fajr: ${data.fajr}");
        // debugPrint("Sunrise: ${data.sunrise}");
        // debugPrint("Dhuhr: ${data.dhuhr}");
        // debugPrint("Asr: ${data.asr}");
        // debugPrint("Maghrib: ${data.maghrib}");
        // debugPrint("Isha: ${data.isha}");
      } else {
        setState(() {
          _prayerTimes = null;
        });
      }
    } catch (e) {
      // debugPrint("Error loading prayer times: $e");
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
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
                    color: const Color(0xFF81C784).withValues(alpha: 0.1),
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _fastCard("SEHRI ENDS", pt.fajr, Icons.wb_twilight),
                      const SizedBox(width: 12),
                      _fastCard("IFTAR STARTS", pt.maghrib, Icons.wb_sunny),
                    ],
                  ),
                  const SizedBox(height: 20),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF131B12)
                : const Color(0xFF243023),
            borderRadius: BorderRadius.circular(15),
            border: isSelected
                ? Border.all(color: const Color(0xFF81C784), width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF81C784), size: 24),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      child: Text(
                        name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white60,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat.jm().format(time),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
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
        height: 150,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF131B12) : const Color(0xFF243023),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: const Color(0xFF81C784), width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, color: const Color(0xFF81C784), size: 32),

            Column(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat.jm().format(time),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            Icon(
              isSelected ? Icons.star : Icons.star_border,
              color: isSelected ? const Color(0xFF81C784) : Colors.white24,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
