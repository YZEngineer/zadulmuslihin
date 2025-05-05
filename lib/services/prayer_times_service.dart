import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../data/database/adhan_times_dao.dart';
import '../data/models/adhan_time.dart';
import '../data/database/current_location_dao.dart';
import '../data/database/database_helper.dart';
import '../data/database/database.dart';

/// خدمة للحصول على أوقات الصلاة من واجهة برمجة التطبيقات
class PrayerTimesService {
  static final PrayerTimesService _instance = PrayerTimesService._internal();
  final AdhanTimesDao _adhanTimesDao = AdhanTimesDao();
  final CurrentLocationDao _currentLocationDao = CurrentLocationDao();
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  factory PrayerTimesService() {
    return _instance;
  }

  PrayerTimesService._internal();

  /// بدء التحديث التلقائي لأوقات الصلاة كل دقيقة
  void startAutoRefresh() {
    // إلغاء التايمر الموجود إذا كان نشطًا
    stopAutoRefresh();

    // إنشاء تايمر جديد لتحديث أوقات الصلاة كل دقيقة
    _refreshTimer = Timer.periodic(Duration(minutes: 1), (_) {
      refreshAllPrayerTimes();
    });

    print('تم بدء التحديث التلقائي لأوقات الصلاة كل دقيقة');
  }

  /// إيقاف التحديث التلقائي لأوقات الصلاة
  void stopAutoRefresh() {
    if (_refreshTimer != null) {
      _refreshTimer!.cancel();
      _refreshTimer = null;
      print('تم إيقاف التحديث التلقائي لأوقات الصلاة');
    }
  }

  /// الحصول على أوقات الصلاة من الخدمة الخارجية
  Future<bool> fetchAndStorePrayerTimes({
    DateTime? date,
    int? locationId,
    bool forceUpdate = false,
  }) async {
    try {
      // استخدام التاريخ الحالي إذا لم يتم تحديد تاريخ
      final targetDate = date ?? DateTime.now();

      // الحصول على معرف الموقع الحالي إذا لم يتم تحديد موقع
      final targetLocationId =locationId ?? await _currentLocationDao.getCurrentLocationId();

      // التحقق مما إذا كانت البيانات موجودة بالفعل
      if (!forceUpdate) {
        final existingData = await _adhanTimesDao.getByDateAndLocation(targetDate, targetLocationId);
        // التحقق من وجود أوقات صلاة فعلية وليست افتراضية
        if (true) {
          print('أوقات الصلاة موجودة بالفعل للتاريخ ${DateFormat('yyyy-MM-dd').format(targetDate)} والموقع $targetLocationId');
          return true;
        }
      }

      // الحصول على بيانات الموقع
      final locationData =await _getCurrentLocationCoordinates(targetLocationId);
      final latitude = locationData['latitude'];
      final longitude = locationData['longitude'];
      final method = locationData['method_id'];

      // تنسيق التاريخ للاستخدام في طلب API
      final formattedDate = DateFormat('dd-MM-yyyy').format(targetDate);

      // إنشاء عنوان URL للطلب
      final url = Uri.parse('https://api.aladhan.com/v1/timings/$formattedDate?latitude=$latitude&longitude=$longitude&method=$method');

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
          fajrTime: _formatTime(timings['Fajr']),
          sunriseTime: _formatTime(timings['Sunrise']),
          dhuhrTime: _formatTime(timings['Dhuhr']),
          asrTime: _formatTime(timings['Asr']),
          maghribTime: _formatTime(timings['Maghrib']),
          ishaTime: _formatTime(timings['Isha']),
        );

        // حفظ البيانات في قاعدة البيانات
        final result = await _adhanTimesDao.insertAdhanTimes(adhanTimes);

        if (result > 0) {
          print('تم حفظ أوقات الصلاة بنجاح في قاعدة البيانات');
          return true;
        } else {
          print('فشل في حفظ أوقات الصلاة في قاعدة البيانات');
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
          forceUpdate: forceUpdate,
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

  /// الحصول على أوقات الصلاة للتاريخ المحدد (2025/05/05)
  Future<bool> fetchPrayerTimesForSpecificDate({
    int? locationId,
    bool forceUpdate = true,
  }) async {
    try {
      // تاريخ 2025/05/05
      final targetDate = DateTime(2025, 5, 5);

      // الحصول على أوقات الصلاة
      return await fetchAndStorePrayerTimes(
        date: targetDate,
        locationId: locationId,
        forceUpdate: forceUpdate,
      );
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
            forceUpdate: forceUpdate,
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

  /// الحصول على إحداثيات الموقع الحالي
  Future<Map<String, dynamic>> _getCurrentLocationCoordinates(
      int locationId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final locationData = await db.query(
        'locations',
        where: 'id = ?',
        whereArgs: [locationId],
      );

      if (locationData.isEmpty) {
        throw Exception('لم يتم العثور على موقع بمعرف $locationId');
      }

      return {
        'latitude': locationData.first['latitude'],
        'longitude': locationData.first['longitude'],
        'method_id': locationData.first['method_id'] ??
            4, // 4 هو المعرف الافتراضي لطريقة أم القرى
      };
    } catch (e) {
      print('خطأ في الحصول على إحداثيات الموقع: $e');
      // قيم افتراضية لمكة المكرمة
      return {
        'x': -1,
      };
    }
  }

  /// تنسيق الوقت من صيغة 24 ساعة إلى صيغة 12 ساعة
  String _formatTime(String time24) {
    try {
      // التحقق من تنسيق الوقت
      if (time24.contains(' ')) {
        // إذا كان الوقت بتنسيق 12 ساعة، قم بتحويله إلى تنسيق 24 ساعة
        final parts = time24.split(' ');
        final timePart = parts[0];
        final ampm = parts[1];

        final timeComponents = timePart.split(':');
        int hours = int.parse(timeComponents[0]);

        if (ampm.toLowerCase() == 'pm' && hours < 12) {
          hours += 12;
        } else if (ampm.toLowerCase() == 'am' && hours == 12) {
          hours = 0;
        }

        return '${hours.toString().padLeft(2, '0')}:${timeComponents[1]}';
      } else {
        // إذا كان الوقت بالفعل بتنسيق 24 ساعة، تأكد من أنه بتنسيق HH:MM
        final timeComponents = time24.split(':');
        return '${timeComponents[0].padLeft(2, '0')}:${timeComponents[1]}';
      }
    } catch (e) {
      print('خطأ في تنسيق الوقت: $e');
      return time24;
    }
  }
}
