import 'package:sqflite/sqflite.dart';
import '../models/current_location.dart';
import '../models/location.dart';
import 'database_helper.dart';
import 'location_dao.dart';

class CurrentLocationDao {
  final dbHelper = DatabaseHelper.instance;
  final locationDao = LocationDao();

  /// تعيين الموقع الحالي
  Future<void> setCurrentLocation(int locationId) async {
    Database db = await dbHelper.database;

    // التحقق من وجود السجل
    var count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM current_location'));

    CurrentLocation currentLocation = CurrentLocation(locationId: locationId);

    if (count != null && count > 0) {
      // تحديث السجل الموجود
      await db.update(
        'current_location',
        currentLocation.toMap(),
        where: 'id = 1',
      );
    } else {
      // إدراج سجل جديد
      await db.insert('current_location', currentLocation.toMap());
    }
  }

  /// الحصول على معرف الموقع الحالي
  Future<int?> getCurrentLocationId() async {
    Database db = await dbHelper.database;
    var results = await db.query(
      'current_location',
      where: 'id = 1',
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    CurrentLocation currentLocation = CurrentLocation.fromMap(results.first);
    return currentLocation.locationId;
  }

  /// الحصول على الموقع الحالي
  Future<Location?> getCurrentLocation() async {
    int? locationId = await getCurrentLocationId();

    if (locationId == null) {
      return null;
    }

    return await locationDao.getLocationById(locationId);
  }
}
