import '../models/adhan_time.dart';
import 'database.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

/// فئة للتعامل مع بيانات أوقات الصلاة في قاعدة البيانات
class AdhanTimesDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableAdhanTimes;

  /// إدراج أوقات الأذان وتعامل مع الإدخالات المكررة
  Future<int> insertAdhanTimes(AdhanTimes adhanTimes) async {
    try {
      // استخدام insertOrReplace للتعامل مع قيود UNIQUE
      return await _databaseHelper.insertOrReplace(
          _tableName, adhanTimes.toMap());
    } catch (e) {
      print('خطأ في إدراج أوقات الأذان: $e');
      return -1;
    }
  }

  /// تحديث أوقات الأذان بدون إمكانية حذفها
  Future<int> updateAdhanTimes(AdhanTimes adhanTimes) async {
    try {
      final existingRecords =
          await getByDateAndLocation(adhanTimes.date, adhanTimes.locationId);

      if (existingRecords.id == null) {
        // هذه الحالة لا ينبغي أن تحدث لأن جميع السجلات يجب أن تكون موجودة مسبقاً
        print(
            'لم يتم العثور على سجل لأوقات الأذان لتاريخ ${DateFormat('yyyy-MM-dd').format(adhanTimes.date)} والموقع ${adhanTimes.locationId}');

        // فقط للتأكد من استمرار عمل التطبيق، نقوم بإنشاء سجل جديد
        print(
            'سيتم إنشاء سجل جديد، لكن هذا يجب ألا يحدث في سيناريو التشغيل العادي');
        return await _databaseHelper.insertOrReplace(
            _tableName, adhanTimes.toMap());
      } else {
        // تحديث السجل الموجود
        final existingId = existingRecords.id;
        if (existingId == null) {
          throw ArgumentError('لا يمكن تحديث سجل بدون معرف');
        }

        final updatedData = adhanTimes.copyWith(id: existingId).toMap();
        return await _databaseHelper
            .update(_tableName, updatedData, 'id = ?', [existingId]);
      }
    } catch (e) {
      print('خطأ في تحديث أوقات الأذان: $e');
      return -1;
    }
  }

  /// الحصول على وقت الأذان لتاريخ وموقع معينين
  Future<AdhanTimes> getByDateAndLocation(DateTime date, int locationId) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final result = await _databaseHelper.query(_tableName,
          where: 'date = ? AND location_id = ?',
          whereArgs: [formattedDate, locationId]);
      if (result.isEmpty) {
        // إنشاء نموذج بقيم افتراضية
        AdhanTimes newAdhanTimes = AdhanTimes(
          locationId: locationId,
          date: date,
          fajrTime: '00:00',
          sunriseTime: '00:00',
          dhuhrTime: '00:00',
          asrTime: '00:00',
          maghribTime: '00:00',
          ishaTime: '00:00',
        );

        // محاولة إدراج السجل في قاعدة البيانات
        try {
          await _databaseHelper.insertOrReplace(
              _tableName, newAdhanTimes.toMap());
          print(
              'تم إنشاء سجل جديد لأوقات الأذان لتاريخ $formattedDate وموقع $locationId');
        } catch (insertError) {
          print('خطأ في إدراج سجل جديد لأوقات الأذان: $insertError');
        }

        return newAdhanTimes;
      }

      return AdhanTimes.fromMap(result.first);
    } catch (e) {
      print('خطأ في استرجاع أوقات الأذان لتاريخ وموقع معينين: $e');
      return AdhanTimes(
        locationId: locationId,
        date: date,
        fajrTime: '00:00',
        sunriseTime: '00:00',
        dhuhrTime: '00:00',
        asrTime: '00:00',
        maghribTime: '00:00',
        ishaTime: '00:00',
      );
    }
  }

  /// الحصول على أوقات الأذان لتاريخ معين
  Future<List<AdhanTimes>> getByDate(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final result = await _databaseHelper.query(
        _tableName,
        where: 'date = ?',
        whereArgs: [formattedDate],
      );

      return result.map((map) => AdhanTimes.fromMap(map)).toList();
    } catch (e) {
      print('خطأ في استرجاع أوقات الأذان لتاريخ معين: $e');
      return [];
    }
  }

  /// الحصول على أوقات الأذان لفترة زمنية وموقع محدد
  Future<List<AdhanTimes>> getByDateRangeAndLocation(
      DateTime startDate, DateTime endDate, int locationId) async {
    try {
      final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

      final result = await _databaseHelper.query(
        _tableName,
        where: 'date BETWEEN ? AND ? AND location_id = ?',
        whereArgs: [formattedStartDate, formattedEndDate, locationId],
        orderBy: 'date ASC',
      );

      return result.map((map) => AdhanTimes.fromMap(map)).toList();
    } catch (e) {
      print('خطأ في استرجاع أوقات الأذان لفترة زمنية وموقع: $e');
      return [];
    }
  }

  /// الحصول على أحدث أوقات أذان للموقع
  Future<AdhanTimes?> getLatest(int locationId) async {
    try {
      final result = await _databaseHelper.query(_tableName,
          where: 'location_id = ?',
          whereArgs: [locationId],
          orderBy: 'date DESC',
          limit: 1);

      if (result.isEmpty) {
        return null;
      }

      return AdhanTimes.fromMap(result.first);
    } catch (e) {
      print('خطأ في استرجاع أحدث أوقات أذان للموقع $locationId: $e');
      return null;
    }
  }

  /// الحصول على أوقات الأذان الحالية لموقع معين
  Future<AdhanTimes?> getCurrentForLocation(int locationId) async {
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);

      final result = await _databaseHelper.query(
        _tableName,
        where: 'date = ? AND location_id = ?',
        whereArgs: [formattedDate, locationId],
      );

      if (result.isEmpty) {
        // إذا لم يتم العثور على سجل لليوم الحالي، نقوم بإنشاء واحد
        print('إنشاء سجل جديد لأوقات الأذان لليوم الحالي للموقع $locationId');

        AdhanTimes newAdhanTimes = AdhanTimes(
          locationId: locationId,
          date: now,
          fajrTime: '00:00',
          sunriseTime: '00:00',
          dhuhrTime: '00:00',
          asrTime: '00:00',
          maghribTime: '00:00',
          ishaTime: '00:00',
        );

        // استخدام insertOrReplace لتجنب مشاكل UNIQUE
        await _databaseHelper.insertOrReplace(
            _tableName, newAdhanTimes.toMap());

        return newAdhanTimes;
      }

      return AdhanTimes.fromMap(result.first);
    } catch (e) {
      print('خطأ في استرجاع أوقات الأذان الحالية للموقع: $e');
      return null;
    }
  }
}
