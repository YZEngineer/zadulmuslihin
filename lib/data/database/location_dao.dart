import '../models/location.dart';
import 'database.dart';
import 'database_helper.dart';

/// فئة للتعامل مع بيانات المواقع في قاعدة البيانات
class LocationDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableLocation;

  /// إدراج موقع جديد
  Future<int> insert(Location location) async {
    return await _databaseHelper.insert(_tableName, location.toMap());
  }

  /// تحديث موقع موجود
  Future<int> update(Location location) async {
    if (location.id == null) {
      throw ArgumentError('لا يمكن تحديث موقع بدون معرف');
    }
    return await _databaseHelper
        .update(_tableName, location.toMap(), 'id = ?', [location.id]);
  }

  /// حذف موقع بواسطة المعرف
  Future<int> delete(int id) async {
    return await _databaseHelper.delete(_tableName, 'id = ?', [id]);
  }

  /// الحصول على موقع بواسطة المعرف
  Future<Location?> getLocationById(int id) async {
    final result = await _databaseHelper
        .query(_tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) {
      return null;
    }

    return Location.fromMap(result.first);
  }

  /// الحصول على جميع المواقع
  Future<List<Location>> getAll() async {
    final result = await _databaseHelper.query(_tableName);
    return result.map((map) => Location.fromMap(map)).toList();
  }

  /// الحصول على الموقع الحالي
  Future<Location?> getCurrentLocation() async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'is_current = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Location.fromMap(result.first);
  }

  /// الحصول على عدد المواقع
  Future<int> getCount() async {
    final result = await _databaseHelper
        .rawQuery('SELECT COUNT(*) as count FROM $_tableName');

    return result.first['count'] as int;
  }

  /// البحث في المواقع
  Future<List<Location>> search(String keyword) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'name LIKE ? OR city LIKE ? OR country LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
    );

    return result.map((map) => Location.fromMap(map)).toList();
  }
}
