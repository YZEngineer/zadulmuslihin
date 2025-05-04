import '../models/daily_worship.dart';
import 'database.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

/// فئة للتعامل مع بيانات العبادات اليومية في قاعدة البيانات
class DailyWorshipDao {
  final _databaseHelper = DatabaseHelper.instance;
  final String _tableName = AppDatabase.tableDailyWorship;

  /// إدراج عبادة يومية جديدة أو تحديث القائمة
  Future<int> insert(DailyWorship dailyWorship) async {
    return await _databaseHelper.insert(_tableName, dailyWorship.toMap());
  }

  /// تحديث عبادة يومية موجودة
  Future<int> update(DailyWorship dailyWorship) async {
    return await _databaseHelper
        .update(_tableName, dailyWorship.toMap(), 'id = ?', [dailyWorship.id]);
  }

  /// الحصول على عبادات يوم حسب المعرف
  Future<DailyWorship?> getById(int id) async {
    final result = await _databaseHelper.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      return null;
    }

    return DailyWorship.fromMap(result.first);
  }

  /// الحصول على جميع سجلات العبادات
  Future<List<DailyWorship>> getAll() async {
    final result = await _databaseHelper.query(_tableName);
    return result.map((map) => DailyWorship.fromMap(map)).toList();
  }

  /// تحديث حالة صلاة معينة
  Future<int> updatePrayerStatus(
      int id, String prayerName, bool completed) async {
    // تحديث حالة الصلاة المحددة
    final value = completed ? 1 : 0;
    final columnName = '${prayerName.toLowerCase()}_prayer';

    final result = await _databaseHelper.update(
        _tableName, {columnName: value}, 'id = ?', [id]);

    return result;
  }

  /// حذف سجل عبادة بواسطة المعرف
  Future<int> delete(int id) async {
    return await _databaseHelper.delete(
      _tableName,
      'id = ?',
      [id],
    );
  }

  /// الحصول على إحصائيات العبادات
  Future<Map<String, int>> getStatistics() async {
    final worships = await getAll();

    // تهيئة الإحصائيات
    Map<String, int> stats = {
      'fajr_completed': 0,
      'dhuhr_completed': 0,
      'asr_completed': 0,
      'maghrib_completed': 0,
      'isha_completed': 0,
      'tahajjud_completed': 0,
      'qiyam_completed': 0,
      'quran_completed': 0,
      'thikr_completed': 0,
      'total_records': worships.length,
    };

    // حساب الإحصائيات
    for (var worship in worships) {
      if (worship.fajrPrayer)
        stats['fajr_completed'] = (stats['fajr_completed'] ?? 0) + 1;
      if (worship.dhuhrPrayer)
        stats['dhuhr_completed'] = (stats['dhuhr_completed'] ?? 0) + 1;
      if (worship.asrPrayer)
        stats['asr_completed'] = (stats['asr_completed'] ?? 0) + 1;
      if (worship.maghribPrayer)
        stats['maghrib_completed'] = (stats['maghrib_completed'] ?? 0) + 1;
      if (worship.ishaPrayer)
        stats['isha_completed'] = (stats['isha_completed'] ?? 0) + 1;
      if (worship.tahajjud)
        stats['tahajjud_completed'] = (stats['tahajjud_completed'] ?? 0) + 1;
      if (worship.qiyam)
        stats['qiyam_completed'] = (stats['qiyam_completed'] ?? 0) + 1;
      if (worship.quran)
        stats['quran_completed'] = (stats['quran_completed'] ?? 0) + 1;
      if (worship.thikr)
        stats['thikr_completed'] = (stats['thikr_completed'] ?? 0) + 1;
    }

    return stats;
  }
}
