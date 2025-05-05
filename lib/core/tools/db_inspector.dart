import '../../data/database/database_helper.dart';
import '../../data/database/database.dart';
import '../../data/models/location.dart';

/// أداة لفحص محتويات قاعدة البيانات وعرضها في الكونسول
class DbInspector {
  static final DbInspector _instance = DbInspector._internal();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  factory DbInspector() {
    return _instance;
  }

  DbInspector._internal();

  /// فحص هيكل جدول معين
  Future<void> inspectTableStructure(String tableName) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery("PRAGMA table_info($tableName)");

      print('=== هيكل جدول $tableName ===');
      for (var column in result) {
        print('${column['name']} (${column['type']})');
      }
      print('=======================');
    } catch (e) {
      print('خطأ في فحص هيكل الجدول: $e');
    }
  }

  /// عرض محتويات جدول معين
  Future<void> inspectTableContents(String tableName) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(tableName);

      print('=== محتويات جدول $tableName (${result.length} سجلات) ===');
      for (var row in result) {
        print(row);
      }
      print('=======================');
    } catch (e) {
      print('خطأ في فحص محتويات الجدول: $e');
    }
  }

  /// فحص هيكل ومحتويات جداول الموقع
  Future<void> inspectLocationTables() async {
    await inspectTableStructure(AppDatabase.tableLocation);
    await inspectTableContents(AppDatabase.tableLocation);

    await inspectTableStructure(AppDatabase.tableCurrentLocation);
    await inspectTableContents(AppDatabase.tableCurrentLocation);

    // فحص جداول الأذان
    await inspectAdhanTables();
  }

  /// فحص وإصلاح جداول الأذان
  Future<void> inspectAdhanTables() async {
    // فحص جدول أوقات الأذان
    await inspectTableStructure(AppDatabase.tableAdhanTimes);
    await inspectTableContents(AppDatabase.tableAdhanTimes);

    // فحص جدول الأذان الحالي
    await inspectTableStructure(AppDatabase.tableCurrentAdhan);
    await inspectTableContents(AppDatabase.tableCurrentAdhan);

    // إصلاح جدول الأذان الحالي إذا لزم الأمر
    await fixCurrentAdhanTable();
  }

  /// إصلاح جدول الأذان الحالي
  Future<void> fixCurrentAdhanTable() async {
    try {
      final db = await _dbHelper.database;

      // التحقق من وجود سجلات في جدول الأذان الحالي
      final records = await db.query(AppDatabase.tableCurrentAdhan);

      if (records.isEmpty) {
        print('جدول الأذان الحالي فارغ، سيتم إنشاء سجل جديد');

        // الحصول على معرف الموقع الحالي
        final currentLocationRecords =
            await db.query(AppDatabase.tableCurrentLocation);
        int locationId = 1; // قيمة افتراضية

        if (currentLocationRecords.isNotEmpty &&
            currentLocationRecords[0].containsKey('location_id')) {
          locationId = currentLocationRecords[0]['location_id'] as int;
        }

        // الحصول على التاريخ الحالي
        final now = DateTime.now();
        final formattedDate = now.toIso8601String().split('T')[0];

        // إنشاء سجل جديد في جدول الأذان الحالي
        await db.insert(AppDatabase.tableCurrentAdhan, {
          'id': 1,
          'location_id': locationId,
          'date': formattedDate,
          'fajr_time': '00:00',
          'sunrise_time': '00:00',
          'dhuhr_time': '00:00',
          'asr_time': '00:00',
          'maghrib_time': '00:00',
          'isha_time': '00:00',
        });

        print(
            'تم إنشاء سجل جديد في جدول الأذان الحالي بمعرف الموقع: $locationId والتاريخ: $formattedDate');
      } else {
        print('جدول الأذان الحالي يحتوي على سجلات (${records.length})');
      }
    } catch (e) {
      print('خطأ في إصلاح جدول الأذان الحالي: $e');
    }
  }

  /// إضافة مواقع متعددة إلى قاعدة البيانات
  Future<void> addPredefinedLocations() async {
    try {
      final db = await _dbHelper.database;

      // قائمة المواقع المحددة مسبقًا
      final locations = [
        Location(
            latitude: 21.4225,
            longitude: 39.8262,
            city: "مكة المكرمة",
            country: "المملكة العربية السعودية",
            timezone: "Asia/Riyadh",
            methodId: 4, // أم القرى
            madhab: "شافعي"),
        Location(
            latitude: 24.7136,
            longitude: 46.6753,
            city: "الرياض",
            country: "المملكة العربية السعودية",
            timezone: "Asia/Riyadh",
            methodId: 4,
            madhab: "حنبلي"),
        Location(
            latitude: 21.4858,
            longitude: 39.1925,
            city: "جدة",
            country: "المملكة العربية السعودية",
            timezone: "Asia/Riyadh",
            methodId: 4,
            madhab: "شافعي"),
        Location(
            latitude: 24.4539,
            longitude: 54.3773,
            city: "أبو ظبي",
            country: "الإمارات العربية المتحدة",
            timezone: "Asia/Dubai",
            methodId: 8, // منطقة الخليج
            madhab: "مالكي"),
        Location(
            latitude: 25.2048,
            longitude: 55.2708,
            city: "دبي",
            country: "الإمارات العربية المتحدة",
            timezone: "Asia/Dubai",
            methodId: 8,
            madhab: "شافعي"),
        Location(
            latitude: 30.0444,
            longitude: 31.2357,
            city: "القاهرة",
            country: "مصر",
            timezone: "Africa/Cairo",
            methodId: 5, // الأزهر
            madhab: "شافعي"),
        Location(
            latitude: 31.9454,
            longitude: 35.9284,
            city: "عمان",
            country: "الأردن",
            timezone: "Asia/Amman",
            methodId: 3,
            madhab: "حنفي"),
        Location(
            latitude: 33.8869,
            longitude: 35.5131,
            city: "بيروت",
            country: "لبنان",
            timezone: "Asia/Beirut",
            methodId: 3,
            madhab: "حنفي"),
        Location(
            latitude: 36.7372,
            longitude: 3.0864,
            city: "الجزائر",
            country: "الجزائر",
            timezone: "Africa/Algiers",
            methodId: 3,
            madhab: "مالكي"),
        Location(
            latitude: 33.5731,
            longitude: -7.5898,
            city: "الدار البيضاء",
            country: "المغرب",
            timezone: "Africa/Casablanca",
            methodId: 3,
            madhab: "مالكي"),
      ];

      // حذف جميع المواقع الموجودة (اختياري)
      // await db.delete(AppDatabase.tableLocation);

      int successCount = 0;

      // إضافة المواقع إلى قاعدة البيانات
      for (var location in locations) {
        try {
          final id =
              await db.insert(AppDatabase.tableLocation, location.toMap());
          print('تم إدراج الموقع: ${location.city} بمعرف: $id');
          successCount++;
        } catch (e) {
          print('خطأ في إدراج البيانات: $e');
        }
      }

      print('تم إضافة $successCount موقع من أصل ${locations.length}');
    } catch (e) {
      print('خطأ في إضافة المواقع المحددة مسبقًا: $e');
    }
  }

  /// إصلاح جدول الموقع الحالي
  Future<void> fixCurrentLocationTable() async {
    try {
      final db = await _dbHelper.database;

      // التحقق من وجود الحقل location_id
      final columns = await db
          .rawQuery("PRAGMA table_info(${AppDatabase.tableCurrentLocation})");
      bool hasLocationId = false;

      for (var column in columns) {
        if (column['name'] == 'location_id') {
          hasLocationId = true;
          break;
        }
      }

      if (!hasLocationId) {
        // حفظ البيانات الحالية إذا وجدت
        final existingData = await db.query(AppDatabase.tableCurrentLocation);

        // حذف الجدول القديم
        await db.execute(
            "DROP TABLE IF EXISTS ${AppDatabase.tableCurrentLocation}");

        // إنشاء الجدول بالهيكل الصحيح
        await db.execute('''
          CREATE TABLE ${AppDatabase.tableCurrentLocation} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            location_id INTEGER NOT NULL
          )
        ''');

        print(
            'تم إعادة إنشاء جدول ${AppDatabase.tableCurrentLocation} بالهيكل الصحيح');

        // استعادة البيانات إذا كانت موجودة
        if (existingData.isNotEmpty) {
          for (var data in existingData) {
            if (data.containsKey('location_id')) {
              await db.insert(AppDatabase.tableCurrentLocation,
                  {'location_id': data['location_id']});
              print('تمت استعادة بيانات الموقع الحالي');
            }
          }
        }
      } else {
        print('جدول ${AppDatabase.tableCurrentLocation} بهيكل صحيح');
      }
    } catch (e) {
      print('خطأ في إصلاح جدول الموقع الحالي: $e');
    }
  }
}
