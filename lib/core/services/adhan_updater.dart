import 'dart:async';
import 'package:intl/intl.dart';
import 'service_provider.dart';
import '../../data/models/adhan_time.dart';
import '../../data/models/location.dart';

/// خدمة لتحديث أوقات الأذان بشكل دوري وضمان بقاء البيانات محدثة
class AdhanUpdater {
  final ServiceProvider _serviceProvider;
  Timer? _dailyUpdateTimer;
  Timer? _currentAdhanUpdateTimer;

  AdhanUpdater({required ServiceProvider serviceProvider})
      : _serviceProvider = serviceProvider;

  /// بدء التحديث الدوري للبيانات
  void startPeriodicUpdates() {
    // تحديث البيانات فوراً
    updateAdhanData();

    // جدولة التحديث اليومي في منتصف الليل
    _scheduleDailyUpdate();
  }

  /// إيقاف التحديث الدوري

  /// تحديث بيانات الأذان (اليوم وغداً)
  Future<void> updateAdhanData() async {
    print('جاري تحديث بيانات الأذان...');

    // التأكد من وجود موقع حالي
    Location? currentLocation = await _ensureCurrentLocation();
    if (currentLocation == null) {
      print('لا يمكن تحديث بيانات الأذان: لا يوجد موقع حالي');
      return;
    }

    // تاريخ اليوم
    DateTime now = DateTime.now();
    String today = DateFormat('yyyy-MM-dd').format(now);

    // تاريخ الغد
    DateTime tomorrow = now.add(const Duration(days: 1));
    String tomorrowStr = DateFormat('yyyy-MM-dd').format(tomorrow);

    try {
      // تحديث بيانات اليوم
      AdhanTimes? todayTimes =
          await _serviceProvider.adhanService.fetchAdhanTimes(
        date: today,
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
        method: currentLocation.methodId,
      );

      if (todayTimes != null) {
        print('تم تحديث أوقات الأذان ليوم $today');
      }

      // تحديث بيانات الغد
      AdhanTimes? tomorrowTimes =
          await _serviceProvider.adhanService.fetchAdhanTimes(
        date: tomorrowStr,
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
        method: currentLocation.methodId,
      );

      if (tomorrowTimes != null) {
        print('تم تحديث أوقات الأذان ليوم $tomorrowStr');
      }

      // تحديث الأذان الحالي
      await _serviceProvider.adhanService.updateCurrentAdhan();
      print('تم تحديث الأذان الحالي');
    } catch (e) {
      print('خطأ في تحديث بيانات الأذان: $e');
    }
  }

  /// جدولة التحديث اليومي في منتصف الليل
  void _scheduleDailyUpdate() {
    // حساب الوقت المتبقي حتى منتصف الليل
    DateTime now = DateTime.now();
    DateTime midnight = DateTime(now.year, now.month, now.day + 1);
    Duration timeUntilMidnight = midnight.difference(now);

    // جدولة التحديث اليومي
    _dailyUpdateTimer = Timer(timeUntilMidnight, () {
      // تحديث البيانات
      updateAdhanData();

      // إعادة جدولة التحديث للغد
      _scheduleDailyUpdate();
    });

    print(
        'تم جدولة التحديث اليومي بعد ${timeUntilMidnight.inHours} ساعات و ${timeUntilMidnight.inMinutes % 60} دقائق');
  }

  /// التأكد من وجود موقع حالي
  Future<Location?> _ensureCurrentLocation() async {
    Location? currentLocation =
        await _serviceProvider.currentLocationDao.getCurrentLocation();

    if (currentLocation == null) {
      print('الموقع الحالي غير محدد. محاولة تحميل موقع افتراضي...');

      // محاولة تحميل أول موقع متاح
      List<Location> locations =
          await _serviceProvider.locationDao.getAllLocations();

      if (locations.isNotEmpty) {
        print('تم العثور على ${locations.length} موقع. استخدام الموقع الأول.');
        await _serviceProvider.currentLocationDao
            .setCurrentLocation(locations[0].id!);
        return locations[0];
      } else {
        // إنشاء موقع افتراضي في حالة عدم وجود مواقع
        print('لم يتم العثور على مواقع. إنشاء موقع افتراضي...');
        Location defaultLocation = Location(
          name: "مكة المكرمة، السعودية",
          latitude: 21.4225,
          longitude: 39.8262,
          country: "السعودية",
          city: "مكة المكرمة",
          methodId: 4, // أم القرى
        );

        int locationId =
            await _serviceProvider.locationDao.insert(defaultLocation);
        defaultLocation = defaultLocation.copyWith(id: locationId);
        await _serviceProvider.currentLocationDao
            .setCurrentLocation(locationId);
        return defaultLocation;
      }
    }

    return currentLocation;
  }
}
