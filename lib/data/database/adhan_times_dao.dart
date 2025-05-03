import 'package:sqflite/sqflite.dart';
import '../models/adhan_time.dart';
import 'database_helper.dart';

class AdhanTimesDao {
  final dbHelper = DatabaseHelper.instance;

  /// إدراج أوقات الأذان ليوم واحد
  Future<int> insert(AdhanTimes adhanTimes) async {
    Database db = await dbHelper.database;
    return await db.insert('adhan_times', adhanTimes.toMap());
  }

  /// تحديث أوقات الأذان ليوم معين
  Future<int> update(AdhanTimes adhanTimes) async {
    if (adhanTimes.id == null) {
      throw ArgumentError('لا يمكن تحديث أوقات الأذان بدون معرف');
    }

    Database db = await dbHelper.database;
    return await db.update(
      'adhan_times',
      adhanTimes.toMap(),
      where: 'id = ?',
      whereArgs: [adhanTimes.id],
    );
  }

  /// حفظ أوقات الأذان (إدراج جديد أو تحديث إذا كان موجوداً)
  Future<int> save(AdhanTimes adhanTimes) async {
    // التحقق إذا كان هناك أوقات أذان لهذا التاريخ
    AdhanTimes? existingTimes = await getAdhanTimesByDate(adhanTimes.date);

    if (existingTimes != null) {
      // تحديث مع الاحتفاظ بنفس المعرف
      return await update(adhanTimes.copyWith(id: existingTimes.id));
    } else {
      // إدراج جديد
      return await insert(adhanTimes);
    }
  }

  /// الحصول على أوقات الأذان حسب المعرف
  Future<AdhanTimes?> getAdhanTimesById(int id) async {
    Database db = await dbHelper.database;
    var results = await db.query(
      'adhan_times',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return AdhanTimes.fromMap(results.first);
  }

  /// الحصول على أوقات الأذان حسب التاريخ
  Future<AdhanTimes?> getAdhanTimesByDate(DateTime date) async {
    Database db = await dbHelper.database;
    var results = await db.query(
      'adhan_times',
      where: 'date = ?',
      whereArgs: [DateFormat('yyyy-MM-dd').format(date)],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return AdhanTimes.fromMap(results.first);
  }

  /// الحصول على قائمة أوقات الأذان لعدة أيام
  Future<List<AdhanTimes>> getAdhanTimesForRange(
      String startDate, String endDate) async {
    Database db = await dbHelper.database;
    var results = await db.query(
      'adhan_times',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC',
    );

    return results.map((map) => AdhanTimes.fromMap(map)).toList();
  }

  /// الحصول على جميع أوقات الأذان المخزنة
  Future<List<AdhanTimes>> getAllAdhanTimes() async {
    Database db = await dbHelper.database;
    var results = await db.query('adhan_times', orderBy: 'date ASC');

    return results.map((map) => AdhanTimes.fromMap(map)).toList();
  }

  /// حذف أوقات الأذان ليوم معين
  Future<int> deleteAdhanTimesByDate(String date) async {
    Database db = await dbHelper.database;
    return await db.delete(
      'adhan_times',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  /// حذف أوقات الأذان حسب المعرف
  Future<int> deleteAdhanTimesById(int id) async {
    Database db = await dbHelper.database;
    return await db.delete(
      'adhan_times',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// حذف جميع أوقات الأذان
  Future<int> deleteAllAdhanTimes() async {
    Database db = await dbHelper.database;
    return await db.delete('adhan_times');
  }
}
