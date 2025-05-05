import 'package:zadulmuslihin/core/tools/db_inspector.dart';
import 'package:zadulmuslihin/data/database/current_adhan_dao.dart';
import 'package:zadulmuslihin/data/database/database_helper.dart';
import 'package:zadulmuslihin/data/database/database_manager.dart';
import 'package:zadulmuslihin/data/database/database.dart';

/// مهيئ التطبيق - مسؤول عن تهيئة الخدمات والبيانات عند بدء التطبيق
class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();
  final CurrentAdhanDao _currentAdhanDao = CurrentAdhanDao();
  final DbInspector _dbInspector = DbInspector();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isInitialized = false;

  factory AppInitializer() {
    return _instance;
  }

  AppInitializer._internal();

  /// تهيئة التطبيق وإعداد البيانات الأساسية
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. تهيئة قاعدة البيانات وإعداد البيانات الأولية
    await DatabaseManager.instance.initialize();



    // 3. فحص وإصلاح جداول الأذان والموقع
    await _dbInspector.inspectLocationTables();
    await _dbInspector.inspectAdhanTables();

    // 4. تحديث بيانات الأذان الحالي
    await _currentAdhanDao.UpdateCurrentAdhan();

    _isInitialized = true;
  }

  /// طباعة معلومات الجداول الحالية في الديباغ كونسول
  Future<void> logDatabaseInfo() async {
    print('\n===== معلومات قاعدة البيانات =====');
    try {
      // الحصول على قائمة جميع الجداول
      final db = await _dbHelper.database;
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'");

      print('الجداول الموجودة: ${tables.length}');
      for (var table in tables) {
        String tableName = table['name'] as String;
        print('\n----- جدول: $tableName -----');

        // عرض هيكل الجدول
        final columns = await db.rawQuery("PRAGMA table_info($tableName)");
        print('عدد الأعمدة: ${columns.length}');

        for (var column in columns) {
          print(
              '${column['name']} (${column['type']})${column['pk'] == 1 ? ' - مفتاح أساسي' : ''}');
        }

        // عرض عدد السجلات
        final count =
            await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
        print('عدد السجلات: ${count.first['count']}');
      }

      // فحص خاص لجدول الأذان الحالي
      print('\n----- تفاصيل جدول الأذان الحالي -----');
      final currentAdhanStructure = await db
          .rawQuery("PRAGMA table_info(${AppDatabase.tableCurrentAdhan})");

      print('هيكل جدول الأذان الحالي:');
      for (var column in currentAdhanStructure) {
        print('${column['name']} (${column['type']})');
      }

      // التحقق من وجود الأعمدة المطلوبة
      bool hasLocationId = currentAdhanStructure
          .any((column) => column['name'] == 'location_id');
      bool hasDate =
          currentAdhanStructure.any((column) => column['name'] == 'date');
      bool hasFajrTime =
          currentAdhanStructure.any((column) => column['name'] == 'fajr_time');

      print('يحتوي على عمود location_id: $hasLocationId');
      print('يحتوي على عمود date: $hasDate');
      print('يحتوي على عمود fajr_time: $hasFajrTime');
    } catch (e) {
      print('خطأ في استعراض معلومات قاعدة البيانات: $e');
    }

    print('===== نهاية معلومات قاعدة البيانات =====\n');

    // فحص جداول قاعدة البيانات وعرض المعلومات
    await _dbInspector.inspectLocationTables();
    await _dbInspector.inspectAdhanTables();
  }
}
