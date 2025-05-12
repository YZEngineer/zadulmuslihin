import '../models/adhan_time.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

/// فئة للتعامل مع بيانات أوقات الصلاة في قاعدة البيانات
class AdhanTimesDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final String _tableName = 'adhan_times';

  /// إدراج أوقات صلاة جديدة
  Future<int> insert(AdhanTimes adhanTimes) async {
    return await _databaseHelper.insert(_tableName, _toMap(adhanTimes));
  }

  /// تحديث أوقات صلاة موجودة
  Future<int> update(AdhanTimes adhanTimes) async {
    if (adhanTimes.id == null) {
      throw ArgumentError('لا يمكن تحديث أوقات صلاة بدون معرف');
    }

    return await _databaseHelper.update(
      _tableName,
      _toMap(adhanTimes),
      'id = ?',
      [adhanTimes.id],
    );
  }

  /// حذف أوقات صلاة بواسطة المعرف
  Future<int> delete(int id) async {
    return await _databaseHelper.delete(_tableName, 'id = ?', [id]);
  }

  /// تحويل نموذج أوقات الصلاة إلى خريطة بيانات
  Map<String, dynamic> _toMap(AdhanTimes adhanTimes) {
    return {
      'id': adhanTimes.id,
      'location_id': adhanTimes.locationId,
      'date': DateFormat('yyyy-MM-dd').format(adhanTimes.date),
      'fajr_time': adhanTimes.fajrTime,
      'sunrise_time': adhanTimes.sunriseTime,
      'dhuhr_time': adhanTimes.dhuhrTime,
      'asr_time': adhanTimes.asrTime,
      'maghrib_time': adhanTimes.maghribTime,
      'isha_time': adhanTimes.ishaTime,
    };
  }

  /// الحصول على أوقات الصلاة للفترة المحددة
  Future<List<AdhanTimes>> getByDateRange(
      DateTime startDate, DateTime endDate, int locationId) async {
    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

    final result = await _databaseHelper.query(
      _tableName,
      where: 'date BETWEEN ? AND ? AND location_id = ?',
      whereArgs: [startDateStr, endDateStr, locationId],
      orderBy: 'date ASC',
    );

    return result
        .map((map) => AdhanTimes(
              id: map['id'] as int?,
              locationId: map['location_id'] as int,
              date: DateTime.parse(map['date'] as String),
              fajrTime: map['fajr_time'] as String,
              sunriseTime: map['sunrise_time'] as String,
              dhuhrTime: map['dhuhr_time'] as String,
              asrTime: map['asr_time'] as String,
              maghribTime: map['maghrib_time'] as String,
              ishaTime: map['isha_time'] as String,
            ))
        .toList();
  }

  /// الحصول على أوقات الصلاة لليوم الحالي والموقع المحدد
  Future<AdhanTimes?> getTodayTimes(int locationId) async {
    final today = DateTime.now();
    return getByDateAndLocation(today, locationId);
  }

  /// الحصول على جميع أوقات الأذان
  Future<List<AdhanTimes>> getAll() async {
    final result =
        await _databaseHelper.query(_tableName, orderBy: 'date DESC');

    return result
        .map((map) => AdhanTimes(
              id: map['id'] as int?,
              locationId: map['location_id'] as int,
              date: DateTime.parse(map['date'] as String),
              fajrTime: map['fajr_time'] as String,
              sunriseTime: map['sunrise_time'] as String,
              dhuhrTime: map['dhuhr_time'] as String,
              asrTime: map['asr_time'] as String,
              maghribTime: map['maghrib_time'] as String,
              ishaTime: map['isha_time'] as String,
            ))
        .toList();
  }

  /// الحصول على أحدث أوقات أذان للموقع
  Future<AdhanTimes?> getLatest(int locationId) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'location_id = ?',
      whereArgs: [locationId],
      orderBy: 'date DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

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
  }

  /// التحقق من وجود أوقات صلاة لتاريخ وموقع محددين
  Future<bool> hasAdhanTimes(DateTime date, int locationId) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    final result = await _databaseHelper.query(
      _tableName,
      where: 'date = ? AND location_id = ?',
      whereArgs: [dateStr, locationId],
    );

    return result.isNotEmpty;
  }

  /// الحصول على أوقات الصلاة لتاريخ وموقع معينين
  Future<AdhanTimes?> getByDateAndLocation(
      DateTime date, int locationId) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    final result = await _databaseHelper.query(
      _tableName,
      where: 'date = ? AND location_id = ?',
      whereArgs: [dateStr, locationId],
    );

    if (result.isEmpty) {
      return null;
    }

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
  }
}
