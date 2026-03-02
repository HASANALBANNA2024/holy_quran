import 'dart:convert';

import 'package:holy_quran/services/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QuranSync {
  static Future<bool> syncQuran(String edition) async {
    try {
      final url = "https://api.alquran.cloud/v1/quran/quran-uthmani,$edition";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body)['data'];
        await DatabaseHelper.updateFullQuran(
          data[0]['surahs'],
          data[1]['surahs'],
        );

        // Save kora holo je download complete
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDownloaded', true);
        await prefs.setString('currentLang', edition);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
