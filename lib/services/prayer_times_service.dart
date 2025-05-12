import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:zadulmuslihin/data/database/location_dao.dart';
import '../data/database/adhan_times_dao.dart';
import '../data/models/adhan_time.dart';
import '../data/database/current_location_dao.dart';
import '../data/database/database_helper.dart';
import '../data/database/database.dart';
import '../core/functions/utils.dart';
import 'package:sqflite/sqflite.dart';

/// خدمة للحصول على أوقات الصلاة من واجهة برمجة التطبيقات
class PrayerTimesService {
  static final PrayerTimesService _instance = PrayerTimesService._internal();
  final AdhanTimesDao _adhanTimesDao = AdhanTimesDao();
  final CurrentLocationDao _currentLocationDao = CurrentLocationDao();
  final LocationDao _locationDao = LocationDao();
  bool _isRefreshing = false;

  factory PrayerTimesService() {
    return _instance;
  }
  PrayerTimesService._internal();

  /// الحصول على أوقات الصلاة من الخدمة الخارجية
  Future<bool> fetchAndStorePrayerTimes(
      {DateTime? date, int? locationId, bool forceUpdate = false}) async {
    try {
      // استخدام التاريخ الحالي إذا لم يتم تحديد تاريخ
      final targetDate = date ?? DateTime.now();

      // الحصول على معرف الموقع الحالي إذا لم يتم تحديد موقع
      final targetLocationId =
          locationId ?? await _currentLocationDao.getCurrentLocationId();

      // التحقق أولاً من وجود البيانات في قاعدة البيانات
      // إلا إذا كان هناك طلب للتحديث القسري
      if (!forceUpdate) {
        final existingData = await _adhanTimesDao.getByDateAndLocation(
          targetDate,
          targetLocationId,
        );

        // إذا كانت البيانات موجودة بالفعل، نعود بنجاح
        if (existingData != null) {
          print(
              'أوقات الصلاة موجودة بالفعل لتاريخ ${DateFormat('yyyy-MM-dd').format(targetDate)} وموقع $targetLocationId');
          return true;
        }
      }

      // الحصول على بيانات الموقع
      final locationData = await _locationDao.getLocationById(targetLocationId);
      final latitude = locationData?.latitude;
      final longitude = locationData?.longitude;
      final method = locationData?.methodId;
      print('latitude: $latitude');
      print('longitude: $longitude');
      print('method: $method');
      print('targetLocationId: $targetLocationId');
      print('targetDate: $targetDate');
      // تنسيق التاريخ للاستخدام في طلب API
      final formattedDate = DateFormat('dd-MM-yyyy').format(targetDate);

      // إنشاء عنوان URL للطلب
      final url = Uri.parse(
          'https://api.aladhan.com/v1/timings/$formattedDate?latitude=$latitude&longitude=$longitude&method=$method');

      print('جلب أوقات الصلاة من: $url');
      // إرسال الطلب
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // تحليل البيانات
        final data = json.decode(response.body);
        final timings = data['data']['timings'];

        print('تم الحصول على أوقات الصلاة بنجاح: $timings');
        // إنشاء نموذج أوقات الأذان
        final adhanTimes = AdhanTimes(
          locationId: targetLocationId,
          date: targetDate,
          fajrTime: formatTime(timings['Fajr']),
          sunriseTime: formatTime(timings['Sunrise']),
          dhuhrTime: formatTime(timings['Dhuhr']),
          asrTime: formatTime(timings['Asr']),
          maghribTime: formatTime(timings['Maghrib']),
          ishaTime: formatTime(timings['Isha']),
        );
        try {
          // حفظ البيانات في قاعدة البيانات مع استبدال إذا كان موجودًا
          final db = await DatabaseHelper.instance.database;
          final Map<String, dynamic> adhanMap = {
            'location_id': adhanTimes.locationId,
            'date': DateFormat('yyyy-MM-dd').format(adhanTimes.date),
            'fajr_time': adhanTimes.fajrTime,
            'sunrise_time': adhanTimes.sunriseTime,
            'dhuhr_time': adhanTimes.dhuhrTime,
            'asr_time': adhanTimes.asrTime,
            'maghrib_time': adhanTimes.maghribTime,
            'isha_time': adhanTimes.ishaTime,
          };

          final result = await db.insert(AppDatabase.tableAdhanTimes, adhanMap,
              conflictAlgorithm: ConflictAlgorithm.replace);

          // تحديث الأذان الحالي في جدول current_adhan (إذا كان موجودًا)
          try {
            final currentAdhanResult = await db.update(
              'current_adhan',
              adhanMap,
              where: 'location_id = ?',
              whereArgs: [targetLocationId],
            );

            // إذا لم يكن هناك سجل للتحديث، قم بإنشائه
            if (currentAdhanResult == 0) {
              await db.insert('current_adhan', adhanMap,
                  conflictAlgorithm: ConflictAlgorithm.replace);
            }

            print('تم تحديث الأذان الحالي بنجاح');
          } catch (e) {
            print('خطأ في تحديث الأذان الحالي: $e');
          }

          print('تم حفظ أوقات الصلاة بنجاح في قاعدة البيانات');
          return true;
        } catch (e) {
          print('خطأ في حفظ أوقات الصلاة في قاعدة البيانات: $e');
          return false;
        }
      } else {
        print('فشل في الحصول على أوقات الصلاة: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('خطأ في الحصول على أوقات الصلاة: $e');
      return false;
    }
  }

  /// الحصول على أوقات الصلاة لتاريخ محدد ولفترة محددة
  Future<bool> fetchPrayerTimesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int? locationId,
    bool forceUpdate = false,
  }) async {
    try {
      // الحصول على معرف الموقع الحالي إذا لم يتم تحديد موقع
      final targetLocationId =
          locationId ?? await _currentLocationDao.getCurrentLocationId();

      // حساب عدد الأيام في النطاق
      final days = endDate.difference(startDate).inDays + 1;
      print(
          'جلب أوقات الصلاة لـ $days يوم من ${DateFormat('yyyy-MM-dd').format(startDate)} إلى ${DateFormat('yyyy-MM-dd').format(endDate)}');

      // الحصول على أوقات الصلاة لكل يوم في النطاق
      bool allSuccess = true;
      for (int i = 0; i < days; i++) {
        final date = startDate.add(Duration(days: i));
        final success = await fetchAndStorePrayerTimes(
          date: date,
          locationId: targetLocationId,
        );

        if (!success) {
          allSuccess = false;
        }

        // تأخير بسيط لتجنب طلبات API المتكررة بسرعة كبيرة
        await Future.delayed(Duration(milliseconds: 500));
      }

      return allSuccess;
    } catch (e) {
      print('خطأ في الحصول على أوقات الصلاة للنطاق الزمني: $e');
      return false;
    }
  }

  Future<bool> fetchPrayerTimesForSpecificDate({
    int? locationId,
    DateTime? date,
    bool? forceUpdate = false,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final targetLocationId =
          locationId ?? await _currentLocationDao.getCurrentLocationId();

      // Si no es una actualización forzada, verificamos si los datos ya existen
      if (!forceUpdate!) {
        final existingData = await _adhanTimesDao.getByDateAndLocation(
          targetDate,
          targetLocationId,
        );

        if (existingData != null) {
          print(
              'أوقات الصلاة موجودة بالفعل لتاريخ ${DateFormat('yyyy-MM-dd').format(targetDate)}');
          return true;
        }
      }

      // الحصول على أوقات الصلاة
      return await fetchAndStorePrayerTimes(
          date: targetDate, locationId: targetLocationId);
    } catch (e) {
      print('خطأ في الحصول على أوقات الصلاة للتاريخ المحدد: $e');
      return false;
    }
  }

  /// تحديث أوقات الصلاة لجميع السجلات الموجودة في قاعدة البيانات
  Future<bool> refreshAllPrayerTimes({bool forceUpdate = true}) async {
    if (_isRefreshing) {
      print('هناك عملية تحديث جارية بالفعل، الرجاء الانتظار...');
      return false;
    }

    try {
      _isRefreshing = true;
      print('بدء تحديث أوقات الصلاة لجميع السجلات...');

      // الحصول على جميع السجلات المميزة (تاريخ + موقع) من قاعدة البيانات
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery('''
        SELECT DISTINCT location_id, date FROM ${AppDatabase.tableAdhanTimes}
        ORDER BY date ASC
      ''');

      /// use dao

      print('عدد السجلات المميزة (تاريخ + موقع): ${result.length}');

      // تحديث كل سجل
      int successCount = 0;
      for (var record in result) {
        final locationId = record['location_id'] as int;
        final dateStr = record['date'] as String;
        final date = DateTime.parse(dateStr);

        // تجاهل التواريخ القديمة (أقل من التاريخ الحالي بأكثر من 7 أيام)
        final now = DateTime.now();
        final difference = now.difference(date).inDays;

        // تحديث فقط التواريخ المستقبلية والتاريخ الحالي وحتى 7 أيام في الماضي
        if (difference <= 7) {
          print('تحديث أوقات الصلاة لتاريخ $dateStr وموقع $locationId');
          final success = await fetchAndStorePrayerTimes(
            date: date,
            locationId: locationId,
          );

          if (success) {
            successCount++;
          }

          // تأخير بسيط لتجنب طلبات API المتكررة بسرعة كبيرة
          await Future.delayed(Duration(milliseconds: 500));
        } else {
          print('تجاهل التاريخ $dateStr (قديم بـ $difference يوم)');
        }
      }

      print('تم تحديث $successCount من أصل ${result.length} سجل بنجاح');
      return successCount > 0;
    } catch (e) {
      print('خطأ في تحديث أوقات الصلاة لجميع السجلات: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /*
  /// جلب أوقات الصلاة من الخادم لموقع وتاريخ محددين
  Future<bool> fetchPrayerTimesForSpecificDate({
    required int locationId,
    required DateTime date,
    bool forceUpdate = false,
  }) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      // التحقق من وجود البيانات في قاعدة البيانات أولاً
      if (!forceUpdate) {
        final storedTimes =
            await _adhanTimesDao.getByDateAndLocation(date, locationId);
        if (storedTimes != null) {
          return true; // البيانات موجودة بالفعل
        }
      }

      // جلب معلومات الموقع
      final locations = await _currentLocationDao.getAllLocations();
      final location = locations.firstWhere(
        (loc) => loc.locationId == locationId,
        orElse: () => throw Exception('لم يتم العثور على الموقع'),
      );

      // تكوين طلب لواجهة API
      final methodId =
          location.methodId ?? 4; // استخدام طريقة أم القرى كافتراضية
      final url = Uri.parse(
        'http://api.aladhan.com/v1/timings/$dateStr?latitude=${location.latitude}&longitude=${location.longitude}&method=$methodId',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] == 200 && data['status'] == 'OK') {
          final timings = data['data']['timings'];

          final adhanTimes = AdhanTimes(
            locationId: locationId,
            date: date,
            fajrTime: timings['Fajr'],
            sunriseTime: timings['Sunrise'],
            dhuhrTime: timings['Dhuhr'],
            asrTime: timings['Asr'],
            maghribTime: timings['Maghrib'],
            ishaTime: timings['Isha'],
          );

          // حفظ البيانات في قاعدة البيانات
          await _saveAdhanTimes(adhanTimes);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('خطأ في جلب أوقات الصلاة: $e');
      return false;
    }
  }*/

  /// حفظ أوقات الصلاة في قاعدة البيانات
  Future<void> _saveAdhanTimes(AdhanTimes adhanTimes) async {
    try {
      // التحقق من وجود سجل بنفس التاريخ والموقع
      final existingRecord = await _adhanTimesDao.getByDateAndLocation(
          adhanTimes.date, adhanTimes.locationId);

      if (existingRecord != null) {
        // تحديث السجل الموجود
        await _adhanTimesDao.update(adhanTimes);
      } else {
        // إدراج سجل جديد
        await _adhanTimesDao.insert(adhanTimes);
      }
    } catch (e) {
      print('خطأ في حفظ أوقات الصلاة: $e');
      throw e;
    }
  }

  /// جلب أوقات الصلاة للفترة المحددة
  Future<bool> fetchPrayerTimesForPeriod({
    required int locationId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // التحقق من صحة الفترة
      if (endDate.isBefore(startDate)) {
        throw ArgumentError('يجب أن يكون تاريخ النهاية بعد تاريخ البداية');
      }

      // حساب عدد الأيام
      final difference = endDate.difference(startDate).inDays + 1;
      if (difference > 30) {
        throw ArgumentError(
            'لا يمكن جلب بيانات لأكثر من 30 يومًا في المرة الواحدة');
      }

      // جلب البيانات لكل يوم في الفترة
      bool allSucceeded = true;
      for (int i = 0; i < difference; i++) {
        final currentDate = startDate.add(Duration(days: i));
        final success = await fetchPrayerTimesForSpecificDate(
          locationId: locationId,
          date: currentDate,
          forceUpdate: true,
        );

        if (!success) {
          allSucceeded = false;
        }
      }

      return allSucceeded;
    } catch (e) {
      print('خطأ في جلب أوقات الصلاة للفترة: $e');
      return false;
    }
  }

  /// تحديث أوقات الصلاة بعد تغيير الموقع
  Future<bool> updatePrayerTimes(double latitude, double longitude) async {
    try {
      // الحصول على موقع افتراضي بناءً على المعلومات المقدمة
      final location = await _currentLocationDao.getCurrentLocation();

      if (location.locationId == null) {
        throw Exception('لم يتم العثور على موقع حالي');
      }

      // تحديث أوقات الصلاة للتاريخ الحالي والأيام القادمة
      final today = DateTime.now();
      final endDate = today.add(Duration(days: 7)); // أسبوع قادم

      return await fetchPrayerTimesForPeriod(
        locationId: location.locationId!,
        startDate: today,
        endDate: endDate,
      );
    } catch (e) {
      print('خطأ في تحديث أوقات الصلاة: $e');
      return false;
    }
  }
}
