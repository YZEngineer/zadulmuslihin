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
    return await _databaseHelper.delete(
      _tableName,
      'id = ?',
      [id],
    );
  }

  /// الحصول على موقع بواسطة المعرف
  Future<Location?> getLocationById(int id) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

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

  /// تعيين موقع كموقع حالي
  Future<int> setCurrentLocation(int id) async {
    // إلغاء تعيين الموقع الحالي السابق
    await _databaseHelper.update(
        _tableName, {'is_current': 0}, 'is_current = ?', [1]);

    // تعيين الموقع الجديد كموقع حالي
    return await _databaseHelper.update(
        _tableName, {'is_current': 1}, 'id = ?', [id]);
  }

  /// الحصول على المواقع حسب المدينة
  Future<List<Location>> getByCity(String city) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'city = ?',
      whereArgs: [city],
    );

    return result.map((map) => Location.fromMap(map)).toList();
  }

  /// الحصول على المواقع حسب الدولة
  Future<List<Location>> getByCountry(String country) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'country = ?',
      whereArgs: [country],
    );

    return result.map((map) => Location.fromMap(map)).toList();
  }

  /// الحصول على المواقع حسب طريقة الحساب
  Future<List<Location>> getByCalculationMethod(String method) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'calculation_method = ?',
      whereArgs: [method],
    );

    return result.map((map) => Location.fromMap(map)).toList();
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

  /// الحصول على المدن المتاحة
  Future<List<String>> getAvailableCities() async {
    final result = await _databaseHelper.rawQuery(
        'SELECT DISTINCT city FROM $_tableName WHERE city IS NOT NULL ORDER BY city ASC');

    return result.map((map) => map['city'] as String).toList();
  }

  /// الحصول على الدول المتاحة
  Future<List<String>> getAvailableCountries() async {
    final result = await _databaseHelper.rawQuery(
        'SELECT DISTINCT country FROM $_tableName WHERE country IS NOT NULL ORDER BY country ASC');

    return result.map((map) => map['country'] as String).toList();
  }
}
