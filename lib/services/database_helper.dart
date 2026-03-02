import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'quran_storage.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE quran_data(id INTEGER PRIMARY KEY, surahNum INTEGER, arabic TEXT, trans TEXT, globalAyahId INTEGER)",
        );
      },
    );
  }

  // Language update korle purono data muche notun data save hobe
  static Future<void> updateFullQuran(
    List<dynamic> arData,
    List<dynamic> trData,
  ) async {
    final dbClient = await db;
    await dbClient.delete('quran_data'); // Clear old data

    Batch batch = dbClient.batch();
    for (int s = 0; s < arData.length; s++) {
      var arAyahs = arData[s]['ayahs'];
      var trAyahs = trData[s]['ayahs'];
      for (int a = 0; a < arAyahs.length; a++) {
        batch.insert('quran_data', {
          'surahNum': s + 1,
          'arabic': arAyahs[a]['text'],
          'trans': trAyahs[a]['text'],
          'globalAyahId':
              arAyahs[a]['number'], // Audio play korar jonno global ID
        });
      }
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Map<String, dynamic>>> getSurahFromLocal(
    int surahNum,
  ) async {
    final dbClient = await db;
    return await dbClient.query(
      'quran_data',
      where: "surahNum = ?",
      whereArgs: [surahNum],
    );
  }
}
