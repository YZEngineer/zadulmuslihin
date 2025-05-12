import '../models/current_location.dart';
import 'database_helper.dart';

/// فئة للتعامل مع بيانات الموقع الحالي في قاعدة البيانات
class CurrentLocationDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final String _tableLocations = 'locations';
  final String _tableCurrentLocation = 'current_location';

  /// الحصول على معرف الموقع الحالي المختار
  Future<int> getCurrentLocationId() async {
    final result = await _databaseHelper.query(_tableCurrentLocation);
    if (result.isEmpty) {
      throw Exception('لم يتم العثور على موقع حالي');
    }
    return result.first['location_id'] as int;
  }

  /// الحصول على معلومات الموقع الحالي المختار
  Future<CurrentLocation> getCurrentLocation() async {
    try {
      final locationId = await getCurrentLocationId();

      final result = await _databaseHelper.query(
        _tableLocations,
        where: 'location_id = ?',
        whereArgs: [locationId],
      );

      if (result.isEmpty) {
        throw Exception('لم يتم العثور على معلومات الموقع');
      }

      return CurrentLocation.fromMap({
        'location_id': locationId,
        'city': result.first['city'],
        'country': result.first['country'],
        'latitude': result.first['latitude'],
        'longitude': result.first['longitude'],
        'timezone': result.first['timezone'],
        'madhab': result.first['madhab'],
        'method_id': result.first['method_id'],
      });
    } catch (e) {
      // إنشاء موقع افتراضي إذا لم يتم العثور على موقع
      return await _createDefaultLocation();
    }
  }

  /// إنشاء موقع افتراضي (مكة المكرمة)
  Future<CurrentLocation> _createDefaultLocation() async {
    final defaultLocation = {
      'latitude': 21.3891,
      'longitude': 39.8579,
      'city': 'مكة المكرمة',
      'country': 'المملكة العربية السعودية',
      'timezone': 'Asia/Riyadh',
      'madhab': 'شافعي',
      'method_id': 4 // طريقة أم القرى
    };

    final db = await _databaseHelper.database;
    final locationId = await db.insert(_tableLocations, defaultLocation);

    await db.insert(_tableCurrentLocation, {'location_id': locationId});

    return CurrentLocation.fromMap({
      'location_id': locationId,
      ...defaultLocation,
    });
  }

  /// تحديث معلومات الموقع الحالي
  Future<int> updateCurrentLocation(CurrentLocation location) async {
    try {
      final currentLocationId = await getCurrentLocationId();

      if (location.locationId != null &&
          location.locationId != currentLocationId) {
        // إذا تم تغيير الموقع إلى موقع آخر موجود
        return await _databaseHelper.update(
            _tableCurrentLocation,
            {'location_id': location.locationId},
            'location_id = ?',
            [currentLocationId]);
      } else {
        // تحديث بيانات الموقع الحالي
        final dataToUpdate = {
          'city': location.city,
          'country': location.country,
          'latitude': location.latitude,
          'longitude': location.longitude,
          'timezone': location.timezone,
          'madhab': location.madhab,
          'method_id': location.methodId,
        };

        return await _databaseHelper.update(_tableLocations, dataToUpdate,
            'location_id = ?', [currentLocationId]);
      }
    } catch (e) {
      throw Exception('خطأ في تحديث الموقع: $e');
    }
  }

  /// إدراج موقع جديد وتعيينه كموقع حالي
  Future<int> insertCurrentLocation(CurrentLocation location) async {
    final db = await _databaseHelper.database;

    // إدراج الموقع الجديد في جدول المواقع
    final locationData = {
      'city': location.city,
      'country': location.country,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'timezone': location.timezone ?? 'Asia/Riyadh',
      'madhab': location.madhab ?? 'شافعي',
      'method_id': location.methodId ?? 4,
    };

    final newLocationId = await db.insert(_tableLocations, locationData);

    // التحقق من وجود سجل في جدول الموقع الحالي
    final currentLocationResult =
        await _databaseHelper.query(_tableCurrentLocation);

    if (currentLocationResult.isEmpty) {
      // إدراج سجل جديد
      await db.insert(_tableCurrentLocation, {'location_id': newLocationId});
    } else {
      // تحديث السجل الموجود
      await db.update(_tableCurrentLocation, {'location_id': newLocationId},
          where: '1 = 1');
    }

    return newLocationId;
  }

  /// احصل على جميع المواقع المخزنة
  Future<List<CurrentLocation>> getAllLocations() async {
    final result = await _databaseHelper.query(_tableLocations);

    return result
        .map((map) => CurrentLocation.fromMap({
              'location_id': map['location_id'],
              'city': map['city'],
              'country': map['country'],
              'latitude': map['latitude'],
              'longitude': map['longitude'],
              'timezone': map['timezone'],
              'madhab': map['madhab'],
              'method_id': map['method_id'],
            }))
        .toList();
  }
}
