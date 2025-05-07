import '../models/current_location.dart';
import 'database.dart';
import 'database_helper.dart';

/// --------------------   need test ---------------------------


/// فئة للتعامل مع بيانات الموقع الحالي في قاعدة البيانات
class CurrentLocationDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableCurrentLocation;

  /// الحصول على بيانات الموقع الحالي
  Future<int> getCurrentLocationId() async {
    try {
      final result = await _databaseHelper.query(_tableName);
      CurrentLocation currentLocation = CurrentLocation.fromMap(result.first);
      return currentLocation.locationId;
    } catch (e) {
      print('خطأ في الحصول على بيانات الموقع الحالي: $e');
      return -1;    }
  }


  /// تحديث معرف الموقع المختار
  Future<int> updateLocationId(int newLocationId) async {
    try {      // تحديث السجل الموجود

      return await _databaseHelper.update(_tableName,
          {'location_id': newLocationId}, 'id = ?', [1]);///تجربة
    } catch (e) {
      print('خطأ في تحديث معرف الموقع: $e');return -1;}
  }
}
