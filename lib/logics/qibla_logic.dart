import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

class QiblaLogic {
  // মক্কা (কাবা) এর স্থানাঙ্ক
  static const double _makkahLat = 21.4225;
  static const double _makkahLon = 39.8262;

  /// কিবলা দিক নির্ণয় (ডিগ্রীতে)
  static double calculateQiblaDirection(double lat, double lon) {
    // ডিগ্রী থেকে রেডিয়ানে রূপান্তর
    double lat1 = lat * math.pi / 180;
    double lon1 = lon * math.pi / 180;
    double lat2 = _makkahLat * math.pi / 180;
    double lon2 = _makkahLon * math.pi / 180;

    // কিবলা দিক নির্ণয়ের ফর্মুলা
    double x = math.sin(lon2 - lon1) * math.cos(lat2);
    double y = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(lon2 - lon1);

    double qibla = math.atan2(x, y) * 180 / math.pi;

    // ডিগ্রী ০-৩৬০ এর মধ্যে নেওয়া
    qibla = (qibla + 360) % 360;

    return qibla;
  }

  /// বর্তমান অবস্থান থেকে কিবলা দিক নির্ণয়
  static Future<Map<String, dynamic>> getQiblaDirection() async {
    try {
      // লোকেশন সার্ভিস চেক
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          'success': false,
          'error': 'Location services are disabled. Please enable GPS.',
        };
      }

      // পারমিশন চেক
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {
            'success': false,
            'error': 'Location permission denied.',
          };
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {
          'success': false,
          'error': 'Location permissions are permanently denied.',
        };
      }

      // বর্তমান অবস্থান নেওয়া
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // কিবলা দিক নির্ণয়
      double qibla = calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );

      return {
        'success': true,
        'qibla': qibla,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'directionName': _getDirectionName(qibla),
      };

    } catch (e) {
      return {
        'success': false,
        'error': 'Error getting location: $e',
      };
    }
  }

  /// দিকের নাম নির্ণয়
  static String _getDirectionName(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return "উত্তর";
    if (degrees >= 22.5 && degrees < 67.5) return "উত্তর-পূর্ব";
    if (degrees >= 67.5 && degrees < 112.5) return "পূর্ব";
    if (degrees >= 112.5 && degrees < 157.5) return "দক্ষিণ-পূর্ব";
    if (degrees >= 157.5 && degrees < 202.5) return "দক্ষিণ";
    if (degrees >= 202.5 && degrees < 247.5) return "দক্ষিণ-পশ্চিম";
    if (degrees >= 247.5 && degrees < 292.5) return "পশ্চিম";
    if (degrees >= 292.5 && degrees < 337.5) return "উত্তর-পশ্চিম";
    return "";
  }

  /// দুই দিকের মধ্যে পার্থক্য নির্ণয়
  static double getAngleDifference(double qibla, double heading) {
    double diff = (qibla - heading + 360) % 360;
    if (diff > 180) diff = 360 - diff;
    return diff;
  }
}