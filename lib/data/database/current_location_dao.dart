import '../models/current_location.dart';
import 'database.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

/// فئة للتعامل مع بيانات الموقع الحالي في قاعدة البيانات
class CurrentLocationDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableCurrentLocation;

  /// إدراج أو تحديث بيانات الموقع الحالي
  Future<int> insertOrUpdate(CurrentLocation location) async {
    // التحقق من وجود سجل أولاً
    final existingRecords = await getAll();

    if (existingRecords.isEmpty) {
      // إدراج سجل جديد
      return await _databaseHelper.insert(_tableName, location.toMap());
    } else {
      // تحديث السجل القائم (نحتفظ بسجل واحد فقط)
      final existingId = existingRecords.first.id;

      // تهيئة بيانات محدثة بالمعرف الحالي
      Map<String, dynamic> updatedData = location.toMap();
      updatedData['id'] = existingId;

      return await _databaseHelper
          .update(_tableName, updatedData, 'id = ?', [existingId]);
    }
  }

  /// الحصول على بيانات الموقع الحالي
  Future<List<CurrentLocation>> getAll() async {
    final result = await _databaseHelper.query(_tableName);
    return result.map((map) => CurrentLocation.fromMap(map)).toList();
  }

  /// الحصول على الموقع الحالي إن وجد
  Future<CurrentLocation?> getCurrent() async {
    final records = await getAll();
    if (records.isEmpty) {
      return null;
    }
    return records.first;
  }

  /// تحديث المدينة والدولة
  Future<int> updateLocationDetails(int id, String city, String country) async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    return await _databaseHelper.update(
        _tableName,
        {'city': city, 'country': country, 'last_updated': formattedDate},
        'id = ?',
        [id]);
  }

  /// تحديث الإحداثيات
  Future<int> updateCoordinates(
      int id, double latitude, double longitude) async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    return await _databaseHelper.update(
        _tableName,
        {
          'latitude': latitude,
          'longitude': longitude,
          'last_updated': formattedDate
        },
        'id = ?',
        [id]);
  }

  /// حذف جميع السجلات
  Future<int> deleteAll() async {
    return await _databaseHelper.delete(_tableName, '', []);
  }
}
