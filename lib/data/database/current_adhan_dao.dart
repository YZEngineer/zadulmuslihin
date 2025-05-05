import 'package:zadulmuslihin/data/models/current_location.dart';

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

  /// التحقق من صحة هيكل جدول الأذان الحالي
  Future<bool> isCurrentAdhanTableValid() async {
    try {
      final db = await _databaseHelper.database;
      final columns = await db.rawQuery("PRAGMA table_info(${_tableName})");

      // التحقق من وجود جميع الأعمدة المطلوبة
      bool hasId = false;
      bool hasLocationId = false;
      bool hasDate = false;
      bool hasFajrTime = false;
      bool hasSunriseTime = false;
      bool hasDhuhrTime = false;
      bool hasAsrTime = false;
      bool hasMaghribTime = false;
      bool hasIshaTime = false;

      for (var column in columns) {
        String name = column['name'] as String;
        if (name == 'id') hasId = true;
        if (name == 'location_id') hasLocationId = true;
        if (name == 'date') hasDate = true;
        if (name == 'fajr_time') hasFajrTime = true;
        if (name == 'sunrise_time') hasSunriseTime = true;
        if (name == 'dhuhr_time') hasDhuhrTime = true;
        if (name == 'asr_time') hasAsrTime = true;
        if (name == 'maghrib_time') hasMaghribTime = true;
        if (name == 'isha_time') hasIshaTime = true;
      }

      // يجب أن تكون جميع الأعمدة موجودة
      return hasId &&
          hasLocationId &&
          hasDate &&
          hasFajrTime &&
          hasSunriseTime &&
          hasDhuhrTime &&
          hasAsrTime &&
          hasMaghribTime &&
          hasIshaTime;
    } catch (e) {
      print('خطأ في التحقق من صحة هيكل جدول الأذان الحالي: $e');
      return false;
    }
  }

  /// إعادة إنشاء جدول الأذان الحالي بهيكله الصحيح
  Future<bool> recreateCurrentAdhanTable() async {
    try {
      final db = await _databaseHelper.database;

      // حذف الجدول الحالي إذا كان موجودًا
      await db.execute("DROP TABLE IF EXISTS ${_tableName}");

      // إنشاء الجدول من جديد
      await db.execute('''
        CREATE TABLE ${_tableName} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          location_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          fajr_time TEXT NOT NULL DEFAULT '00:00',
          sunrise_time TEXT NOT NULL DEFAULT '00:00',
          dhuhr_time TEXT NOT NULL DEFAULT '00:00',
          asr_time TEXT NOT NULL DEFAULT '00:00',
          maghrib_time TEXT NOT NULL DEFAULT '00:00',
          isha_time TEXT NOT NULL DEFAULT '00:00',
          FOREIGN KEY (location_id) REFERENCES ${AppDatabase.tableLocation} (id)
        )
      ''');

      print('تم إعادة إنشاء جدول الأذان الحالي بنجاح');
      return true;
    } catch (e) {
      print('خطأ في إعادة إنشاء جدول الأذان الحالي: $e');
      return false;
    }
  }

  /// إصلاح جدول الأذان الحالي إذا كان فارغاً
  Future<void> fixEmptyCurrentAdhanTable() async {
    try {
      // التحقق من صحة هيكل الجدول
      bool isValid = await isCurrentAdhanTableValid();

      if (!isValid) {
        print('هيكل جدول الأذان الحالي غير صحيح، سيتم إعادة إنشائه');
        await recreateCurrentAdhanTable();
      }

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
      List<CurrentAdhan> currentAdhanList = await getCurrentAdhan();

      // إذا كان الجدول فارغاً بعد محاولة الإصلاح، نقوم بالخروج
      if (currentAdhanList.isEmpty) {
        print('لا يمكن تحديث الأذان الحالي: الجدول فارغ رغم محاولة الإصلاح');
        return;
      }

      int locationId = await _currentLocationDao.getCurrentLocationId();
      DateTime date = DateTime.now();
      CurrentAdhan currentAdhan = currentAdhanList.first;

      if (currentAdhan.locationId == locationId ) {
        AdhanTimes adhanTimes =await _adhanTimesDao.getByDateAndLocation(date, locationId);
        CurrentAdhan newCurrentAdhan = CurrentAdhan.fromMap(adhanTimes.toMap());
        newCurrentAdhan =newCurrentAdhan.copyWith(id: 1); // نتأكد من أن المعرف هو 1
        await ChangeCurrentAdhan(newCurrentAdhan);
        print('تم تحديث الأذان الحالي للموقع: $locationId والتاريخ: ${date.toString()}');
      }
    } catch (e) {
      print('خطأ في تحديث الأذان الحالي: $e');
    }
  }
}
