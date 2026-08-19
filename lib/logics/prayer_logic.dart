import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PrayerLogic {
  static Future<PrayerTimes?> getPrayerTimes() async {
    try {
      /// permission check
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // debugPrint("Location service is disabled");

        /// if location service of then location track to dhaka
        return _getDefaultDhakaTime();
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // debugPrint("Location permission denied");
          return _getDefaultDhakaTime();
        }
      }
      if (permission == LocationPermission.deniedForever) {
        // debugPrint(" Location permission permanently denied");
        return _getDefaultDhakaTime();
      }

      /// location with timeout
      Position position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 5),
            ),
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint("📍 Location timeout - using default");
              throw TimeoutException('Location timeout');
            },
          );

      debugPrint("📍 Location: ${position.latitude}, ${position.longitude}");

      final coordinates = Coordinates(position.latitude, position.longitude);

      /// bangladesh and asia
      final params = CalculationMethod.karachi.getParameters();
      params.madhab = Madhab.hanafi;

      params.adjustments = PrayerAdjustments(
        fajr: 4,
        sunrise: 0,
        dhuhr: 0,
        asr: 0,
        maghrib: 2,
        isha: 4,
      );

      return PrayerTimes.today(coordinates, params);
    } catch (e) {
      // debugPrint("Error getting prayer times:$e");
      return _getDefaultDhakaTime();
    }
  }

  static PrayerTimes _getDefaultDhakaTime() {
    // debugPrint("Using default Dhaka time");
    final dhaka = Coordinates(23.8103, 90.4125);
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;

    return PrayerTimes.today(dhaka, params);
  }

  static String getRemainingTime(DateTime targetTime) {
    DateTime now = DateTime.now();

    if (targetTime.isBefore(now)) {
      targetTime = targetTime.add(const Duration(days: 1));
    }

    final remaining = targetTime.difference(now);

    if (remaining.isNegative) {
      return "00:00:00";
    }

    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');

    return "$hours:$minutes:$seconds";
  }
}
