import 'package:sqflite/sqflite.dart';
import '../models/daily_prayers.dart';
import 'database_helper.dart';

class DailyPrayerDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(DailyPrayer prayer) async {
    Database db = await dbHelper.database;
    return await db.insert('daily_prayers', prayer.toMap());
  }

  Future<List<DailyPrayer>> getAllPrayers() async {
    Database db = await dbHelper.database;
    var prayers = await db.query('daily_prayers');

    return prayers.map((prayer) => DailyPrayer.fromMap(prayer)).toList();
  }

  Future<List<DailyPrayer>> getPrayersByOccasion(String occasion) async {
    Database db = await dbHelper.database;
    var prayers = await db.query(
      'daily_prayers',
      where: 'occasion = ?',
      whereArgs: [occasion],
    );

    return prayers.map((prayer) => DailyPrayer.fromMap(prayer)).toList();
  }

  Future<DailyPrayer?> getPrayerById(int id) async {
    Database db = await dbHelper.database;
    var prayers = await db.query('daily_prayers',
        where: 'id = ?', whereArgs: [id], limit: 1);

    if (prayers.isNotEmpty) {
      return DailyPrayer.fromMap(prayers.first);
    }

    return null;
  }

  Future<List<String>> getAllOccasions() async {
    Database db = await dbHelper.database;
    var result = await db.rawQuery(
        'SELECT DISTINCT occasion FROM daily_prayers WHERE occasion IS NOT NULL');

    return result.map((row) => row['occasion'] as String).toList();
  }

  Future<int> update(DailyPrayer prayer) async {
    Database db = await dbHelper.database;
    return await db.update('daily_prayers', prayer.toMap(),
        where: 'id = ?', whereArgs: [prayer.id]);
  }

  Future<int> delete(int id) async {
    Database db = await dbHelper.database;
    return await db.delete('daily_prayers', where: 'id = ?', whereArgs: [id]);
  }
}
