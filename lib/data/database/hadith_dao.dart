import 'package:sqflite/sqflite.dart';
import '../models/hadith.dart';
import 'database_helper.dart';

class HadithDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Hadith hadith) async {
    Database db = await dbHelper.database;
    return await db.insert('hadiths', hadith.toMap());
  }

  Future<List<Hadith>> getAllHadiths() async {
    Database db = await dbHelper.database;
    var hadiths = await db.query('hadiths');

    return hadiths.map((hadith) => Hadith.fromMap(hadith)).toList();
  }

  Future<List<Hadith>> searchHadiths(String keyword) async {
    Database db = await dbHelper.database;
    var hadiths = await db.query(
      'hadiths',
      where: 'content LIKE ? OR narrator LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );

    return hadiths.map((hadith) => Hadith.fromMap(hadith)).toList();
  }

  Future<List<Hadith>> getHadithsByBook(String book) async {
    Database db = await dbHelper.database;
    var hadiths = await db.query(
      'hadiths',
      where: 'book = ?',
      whereArgs: [book],
    );

    return hadiths.map((hadith) => Hadith.fromMap(hadith)).toList();
  }

  Future<Hadith?> getHadithById(int id) async {
    Database db = await dbHelper.database;
    var hadiths =
        await db.query('hadiths', where: 'id = ?', whereArgs: [id], limit: 1);

    if (hadiths.isNotEmpty) {
      return Hadith.fromMap(hadiths.first);
    }

    return null;
  }

  Future<int> update(Hadith hadith) async {
    Database db = await dbHelper.database;
    return await db.update('hadiths', hadith.toMap(),
        where: 'id = ?', whereArgs: [hadith.id]);
  }

  Future<int> delete(int id) async {
    Database db = await dbHelper.database;
    return await db.delete('hadiths', where: 'id = ?', whereArgs: [id]);
  }
}
