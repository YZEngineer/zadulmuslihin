import 'package:sqflite/sqflite.dart';
import '../models/athkar.dart';
import 'database_helper.dart';

class AthkarDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Athkar athkar) async {
    Database db = await dbHelper.database;
    return await db.insert('athkar', athkar.toMap());
  }

  Future<List<Athkar>> getAllAthkar() async {
    Database db = await dbHelper.database;
    var athkarList = await db.query('athkar');

    return athkarList.map((athkar) => Athkar.fromMap(athkar)).toList();
  }

  Future<List<Athkar>> getAthkarByCategory(String category) async {
    Database db = await dbHelper.database;
    var athkarList = await db.query(
      'athkar',
      where: 'category = ?',
      whereArgs: [category],
    );

    return athkarList.map((athkar) => Athkar.fromMap(athkar)).toList();
  }

  Future<Athkar?> getAthkarById(int id) async {
    Database db = await dbHelper.database;
    var athkarList =
        await db.query('athkar', where: 'id = ?', whereArgs: [id], limit: 1);

    if (athkarList.isNotEmpty) {
      return Athkar.fromMap(athkarList.first);
    }

    return null;
  }

  Future<List<String>> getAllCategories() async {
    Database db = await dbHelper.database;
    var result = await db.rawQuery(
        'SELECT DISTINCT category FROM athkar WHERE category IS NOT NULL');

    return result.map((row) => row['category'] as String).toList();
  }

  Future<int> update(Athkar athkar) async {
    Database db = await dbHelper.database;
    return await db.update('athkar', athkar.toMap(),
        where: 'id = ?', whereArgs: [athkar.id]);
  }

  Future<int> delete(int id) async {
    Database db = await dbHelper.database;
    return await db.delete('athkar', where: 'id = ?', whereArgs: [id]);
  }
}
