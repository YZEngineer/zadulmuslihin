import 'package:sqflite/sqflite.dart';
import '../../data/database/database_helper.dart';
import '../../data/database/database.dart';
import '../../data/database/current_adhan_dao.dart';
import 'package:intl/intl.dart';

/// أداة لإصلاح جداول قاعدة البيانات
class TableFixer {
  static final TableFixer _instance = TableFixer._internal();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final CurrentAdhanDao _currentAdhanDao = CurrentAdhanDao();

  factory TableFixer() {
    return _instance;
  }

  TableFixer._internal();

  /// إصلاح جدول أوقات الأذان
  Future<void> fixAdhanTimesTable() async {
    try {
      final db = await _dbHelper.database;

      // التحقق من وجود الجدول وهيكلته
      final columns = await db
          .rawQuery("PRAGMA table_info(${AppDatabase.tableAdhanTimes})");

      // التحقق من وجود قيد UNIQUE على location_id و date
      final indexInfo = await db.rawQuery(
          "SELECT * FROM sqlite_master WHERE type='index' AND tbl_name='${AppDatabase.tableAdhanTimes}'");

      print(
          'جدول أوقات الأذان يحتوي على ${columns.length} عمود و ${indexInfo.length} فهرس');

      // إضافة سجلات لأوقات الأذان للموقع الحالي لكل موقع في الجدول
      // باستخدام تاريخ اليوم الحالي
      final locations = await db.query(AppDatabase.tableLocation);
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);

      print('إضافة أو تحديث سجلات أوقات الأذان لعدد ${locations.length} موقع');

      for (var location in locations) {
        int locationId = location['id'] as int;

        // إضافة سجل جديد مع التعامل مع قيود UNIQUE
        await db.insert(
          AppDatabase.tableAdhanTimes,
          {
            'location_id': locationId,
            'date': formattedDate,
            'fajr_time': '00:00',
            'sunrise_time': '00:00',
            'dhuhr_time': '00:00',
            'asr_time': '00:00',
            'maghrib_time': '00:00',
            'isha_time': '00:00',
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        print(
            'تم إضافة/تحديث سجل أوقات الأذان للموقع $locationId والتاريخ $formattedDate');
      }

      // التحقق من عدد السجلات بعد الإصلاح
      final recordCount = await db.rawQuery(
          'SELECT COUNT(*) as count FROM ${AppDatabase.tableAdhanTimes}');
      print(
          'عدد سجلات جدول أوقات الأذان بعد الإصلاح: ${recordCount.first['count']}');
    } catch (e) {
      print('خطأ في إصلاح جدول أوقات الأذان: $e');
    }
  }

  /// إصلاح جدول الأذان الحالي
  Future<void> fixCurrentAdhanTable() async {
    try {
      final db = await _dbHelper.database;

      // التحقق من وجود الجدول ومن بنيته
      bool tableRecreated = false;

      // التحقق من وجود الأعمدة المطلوبة في الجدول
      final columns = await db
          .rawQuery("PRAGMA table_info(${AppDatabase.tableCurrentAdhan})");

      // التحقق مما إذا كان الجدول يحتوي على عمود location_id
      bool hasLocationId = false;
      for (var column in columns) {
        if (column['name'] == 'location_id') {
          hasLocationId = true;
          break;
        }
      }

      if (!hasLocationId && columns.isNotEmpty) {
        print(
            'جدول الأذان الحالي لا يحتوي على العمود المطلوب (location_id)، سيتم إعادة إنشاؤه');

        // حذف الجدول الحالي وإعادة إنشائه
        await db
            .execute("DROP TABLE IF EXISTS ${AppDatabase.tableCurrentAdhan}");

        // إعادة إنشاء الجدول بالهيكل الصحيح
        await db.execute('''
          CREATE TABLE ${AppDatabase.tableCurrentAdhan} (
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
        tableRecreated = true;
      }

      // التحقق من وجود سجلات في جدول الأذان الحالي
      final records = await db.query(AppDatabase.tableCurrentAdhan);

      if (records.isEmpty || tableRecreated) {
        print('جدول الأذان الحالي فارغ، سيتم إصلاحه');
        await _currentAdhanDao.fixEmptyCurrentAdhanTable();
        // تحديث بيانات الأذان الحالي
        await _currentAdhanDao.UpdateCurrentAdhan();
        print('تم إصلاح جدول الأذان الحالي وتحديث البيانات');
      } else {
        print('جدول الأذان الحالي يحتوي على ${records.length} سجل');
      }
    } catch (e) {
      print('خطأ في إصلاح جدول الأذان الحالي: $e');
    }
  }
}
