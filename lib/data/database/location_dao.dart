import 'package:sqflite/sqflite.dart';
import '../models/location.dart';
import 'database_helper.dart';

class LocationDao {
  final dbHelper = DatabaseHelper.instance;

  /// إدراج موقع جديد
  Future<int> insert(Location location) async {
    Database db = await dbHelper.database;
    return await db.insert('locations', location.toMap());
  }

  /// تحديث موقع موجود
  Future<int> update(Location location) async {
    if (location.id == null) {
      throw ArgumentError('لا يمكن تحديث الموقع بدون معرف');
    }

    Database db = await dbHelper.database;
    return await db.update(
      'locations',
      location.toMap(),
      where: 'id = ?',
      whereArgs: [location.id],
    );
  }

  /// الحصول على موقع حسب المعرف
  Future<Location?> getLocationById(int id) async {
    Database db = await dbHelper.database;
    var results = await db.query(
      'locations',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return Location.fromMap(results.first);
  }

  /// الحصول على جميع المواقع المخزنة
  Future<List<Location>> getAllLocations() async {
    Database db = await dbHelper.database;
    var results = await db.query('locations', orderBy: 'name ASC');

    return results.map((map) => Location.fromMap(map)).toList();
  }

  /// البحث عن موقع حسب الاسم
  Future<List<Location>> searchLocationsByName(String query) async {
    Database db = await dbHelper.database;
    var results = await db.query(
      'locations',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );

    return results.map((map) => Location.fromMap(map)).toList();
  }

  /// حذف موقع حسب المعرف
  Future<int> deleteLocationById(int id) async {
    Database db = await dbHelper.database;
    return await db.delete(
      'locations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// حذف جميع المواقع
  Future<int> deleteAllLocations() async {
    Database db = await dbHelper.database;
    return await db.delete('locations');
  }
}
