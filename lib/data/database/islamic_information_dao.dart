import 'package:sqflite/sqflite.dart';
import '../models/islamic_information.dart';
import 'database_helper.dart';

class IslamicInformationDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(IslamicInformation information) async {
    Database db = await dbHelper.database;
    return await db.insert('islamic_information', information.toMap());
  }

  Future<List<IslamicInformation>> getAllInformation() async {
    Database db = await dbHelper.database;
    var infos = await db.query('islamic_information', orderBy: 'title');

    return infos.map((info) => IslamicInformation.fromMap(info)).toList();
  }

  Future<List<IslamicInformation>> getInformationByCategory(
      String category) async {
    Database db = await dbHelper.database;
    var infos = await db.query('islamic_information',
        where: 'category = ?', whereArgs: [category], orderBy: 'title');

    return infos.map((info) => IslamicInformation.fromMap(info)).toList();
  }

  Future<IslamicInformation?> getInformationById(int id) async {
    Database db = await dbHelper.database;
    var infos = await db.query('islamic_information',
        where: 'id = ?', whereArgs: [id], limit: 1);

    if (infos.isNotEmpty) {
      return IslamicInformation.fromMap(infos.first);
    }

    return null;
  }

  Future<int> update(IslamicInformation information) async {
    Database db = await dbHelper.database;
    return await db.update('islamic_information', information.toMap(),
        where: 'id = ?', whereArgs: [information.id]);
  }

  Future<int> delete(int id) async {
    Database db = await dbHelper.database;
    return await db
        .delete('islamic_information', where: 'id = ?', whereArgs: [id]);
  }
}
