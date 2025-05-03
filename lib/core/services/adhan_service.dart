import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../data/models/adhan_time.dart';
import '../../data/models/location.dart';
import '../../data/models/current_adhan.dart';
import '../../data/database/adhan_times_dao.dart';
import '../../data/database/current_location_dao.dart';
import '../../data/database/current_adhan_dao.dart';
import '../utils/time_helper.dart';

class AdhanService {
  final AdhanTimesDao adhanTimesDao;
  final CurrentLocationDao currentLocationDao;
  final CurrentAdhanDao currentAdhanDao;
  // Base URL للحصول على مواقيت الصلاة
  final String apiBaseUrl = 'https://api.aladhan.com/v1';

  AdhanService({
    required this.adhanTimesDao,
    required this.currentLocationDao,
    required this.currentAdhanDao,
  });

  /// الحصول على أوقات الأذان للموقع المحدد
  /// طريقة الحساب الافتراضية هي رابطة العالم الإسلامي
  Future<AdhanTimes?> fetchAdhanTimes({
    required String date,
    required double latitude,
    required double longitude,
    int? method, // طريقة الحساب (1-15)
    int? adjustment, // تعديل الوقت بالدقائق
  }) async {
    try {
      // تحقق أولاً إذا كانت أوقات الأذان موجودة محليًا
      AdhanTimes? localAdhanTimes =
          await adhanTimesDao.getAdhanTimesByDate(date);
      if (localAdhanTimes != null) {
        print('تم استرجاع أوقات الأذان من قاعدة البيانات المحلية ليوم: $date');
        return localAdhanTimes;
      }

      print('جاري طلب أوقات الأذان من الخادم ليوم: $date');

      // إذا لم تكن موجودة، قم بطلبها من الخادم
      String url = '$apiBaseUrl/timings/$date';

      // بناء معلمات الطلب
      Map<String, String> queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      };

      // إضافة معلمات اختيارية إذا تم توفيرها
      if (method != null) {
        queryParams['method'] = method.toString();
      } else {
        // استخدام طريقة رابطة العالم الإسلامي كافتراضية
        queryParams['method'] = '3';
      }

      if (adjustment != null) {
        queryParams['adjustment'] = adjustment.toString();
      }

      // طباعة عنوان URL للتصحيح
      final fullUrl = Uri.parse(url).replace(queryParameters: queryParams);
      print('طلب API: ${fullUrl.toString()}');

      // إعادة المحاولة ثلاث مرات في حالة فشل الاتصال
      int maxRetries = 3;
      int retryCount = 0;
      http.Response? response;

      while (retryCount < maxRetries) {
        try {
          // إرسال الطلب مع مهلة 10 ثوانٍ كحد أقصى
          response =
              await http.get(fullUrl).timeout(const Duration(seconds: 10));
          break; // الخروج من الحلقة إذا نجح الطلب
        } catch (e) {
          retryCount++;
          print('فشل الطلب (محاولة $retryCount من $maxRetries): $e');
          if (retryCount >= maxRetries) {
            throw Exception('فشل الحصول على البيانات بعد $maxRetries محاولات');
          }
          // انتظر قبل إعادة المحاولة
          await Future.delayed(Duration(seconds: 2 * retryCount));
        }
      }

      if (response != null && response.statusCode == 200) {
        // تحليل الاستجابة
        Map<String, dynamic> data = json.decode(response.body);
        if (data['code'] == 200 && data['status'] == 'OK') {
          Map<String, dynamic> timings = data['data']['timings'];

          print('تم استلام أوقات الأذان بنجاح: ${timings.toString()}');

          // إنشاء كائن AdhanTimes من البيانات المستلمة
          AdhanTimes adhanTimes = AdhanTimes(
            date: date,
            fajrTime: _formatTime(timings['Fajr']),
            sunriseTime: _formatTime(timings['Sunrise']),
            dhuhrTime: _formatTime(timings['Dhuhr']),
            asrTime: _formatTime(timings['Asr']),
            maghribTime: _formatTime(timings['Maghrib']),
            ishaTime: _formatTime(timings['Isha']),
            // يمكن حساب وقت السحور كوقت قبل الفجر بساعة تقريبًا
            suhoorTime: _calculateSuhoorTime(_formatTime(timings['Fajr'])),
          );

          // حفظ البيانات المستلمة محليًا
          try {
            await adhanTimesDao.save(adhanTimes);
            print('تم حفظ أوقات الأذان في قاعدة البيانات المحلية');
          } catch (e) {
            print('خطأ في حفظ أوقات الأذان محليًا: $e');
            // الاستمرار بإرجاع البيانات حتى لو فشل الحفظ المحلي
          }

          return adhanTimes;
        } else {
          print('خطأ في استجابة API: ${data['status']} - ${data['data']}');
        }
      } else {
        print('خطأ في الطلب: ${response?.statusCode} - ${response?.body}');
      }

      // إنشاء بيانات افتراضية في حالة فشل الطلب
      print('استخدام بيانات افتراضية نظرًا لفشل الطلب');
      return _createDefaultAdhanTimes(date);
    } catch (e) {
      print('خطأ في الحصول على أوقات الأذان: $e');
      // إرجاع بيانات افتراضية في حالة حدوث استثناء
      return _createDefaultAdhanTimes(date);
    }
  }

  /// إنشاء أوقات أذان افتراضية في حالة فشل طلب API
  AdhanTimes _createDefaultAdhanTimes(String date) {
    return AdhanTimes(
      date: date,
      fajrTime: '04:30',
      sunriseTime: '06:05',
      dhuhrTime: '12:15',
      asrTime: '15:30',
      maghribTime: '18:10',
      ishaTime: '19:45',
      suhoorTime: '03:45',
    );
  }

  /// الحصول على أوقات الأذان لشهر كامل للموقع المحدد
  Future<List<AdhanTimes>> fetchMonthlyAdhanTimes({
    required int year,
    required int month,
    required double latitude,
    required double longitude,
    int? method,
    int? adjustment,
  }) async {
    try {
      // عنوان URL للحصول على مواقيت الصلاة الشهرية
      String url = '$apiBaseUrl/calendar/$year/$month';

      // بناء معلمات الطلب
      Map<String, String> queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      };

      // إضافة معلمات اختيارية إذا تم توفيرها
      if (method != null) {
        queryParams['method'] = method.toString();
      } else {
        // استخدام طريقة رابطة العالم الإسلامي كافتراضية
        queryParams['method'] = '3';
      }

      if (adjustment != null) {
        queryParams['adjustment'] = adjustment.toString();
      }

      // طباعة عنوان URL للتصحيح
      final fullUrl = Uri.parse(url).replace(queryParameters: queryParams);
      print('طلب API الشهري: ${fullUrl.toString()}');

      // إرسال الطلب
      final response = await http.get(fullUrl);

      if (response.statusCode == 200) {
        // تحليل الاستجابة
        Map<String, dynamic> data = json.decode(response.body);
        if (data['code'] == 200 && data['status'] == 'OK') {
          List<dynamic> days = data['data'];
          List<AdhanTimes> adhanTimesList = [];

          for (var day in days) {
            Map<String, dynamic> timings = day['timings'];
            String date = day['date']['gregorian']['date'];

            // تنسيق التاريخ إلى YYYY-MM-DD
            DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(date);
            String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

            AdhanTimes adhanTimes = AdhanTimes(
              date: formattedDate,
              fajrTime: _formatTime(timings['Fajr']),
              sunriseTime: _formatTime(timings['Sunrise']),
              dhuhrTime: _formatTime(timings['Dhuhr']),
              asrTime: _formatTime(timings['Asr']),
              maghribTime: _formatTime(timings['Maghrib']),
              ishaTime: _formatTime(timings['Isha']),
              suhoorTime: _calculateSuhoorTime(_formatTime(timings['Fajr'])),
            );

            // إضافة البيانات إلى القائمة
            adhanTimesList.add(adhanTimes);

            // حفظ البيانات محليًا
            await adhanTimesDao.save(adhanTimes);
          }

          print(
              'تم الحصول على أوقات الأذان لـ ${adhanTimesList.length} يوم من الشهر');
          return adhanTimesList;
        }
      }

      // في حالة فشل الطلب أو كانت البيانات غير صالحة
      print('فشل في الحصول على بيانات الأذان الشهرية: ${response.statusCode}');
      return [];
    } catch (e) {
      print('خطأ في الحصول على أوقات الأذان الشهرية: $e');
      return [];
    }
  }

  /// الحصول على أوقات الأذان ليوم معين للموقع الحالي
  Future<AdhanTimes?> getAdhanTimesForCurrentLocation({
    required String date,
    int? adjustment,
  }) async {
    try {
      // الحصول على الموقع الحالي
      Location? currentLocation = await currentLocationDao.getCurrentLocation();

      if (currentLocation == null) {
        print('لم يتم تحديد موقع حالي');
        return null;
      }

      // محاولة الحصول على البيانات من قاعدة البيانات المحلية
      AdhanTimes? localAdhanTimes =
          await adhanTimesDao.getAdhanTimesByDate(date);
      if (localAdhanTimes != null) {
        return localAdhanTimes;
      }

      // إذا لم تكن البيانات موجودة محليًا، اطلبها من الخادم
      return await fetchAdhanTimes(
        date: date,
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
        method: currentLocation.methodId,
        adjustment: adjustment,
      );
    } catch (e) {
      print('خطأ في الحصول على أوقات الأذان للموقع الحالي: $e');
      return null;
    }
  }

  /// الحصول على أوقات الأذان لشهر كامل للموقع الحالي
  Future<List<AdhanTimes>> getMonthlyAdhanTimesForCurrentLocation({
    required int year,
    required int month,
    int? adjustment,
  }) async {
    try {
      // الحصول على الموقع الحالي
      Location? currentLocation = await currentLocationDao.getCurrentLocation();

      if (currentLocation == null) {
        print('لم يتم تحديد موقع حالي');
        return [];
      }

      return await fetchMonthlyAdhanTimes(
        year: year,
        month: month,
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
        method: currentLocation.methodId,
        adjustment: adjustment,
      );
    } catch (e) {
      print('خطأ في الحصول على أوقات الأذان الشهرية للموقع الحالي: $e');
      return [];
    }
  }

  /// الحصول على الأذان الحالي
  Future<CurrentAdhan?> getCurrentAdhan() async {
    try {
      // محاولة الحصول على البيانات من قاعدة البيانات المحلية
      CurrentAdhan? currentAdhan = await currentAdhanDao.getCurrentAdhan();

      if (currentAdhan != null) {
        // التحقق من أن البيانات لليوم الحالي
        String today = TimeHelper.getToday();
        if (currentAdhan.date == today) {
          return currentAdhan;
        }
      }

      // إذا لم تكن البيانات موجودة أو قديمة، قم بتحديثها
      await updateCurrentAdhan();

      // إعادة محاولة الحصول على البيانات المحدثة
      return await currentAdhanDao.getCurrentAdhan();
    } catch (e) {
      print('خطأ في الحصول على الأذان الحالي: $e');
      return null;
    }
  }

  /// تحديث بيانات الأذان الحالي
  Future<void> updateCurrentAdhan() async {
    try {
      // الحصول على التاريخ الحالي
      String todayStr = TimeHelper.getToday();
      DateTime today = DateTime.parse(todayStr);

      // الحصول على أوقات الأذان لليوم الحالي
      AdhanTimes? todayTimes =
          await getAdhanTimesForCurrentLocation(date: todayStr);

      if (todayTimes != null) {
        // إنشاء كائن الأذان الحالي باستخدام جميع أوقات الصلوات
        CurrentAdhan currentAdhan = CurrentAdhan(
          date: todayStr,
          fajrTime: todayTimes.fajrTime,
          sunriseTime: todayTimes.sunriseTime,
          dhuhrTime: todayTimes.dhuhrTime,
          asrTime: todayTimes.asrTime,
          maghribTime: todayTimes.maghribTime,
          ishaTime: todayTimes.ishaTime,
          suhoorTime: todayTimes.suhoorTime,
        );

        // حفظ الأذان الحالي في قاعدة البيانات
        await currentAdhanDao.setCurrentAdhan(currentAdhan);

        print('تم تحديث أوقات الأذان الحالية ليوم: $todayStr');
      }
    } catch (e) {
      print('خطأ في تحديث الأذان الحالي: $e');
    }
  }

  /// الحصول على أوقات الأذان ليوم معين
  /// محاولة الحصول عليها من قاعدة البيانات المحلية أولاً، ثم من الخادم إذا لم تكن موجودة
  Future<AdhanTimes?> getAdhanTimes({
    required String date,
    required double latitude,
    required double longitude,
    int? method,
    int? adjustment,
  }) async {
    // محاولة الحصول على البيانات من قاعدة البيانات المحلية
    AdhanTimes? localAdhanTimes = await adhanTimesDao.getAdhanTimesByDate(date);

    if (localAdhanTimes != null) {
      return localAdhanTimes;
    }

    // إذا لم تكن موجودة، اطلبها من الخادم
    return await fetchAdhanTimes(
      date: date,
      latitude: latitude,
      longitude: longitude,
      method: method,
      adjustment: adjustment,
    );
  }

  /// تحويل تنسيق الوقت من API إلى تنسيق 24 ساعة
  String _formatTime(String apiTime) {
    // تنسيق الوقت من API يكون مثل "04:30 (GMT+3)" أو "04:30"
    String timeOnly = apiTime.split(' ').first;
    return timeOnly;
  }

  /// حساب وقت السحور (عادة قبل الفجر بساعة تقريبًا)
  String _calculateSuhoorTime(String fajrTime) {
    try {
      // تحويل وقت الفجر إلى دقائق ثم طرح 60 دقيقة (ساعة)
      int fajrMinutes = TimeHelper.timeToMinutes(fajrTime);
      int suhoorMinutes = fajrMinutes - 60;

      // تعامل مع حالة أن وقت السحور قد يكون قبل منتصف الليل
      if (suhoorMinutes < 0) {
        suhoorMinutes += 24 * 60; // إضافة 24 ساعة
      }

      // تحويل الدقائق إلى وقت
      return TimeHelper.minutesToTime(suhoorMinutes);
    } catch (e) {
      // في حالة الخطأ، إرجاع وقت افتراضي قبل الفجر بساعة
      return '03:30';
    }
  }
}
