import 'adhan_service.dart';
import 'adhan_updater.dart';
import '../../data/database/adhan_times_dao.dart';
import '../../data/database/current_location_dao.dart';
import '../../data/database/current_adhan_dao.dart';
import '../../data/database/location_dao.dart';

/// مزود للوصول إلى الخدمات المختلفة في التطبيق
class ServiceProvider {
  static final ServiceProvider _instance = ServiceProvider._internal();

  factory ServiceProvider() {
    return _instance;
  }

  ServiceProvider._internal();

  // كائنات الـ DAO التي سيتم استخدامها في الخدمات
  final adhanTimesDao = AdhanTimesDao();
  final currentLocationDao = CurrentLocationDao();
  final currentAdhanDao = CurrentAdhanDao();
  final locationDao = LocationDao();

  // خدمة الأذان
  late final AdhanService adhanService = AdhanService(
    adhanTimesDao: adhanTimesDao,
    currentLocationDao: currentLocationDao,
    currentAdhanDao: currentAdhanDao,
  );

  // محدث الأذان
  late final AdhanUpdater adhanUpdater = AdhanUpdater(
    serviceProvider: this,
  );

  // تهيئة جميع الخدمات
  Future<void> initialize() async {
    // بدء تحديث الأذان الدوري
    adhanUpdater.startPeriodicUpdates();
  }
}
