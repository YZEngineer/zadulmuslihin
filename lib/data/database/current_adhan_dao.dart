import '../models/current_location.dart';
import '../models/current_adhan.dart';
import '../models/adhan_time.dart';
import 'database.dart';
import 'database_helper.dart';
import 'adhan_times_dao.dart';
import 'current_location_dao.dart';

/// فئة للتعامل مع بيانات الصلاة الحالية في قاعدة البيانات
class CurrentAdhanDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableCurrentAdhan;
  final AdhanTimesDao _adhanTimesDao = AdhanTimesDao();
  final CurrentLocationDao _currentLocationDao = CurrentLocationDao();

  ///  final CurrentAdhan _currentAdhan = CurrentAdhan();

  /// تحديث بيانات الصلاة الحالية
  Future<int> ChangeCurrentAdhan(CurrentAdhan updatedAdhan) async {
    return await _databaseHelper
        .update(_tableName, updatedAdhan.toMap(), 'id = ?', [1]);
  }

  /// الحصول على بيانات الصلاة الحالية
  Future<List<CurrentAdhan>> getCurrentAdhan() async {
    try {
      final result = await _databaseHelper.query(_tableName);
      if (result.isEmpty) {
        // إذا كان الجدول فارغاً، نقوم بإصلاحه أولاً
        await fixEmptyCurrentAdhanTable();
        final newResult = await _databaseHelper.query(_tableName);
        return newResult.map((map) => CurrentAdhan.fromMap(map)).toList();
      }
      return result.map((map) => CurrentAdhan.fromMap(map)).toList();
    } catch (e) {
      print('خطأ في الحصول على بيانات الصلاة الحالية: $e');
      return [];
    }
  }

  /// إصلاح جدول الأذان الحالي إذا كان فارغاً
  Future<void> fixEmptyCurrentAdhanTable() async {
    try {
      final db = await _databaseHelper.database;
      int locationId = await _currentLocationDao.getCurrentLocationId();

      // الحصول على التاريخ الحالي
      final now = DateTime.now();
      final formattedDate = now.toIso8601String().split('T')[0];

      // إنشاء سجل جديد في جدول الأذان الحالي
      await db.insert(_tableName, {
        'id': 1,
        'location_id': locationId,
        'date': formattedDate,
        'fajr_time': '00:00',
        'sunrise_time': '00:00',
        'dhuhr_time': '00:00',
        'asr_time': '00:00',
        'maghrib_time': '00:00',
        'isha_time': '00:00',
      });

      print('تم إنشاء سجل جديد في جدول الأذان الحالي');
    } catch (e) {
      print('خطأ في إصلاح جدول الأذان الحالي: $e');
    }
  }

  Future<void> UpdateCurrentAdhan() async {
    try {
      int locationId = await _currentLocationDao.getCurrentLocationId();
      DateTime date = DateTime.now();

      AdhanTimes? adhanTimes =
          await _adhanTimesDao.getByDateAndLocation(date, locationId);

      // Si no hay datos de adhanTimes, no podemos continuar
      if (adhanTimes == null) {
        print(
            'لا توجد أوقات صلاة متاحة للتاريخ: ${date.toString()} والموقع: $locationId');
        return;
      }

      CurrentAdhan newCurrentAdhan = CurrentAdhan.fromMap(adhanTimes.toMap());
      newCurrentAdhan = newCurrentAdhan.copyWith(id: 1);

      /// نتأكد من أن المعرف هو 1   /// ممكن  حذفه
      await ChangeCurrentAdhan(newCurrentAdhan);
      print(
          'تم تحديث الأذان الحالي للموقع: $locationId والتاريخ: ${date.toString()}');
    } catch (e) {
      print('خطأ في تحديث الأذان الحالي: $e');
    }
  }

  /// الحصول على أوقات الأذان الحالية للموقع المحدد
  Future<AdhanTimes?> getCurrentAdhanTimes(int locationId) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        _tableName,
        where: 'location_id = ?',
        whereArgs: [locationId],
        limit: 1,
      );

      if (result.isEmpty) {
        // إذا لم يكن هناك سجل، حاول تحديثه أولاً
        await UpdateCurrentAdhan();

        // محاولة الحصول على السجل مرة أخرى
        final updatedResult = await db.query(
          _tableName,
          where: 'location_id = ?',
          whereArgs: [locationId],
          limit: 1,
        );

        if (updatedResult.isEmpty) {
          return null;
        }

        // تحويل السجل إلى كائن AdhanTimes
        return AdhanTimes(
          id: updatedResult.first['id'] as int?,
          locationId: updatedResult.first['location_id'] as int,
          date: DateTime.parse(updatedResult.first['date'] as String),
          fajrTime: updatedResult.first['fajr_time'] as String,
          sunriseTime: updatedResult.first['sunrise_time'] as String,
          dhuhrTime: updatedResult.first['dhuhr_time'] as String,
          asrTime: updatedResult.first['asr_time'] as String,
          maghribTime: updatedResult.first['maghrib_time'] as String,
          ishaTime: updatedResult.first['isha_time'] as String,
        );
      }

      // تحويل السجل إلى كائن AdhanTimes
      return AdhanTimes(
        id: result.first['id'] as int?,
        locationId: result.first['location_id'] as int,
        date: DateTime.parse(result.first['date'] as String),
        fajrTime: result.first['fajr_time'] as String,
        sunriseTime: result.first['sunrise_time'] as String,
        dhuhrTime: result.first['dhuhr_time'] as String,
        asrTime: result.first['asr_time'] as String,
        maghribTime: result.first['maghrib_time'] as String,
        ishaTime: result.first['isha_time'] as String,
      );
    } catch (e) {
      print('خطأ في الحصول على أوقات الأذان الحالية: $e');
      return null;
    }
  }
}
