import '../models/current_location.dart';
import 'database.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

/// فئة للتعامل مع بيانات الموقع الحالي في قاعدة البيانات
class CurrentLocationDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableCurrentLocation;

  /// الحصول على بيانات الموقع الحالي
  Future<List<CurrentLocation>> getAll() async {
    try {
      final result = await _databaseHelper.query(_tableName);
      return result.map((map) => CurrentLocation.fromMap(map)).toList();
    } catch (e) {
      print('خطأ في الحصول على بيانات الموقع الحالي: $e');
      return [];
    }
  }

  Future<int> getCurrentLocationId() async {
    final records = await getAll();
    if (records.isEmpty) {
      print('لم يتم العثور على سجل موقع حالي، وهذا غير متوقع');
      return -1;
    }
    return records.first.locationId;
  }

  /// الحصول على الموقع الحالي
  Future<CurrentLocation?> getCurrentLocation() async {
    try {
      final records = await getAll();
      if (records.isEmpty) {
        print('لم يتم العثور على سجل موقع حالي، وهذا غير متوقع');
        return null;
      }
      return records.first;
    } catch (e) {
      print('خطأ في الحصول على الموقع الحالي: $e');
      return null;
    }
  }

  /// تحديث معرف الموقع المختار
  Future<int> updateLocationId(int newLocationId) async {
    try {
      // التحقق أولاً من وجود الموقع المطلوب في جدول المواقع
      final locationsTable = AppDatabase.tableLocation;
      final locationResult = await _databaseHelper.query(
        locationsTable,
        where: 'id = ?',
        whereArgs: [newLocationId],
      );

      if (locationResult.isEmpty) {
        print('الموقع رقم $newLocationId غير موجود في جدول المواقع');
        return -1;
      }

      // الحصول على سجل الموقع الحالي
      final records = await getAll();
      if (records.isEmpty) {
        print('لم يتم العثور على سجل الموقع الحالي، وهذا غير متوقع');
        return -1;
      }

      // تحديث السجل الموجود
      return await _databaseHelper.update(_tableName,
          {'location_id': newLocationId}, 'id = ?', [records.first.id]);
    } catch (e) {
      print('خطأ في تحديث معرف الموقع: $e');
      return -1;
    }
  }
}
