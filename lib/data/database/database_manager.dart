import 'dart:async';
import '../models/daily_task.dart';
import 'database_helper.dart';
import 'database.dart';
import '../models/islamic_information.dart';
import '../models/daily_message.dart';
import '../models/thought.dart';
import '../models/location.dart'; // in database.dart
import '../models/my_library.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:zadulmuslihin/data/database/my_library_dao.dart';
import 'package:intl/intl.dart';

/// مدير قاعدة البيانات المسؤول عن تهيئة وتعبئة البيانات
class DatabaseManager {
  static final DatabaseManager instance = DatabaseManager._privateConstructor();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool _isInitialized = false;

  DatabaseManager._privateConstructor();

  /// تهيئة قاعدة البيانات وتعبئتها بالبيانات الأولية
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _databaseHelper.database; // التأكد من إنشاء قاعدة البيانات
    await populateInitialData();

    _isInitialized = true;
  }

  /// تعبئة البيانات الأولية
  Future<void> populateInitialData() async {
    /*
    // تعبئة المعلومات الإسلامية
    final infos =
        await _databaseHelper.query(AppDatabase.tableIslamicInformation);
    if (infos.isEmpty) {
      await _populateIslamicInformation();
    }*/

    // تعبئة الرسائل اليومية
    final messages = await _databaseHelper.query(AppDatabase.tableDailyMessage);
    if (messages.isEmpty) {
      await _populateDailyMessages();
    }

    // تعبئة الأفكار
    final thoughts = await _databaseHelper.query(AppDatabase.tableThought);
    if (thoughts.isEmpty) {
      await _populateThoughts();
    }
    // تعبئة المهام اليومية
    final tasks = await _databaseHelper.query(AppDatabase.tableDailyTask);
    if (tasks.isEmpty) {
      await _populateDailyTasks();
    }
    // تعبئة المواقع
    final locations = await _databaseHelper.query(AppDatabase.tableLocation);
    if (locations.isEmpty) {
      await _populateLocations();
    }

    // ثم تعبئة الموقع الحالي
    final currentLocation =
        await _databaseHelper.query(AppDatabase.tableCurrentLocation);
    if (currentLocation.isEmpty) {
      await _populateCurrentLocation();
    }

    // تعبئة أوقات الأذان
    final adhanTimes = await _databaseHelper.query(AppDatabase.tableAdhanTimes);
    if (adhanTimes.isEmpty) {
      await _populateAdhanTimes();
    }

    final currentAdhan =
        await _databaseHelper.query(AppDatabase.tableCurrentAdhan);
    if (currentAdhan.isEmpty) {
      await _populateCurrentAdhan();
    }

    // تعبئة المكتبة بالبيانات الافتراضية
    final library = await _databaseHelper.query(AppDatabase.tableMyLibrary);
    if (library.isEmpty) {
      await _populateMyLibrary();
    }
    // تعبئة اوقات الصل
  }

  /// تعبئة المهام اليومية
  /// رياضة, عادات ,اهداف
  /// 5 رياضة و3 اهداف و2 عادة اضافة
  Future<void> _populateDailyTasks() async {
    final tasks = [
      DailyTask(
          title: "ضغط Push-ups",
          completed: false,
          workOn: false,
          category: 1),
      DailyTask(  
          title: "جري",
          completed: false,
          workOn: false,
          category: 1),
      DailyTask(
          title: "Squats القرفصاء ",
          completed: false,
          workOn: false,
          category: 1),
      DailyTask(
          title: "Plank بلانك",
          completed: false,
          workOn: false,
          category: 1),
      DailyTask(
          title: "Dips رفع",
          completed: false,
          workOn: false,
          category: 1),
      DailyTask(
          title: "Crunches تمرين المعدة",
          completed: false,
          workOn: false,
          category: 1),
      DailyTask(
          title: "تعلم السيرة",
          completed: false,
          workOn: false,
          category: 2),
      DailyTask(
          title: " x قراءة كتاب",
          completed: false,
          workOn: false,
          category: 2),
      DailyTask(
          title: "استماع درس عقيدة",
          completed: false,
          workOn: false,
          category: 2),
      DailyTask(
          title: "محاسبة النفس",
          completed: false,
          workOn: false,
          category: 3),
      DailyTask(
          title: "تزكية",
          completed: false,
          workOn: false,
          category: 3),
    ];

    for (var task in tasks) {
      await _databaseHelper.insert(AppDatabase.tableDailyTask, task.toMap());
    }
  }

  /// تعبئة المعلومات الإسلامية
  Future<void> _populateIslamicInformation() async {
    final informations = [
      IslamicInformation(
          title: "أركان الإسلام",
          content:
              "أركان الإسلام خمسة: شهادة أن لا إله إلا الله وأن محمداً رسول الله، وإقام الصلاة، وإيتاء الزكاة، وصوم رمضان، وحج البيت لمن استطاع إليه سبيلاً.",
          category: "أساسيات الإسلام"),
      IslamicInformation(
          title: "أركان الإيمان",
          content:
              "أركان الإيمان ستة: الإيمان بالله، وملائكته، وكتبه، ورسله، واليوم الآخر، والقدر خيره وشره.",
          category: "العقيدة"),
      IslamicInformation(
          title: "شروط الصلاة",
          content:
              "شروط الصلاة: الإسلام، العقل، البلوغ، دخول الوقت، الطهارة من الحدث، الطهارة من النجس، ستر العورة، استقبال القبلة، النية.",
          category: "الصلاة"),
    ];

    for (var info in informations) {
      await _databaseHelper.insert(
          AppDatabase.tableIslamicInformation, info.toMap());
    }
  }

  /// تعبئة الرسائل اليومية
  Future<void> _populateDailyMessages() async {
    final currentDate = DateTime.now();

    final messages = [
      DailyMessage(
          title: "الإخلاص في العمل",
          content: "اجعل نيتك خالصة لله في كل أعمالك، فإنما الأعمال بالنيات",
          category: "نوع الرسالة",
          date: currentDate),
      DailyMessage(
          title: "صلة الرحم",
          content: "حافظ على صلة الرحم فإنها تزيد في العمر وتوسع في الرزق",
          category: "معاملات",
          source: "من الأحاديث النبوية",
          date: currentDate),
      DailyMessage(
          title: "ذكر الله",
          content: "اجعل لسانك رطباً بذكر الله، فإن ذكر الله طمأنينة للقلوب",
          category: "عبادة",
          source: "من وصايا الصالحين",
          date: currentDate),
    ];

    for (var message in messages) {
      await _databaseHelper.insert(
          AppDatabase.tableDailyMessage, message.toMap());
    }
  }

  // إدخال المواقع الأساسية
  Future<void> _populateLocations() async {
    final List<Map<String, dynamic>> defaultLocations = [
      {
        'latitude': 24.7136,
        'longitude': 46.6753,
        'city': "الرياض",
        'country': "المملكة العربية السعودية",
        'timezone': "Asia/Riyadh",
        'method_id': 4,
        'madhab': "شافعي"
      },
      {
        'latitude': 21.4225,
        'longitude': 39.8262,
        'city': "مكة المكرمة",
        'country': "المملكة العربية السعودية",
        'timezone': "Asia/Riyadh",
        'method_id': 4,
        'madhab': "شافعي"
      },
      {
        'latitude': 31.9552,
        'longitude': 35.9453,
        'city': "القدس",
        'country': "فلسطين",
        'timezone': "Asia/Jerusalem",
        'method_id': 4,
        'madhab': "شافعي"
      },
    ];

    // إضافة المواقع الافتراضية
    for (var location in defaultLocations) {
      final locationId =
          await _databaseHelper.insert(AppDatabase.tableLocation, location);
      print("تم إضافة موقع: ${location['city']} بمعرف: $locationId");
    }
  }

  /// تعبئة الأفكار
  Future<void> _populateThoughts() async {
    final currentDate = DateTime.now();

    final thoughts = [
      Thought(
          title: "تفكر",
          content: "تفكر في خلق السماوات والأرض",
          category: 1,
          date: currentDate),
      Thought(
          title: "شكر",
          content: "التفكر في نعم الله التي لا تعد ولا تحصى",
          category: 1,
          date: currentDate),
      Thought(
          title: "تذكير",
          content: "تذكر الموت فإنه يزهد في الدنيا",
          category: 2,
          date: currentDate)
    ];

    for (var thought in thoughts) {
      await _databaseHelper.insert(AppDatabase.tableThought, thought.toMap());
    }
  }

  /// تعبئة المكتبة بالبيانات الافتراضية
  Future<void> _populateMyLibrary() async {
    final libraryItems = [
      // الأذكار
      MyLibrary(
        content:
            "أصبحنا وأصبح الملك لله والحمد لله لا إله إلا الله وحده لا شريك له",
        title: "أذكار الصباح",
        category: "أذكار",
        type: "ذكر",
        tabName: "أذكار",
      ),
      MyLibrary(
        content:
            "أمسينا وأمسى الملك لله والحمد لله لا إله إلا الله وحده لا شريك له",
        title: "أذكار المساء",
        category: "أذكار",
        type: "ذكر",
        tabName: "أذكار",
      ),
      MyLibrary(
        content: "اللهم افتح لي أبواب رحمتك",
        title: "دعاء دخول المسجد",
        category: "أذكار",
        type: "ذكر",
        tabName: "أذكار",
      ),

      // الأحاديث
      MyLibrary(
        content: "إنما الأعمال بالنيات وإنما لكل امرئ ما نوى",
        title: "النية والإخلاص",
        category: "أحاديث",
        source: "صحيح البخاري",
        type: "حديث",
        tabName: "أحاديث",
      ),
      MyLibrary(
        content: "من كان يؤمن بالله واليوم الآخر فليقل خيرا أو ليصمت",
        title: "آداب الكلام",
        category: "أحاديث",
        source: "صحيح البخاري",
        type: "حديث",
        tabName: "أحاديث",
      ),
      MyLibrary(
        content: "المسلم من سلم المسلمون من لسانه ويده",
        category: "أحاديث",
        title: "الأخلاق",
        source: "صحيح البخاري",
        type: "حديث",
        tabName: "أحاديث",
      ),

      // الآيات
      MyLibrary(
        content: "واتل عليهم نبا ابراهيم اذ قال لابيه وقومه ... ",
        title: "دعاء ابراهيم عليه السلام",
        category: "آيات",
        source: "الشعراء: 75",
        type: "آية",
        tabName: "آيات",
      ),
      MyLibrary(
        content: "لا اله الا انت سبحانك اني كنت من الظالمين",
        title: "دعاء يونس عليه السلام",
        category: "آيات",
        source: "الأنبياء: 87",
        type: "آية",
        tabName: "آيات",
      ),
      MyLibrary(
        content: "رب اشرح لي صدري , ويسر لي أمري  , واحلل عقدة من لساني ",
        title: "دعاء موسى عليه السلام",
        category: "آيات",
        source: "طه: 25-27",
        type: "آية",
        tabName: "آيات",
      ),

      // الدورات العلمية - العقيدة
      MyLibrary(
        content: "مقدمة في علم العقيدة الإسلامية، شرح مفصل لأركان الإيمان",
        title: "أساسيات العقيدة",
        type: "أساسيات العقيدة",
        tabName: "العقيدة",
        source: "الشيخ محمد",
        category: "مقررات",
        links: "youtube.com",
      ),
      MyLibrary(
        content: "شرح الأصول الثلاثة وأدلتها",
        title: "الأصول الثلاثة",
        type: "الأصول الثلاثة",
        tabName: "العقيدة",
        source: "الشيخ عبدالله",
        category: "مقررات",
        links: "google.com",
      ),

      // الدورات العلمية - الفقه
      MyLibrary(
        content: "أساسيات فقه العبادات، تعلم أحكام الطهارة والصلاة",
        title: "تعلم الصلاة",
        type: "تعلم الصلاة",
        tabName: "الفقه",
        source: "الشيخ أحمد",
        category: "مقررات",
        links: "youtube.com, google.com",
      ),
      MyLibrary(
        content: "أحكام الزكاة والصدقات في الإسلام",
        title: "فقه الزكاة",
        type: "فقه الزكاة",
        tabName: "الفقه",
        source: "الشيخ عبدالرحمن",
        category: "مقررات",
        links: "google.com",
      ),

      // الدورات العلمية - التفسير
      MyLibrary(
        content: "تفسير سورة البقرة آية بآية مع شرح المعاني والأحكام",
        title: "تفسير سورة البقرة",
        type: "تفسير1",
        tabName: "التفسير",
        source: "الشيخ عبدالله",
        category: "مقررات",
        links: "youtube.com",
      ),
      MyLibrary(
        content: "تفسير جزء عم مع شرح مفصل لكل سورة",
        title: "تفسير جزء عم",
        type: "تفسير2",
        tabName: "التفسير",
        source: "الشيخ سعيد",
        category: "مقررات",
        links: "google.com",
      ),

      // الدورات التربوية
      MyLibrary(
        content: "كيفية تربية الأبناء على القيم الإسلامية",
        title: "التربية الإسلامية للأبناء",
        type: "التربية 1",
        tabName: "التربية",
        source: "د. محمد",
        category: "مقررات",
        links: "youtube.com",
      ),
      MyLibrary(
        content: "تنمية المهارات الحياتية للأطفال وفق المنهج الإسلامي",
        title: "تنمية مهارات الأطفال",
        type: "تنمية 1",
        tabName: "التربية",
        source: "د. فاطمة",
        category: "مقررات",
        links: "google.com",
      ),

      // دورات اللغة العربية
      MyLibrary(
        content: "تعلم أساسيات النحو العربي للمبتدئين",
        title: "أساسيات النحو",
        type: " 1أساسيات النحو",
        tabName: "اللغة العربية",
        source: "أ. أحمد",
        category: "مقررات",
        links: "youtube.com",
      ),
      MyLibrary(
        content: "قواعد الإملاء العربي وتطبيقاتها",
        title: "قواعد الإملاء",
        type: "1قواعد الإملاء",
        tabName: "اللغة العربية",
        source: "أ. سارة",
        category: "مقررات",
        links: "google.com",
      ),

      // المقالات والمدونات
      MyLibrary(
        content: "مقدمة عن التدبر وأهميته في حياة المسلم",
        title: "التدبر في القرآن",
        type: "التدبر في القرآن1",
        tabName: "مقالات",
        source: "الشيخ عبدالله",  
        category: "مقالات إسلامية",
      ),
      MyLibrary(
        content: "كيف نستفيد من السيرة النبوية في حياتنا اليومية",
        title: "دروس من السيرة النبوية",
        type: "دروس من السيرة1 النبوية",
        tabName: "مقالات",
        source: "د. سعيد",
        category: "مقالات إسلامية",
      ),

      // نماذج المحتويات الأخرى
      MyLibrary(
        title: "عنوان الدرس",
        content: "المحتوى",
        source: "المصدر",
        tabName: "تبويب مخصص",
        links: "روابط",
        type: "التدبر في القرآن2",
        category: "مقالات إسلامية",
      ),
      MyLibrary(
        content: "الدرس الثالث",
        title: "الدرس الثالث",
        type: "معاملات1",
        category: "مقررات",
        tabName: "دروس",
      ),
      MyLibrary(
        content: "الدرس الثالث",
        title: "الدرس الثالث",
        type: "فقه1",
        category: "مقررات",
        tabName: "دروس",
      ),
      MyLibrary(
        content: "الدرس الثالث",
        title: "الدرس الثالث",
        type: "تزكية 1",
        category: "مقررات",
        tabName: "دروس",
      ),
    ];

    for (var item in libraryItems) {
      await _databaseHelper.insert(AppDatabase.tableMyLibrary, item.toJson());
    }
  }

  /// استعادة قاعدة البيانات وحذف جميع البيانات وإعادة التهيئة
  Future<void> resetAndInitialize() async {
    await _databaseHelper.resetDatabase();
    _isInitialized = false;
    await initialize();
  }

  Future<void> _populateCurrentLocation() async {
    final currentLocation =
        await _databaseHelper.query(AppDatabase.tableCurrentLocation);
    if (currentLocation.isEmpty) {
      await _databaseHelper
          .insert(AppDatabase.tableCurrentLocation, {'location_id': 1});
    }
  }

  Future<void> _populateCurrentAdhan() async {
    final currentAdhan =
        await _databaseHelper.query(AppDatabase.tableCurrentAdhan);
    if (currentAdhan.isEmpty) {
      await _databaseHelper.insert(AppDatabase.tableCurrentAdhan, {
        'location_id': 1,
        'date': DateTime.now().toIso8601String().split('T')[0],
        'fajr_time': '00:00',
        'sunrise_time': '00:00',
        'dhuhr_time': '00:00',
        'asr_time': '00:00',
        'maghrib_time': '00:00',
        'isha_time': '00:00',
      });
    }
  }

  Future<void> _populateAdhanTimes() async {
    try {
      final db = await _databaseHelper.database;
      final now = DateTime.now();
      final locations = await db.query(AppDatabase.tableLocation);

      // احصل على أوقات الصلاة لكل موقع
      for (var location in locations) {
        final locationId = location['id'] as int;

        // تحقق أولاً من وجود سجل لهذا الموقع والتاريخ
        final existingRecord = await db.query(
          AppDatabase.tableAdhanTimes,
          where: 'location_id = ? AND date = ?',
          whereArgs: [locationId, DateFormat('yyyy-MM-dd').format(now)],
        );

        // إذا كان السجل غير موجود، أو نريد استبداله
        final Map<String, dynamic> adhanMap = {
          'location_id': locationId,
          'date': DateFormat('yyyy-MM-dd').format(now),
          'fajr_time': '00:00',
          'sunrise_time': '00:00',
          'dhuhr_time': '00:00',
          'asr_time': '00:00',
          'maghrib_time': '00:00',
          'isha_time': '00:00',
        };

        // استخدام ConflictAlgorithm.replace لتجنب مشكلة UNIQUE constraint
        await db.insert(AppDatabase.tableAdhanTimes, adhanMap,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } catch (e) {
      print('خطأ في إدراج البيانات: $e');
    }
  }

  /// الحصول على قائمة بجميع الجداول وعدد السجلات في كل جدول
  Future<List<Map<String, dynamic>>> getAllTables() async {
    final db = await _databaseHelper.database;
    final tables = [
      AppDatabase.tableDailyTask,
      AppDatabase.tableDailyMessage,
      AppDatabase.tableThought,
      AppDatabase.tableLocation,
      AppDatabase.tableCurrentLocation,
      AppDatabase.tableAdhanTimes,
      AppDatabase.tableCurrentAdhan,
      AppDatabase.tableMyLibrary,
      AppDatabase.tableIslamicInformation,
      AppDatabase.tableDailyWorship,
      AppDatabase.tableWorshipHistory,
      AppDatabase.tableThoughtHistory,
    ];

    List<Map<String, dynamic>> result = [];
    for (var table in tables) {
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $table'));
      result.add({
        'name': table,
        'count': count,
      });
    }
    return result;
  }

  /// حذف جدول معين
  Future<void> deleteTable(String tableName) async {
    final db = await _databaseHelper.database;
    await db.delete(tableName);
  }

  /// نسخ قاعدة البيانات
  Future<void> backupDatabase() async {
    final db = await _databaseHelper.database;
    final dbPath = db.path;
    // هنا يمكن إضافة كود لنسخ قاعدة البيانات إلى مكان آخر
    // مثل حفظ نسخة في التخزين المحلي أو رفعها إلى السحابة
  }

  /// استعادة قاعدة البيانات
  Future<void> restoreDatabase() async {
    final db = await _databaseHelper.database;
    final dbPath = db.path;
    // هنا يمكن إضافة كود لاستعادة قاعدة البيانات من نسخة احتياطية
    // مثل استرجاع نسخة من التخزين المحلي أو من السحابة
  }
}
