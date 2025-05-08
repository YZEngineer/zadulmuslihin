import 'dart:async';
import '../models/daily_task.dart';
import 'database_helper.dart';
import 'database.dart';
import '../models/hadith.dart';
import '../models/athkar.dart';
import '../models/quran_verses.dart';
import '../models/islamic_information.dart';
import '../models/daily_message.dart';
import '../models/thought.dart';
import '../models/location.dart'; // in database.dart

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
    // تعبئة الأحاديث النبوية
    final hadiths = await _databaseHelper.query(AppDatabase.tableHadith);
    if (hadiths.isEmpty) {
      await _populateHadiths();
    }

    // تعبئة الأذكار
    final athkars = await _databaseHelper.query(AppDatabase.tableAthkar);
    if (athkars.isEmpty) {
      await _populateAthkar();
    }

    // تعبئة آيات القرآن المختارة
    final verses = await _databaseHelper.query(AppDatabase.tableQuranVerses);
    if (verses.isEmpty) {
      await _populateQuranVerses();
    }

    // تعبئة المعلومات الإسلامية
    final infos =
        await _databaseHelper.query(AppDatabase.tableIslamicInformation);
    if (infos.isEmpty) {
      await _populateIslamicInformation();
    }

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
    final currentLocation =
        await _databaseHelper.query(AppDatabase.tableCurrentLocation);
    if (currentLocation.isEmpty) {
      await _populateCurrentLocation();
    }

    final adhanTimes = await _databaseHelper.query(AppDatabase.tableAdhanTimes);
    if (adhanTimes.isEmpty) {
      await _populateAdhanTimes();
    }
    final currentAdhan =
        await _databaseHelper.query(AppDatabase.tableCurrentAdhan);
    if (currentAdhan.isEmpty) {
      await _populateCurrentAdhan();
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
          isCompleted: false,
          workOn: false,
          category: 1),
      DailyTask(title: "جري", isCompleted: false, workOn: false, category: 1),
      DailyTask(
          title: "Squats القرفصاء ",
          isCompleted: false,
          workOn: false,
          category: 1),
      DailyTask(
          title: "Plan بلانك", isCompleted: false, workOn: false, category: 1),
      DailyTask(
          title: "Dips رفع", isCompleted: false, workOn: false, category: 1),
      DailyTask(
          title: "Crunches تمرين المعدة",
          isCompleted: false,
          workOn: false,
          category: 1),
      DailyTask(
          title: "تعلم السيرة", isCompleted: false, workOn: false, category: 2),
      DailyTask(
          title: " x قراءة كتاب",
          isCompleted: false,
          workOn: false,
          category: 2),
      DailyTask(
          title: "استماع درس عقيدة",
          isCompleted: false,
          workOn: false,
          category: 2),
      DailyTask(
          title: "محاسبة النفس",
          isCompleted: false,
          workOn: false,
          category: 3),
      DailyTask(title: "تزكية", isCompleted: false, workOn: false, category: 3),
    ];

    for (var task in tasks) {
      await _databaseHelper.insert(AppDatabase.tableDailyTask, task.toMap());
    }
  }

  /// تعبئة الأحاديث النبوية
  Future<void> _populateHadiths() async {
    final hadiths = [
      Hadith(
          content: "إنما الأعمال بالنيات وإنما لكل امرئ ما نوى",
          title: "النية والإخلاص",
          source: "صحيح البخاري"),
      Hadith(
          content: "من كان يؤمن بالله واليوم الآخر فليقل خيرا أو ليصمت",
          title: "آداب الكلام",
          source: "صحيح البخاري"),
      Hadith(
          content: "المسلم من سلم المسلمون من لسانه ويده",
          title: "الأخلاق",
          source: "صحيح البخاري"),
    ];

    for (var hadith in hadiths) {
      await _databaseHelper.insert(AppDatabase.tableHadith, hadith.toMap());
    }
  }

  /// تعبئة الأذكار
  Future<void> _populateAthkar() async {
    final athkars = [
      Athkar(
          content:
              "أصبحنا وأصبح الملك لله والحمد لله لا إله إلا الله وحده لا شريك له",
          title: "أذكار الصباح"),
      Athkar(
          content:
              "أمسينا وأمسى الملك لله والحمد لله لا إله إلا الله وحده لا شريك له",
          title: "أذكار المساء"),
      Athkar(content: "اللهم افتح لي أبواب رحمتك", title: "دعاء دخول المسجد"),
    ];

    for (var athkar in athkars) {
      await _databaseHelper.insert(AppDatabase.tableAthkar, athkar.toMap());
    }
  }

  /// تعبئة آيات القرآن المختارة
  Future<void> _populateQuranVerses() async {
    final verses = [
      QuranVerses(
          text: "واتل عليهم نبا ابراهيم اذ قال لابيه وقومه ... ",
          source: "الشعراء: 75",
          theme: "دعاء ابراهيم عليه السلام"),
      QuranVerses(
          text: "لا اله الا انت سبحانك اني كنت من الظالمين",
          source: "...",
          theme: "...."),
      QuranVerses(
          text: "رب اشرح لي صدري , ويسر لي أمري  , واحلل عقدة من لساني ",
          source: "طه: 25-27",
          theme: "دعاء موسى عليه السلام"),
    ];

    for (var verse in verses) {
      await _databaseHelper.insert(AppDatabase.tableQuranVerses, verse.toMap());
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
          category: 1,
          source: "من أقوال السلف",
          date: currentDate),
      DailyMessage(
          title: "صلة الرحم",
          content: "حافظ على صلة الرحم فإنها تزيد في العمر وتوسع في الرزق",
          category: 2,
          source: "من الأحاديث النبوية",
          date: currentDate),
      DailyMessage(
          title: "ذكر الله",
          content: "اجعل لسانك رطباً بذكر الله، فإن ذكر الله طمأنينة للقلوب",
          category: 3,
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


    final List<Location> defaultLocations = [
      Location(
          latitude: 24.7136,
          longitude: 46.6753,
          city: "الرياض",
          country: "المملكة العربية السعودية",
          timezone: "Asia/Riyadh",
          methodId: 1,
          madhab: "Hanafi"),
      Location(
          latitude: 21.4225,
          longitude: 39.8262,
          city: "مكة المكرمة",
          country: "المملكة العربية السعودية",
          timezone: "Asia/Riyadh",
          methodId: 1,
          madhab: "Hanafi"),
      Location(
          latitude: 31.9552,
          longitude: 35.9453,
          city: "القدس",
          country: "فلسطين",
          timezone: "Asia/Jerusalem",
        methodId: 1,
        madhab: "Hanafi"),
    ];

    // إضافة المواقع الافتراضية
    for (var location in defaultLocations) {
      await _databaseHelper.insert(AppDatabase.tableLocation, location.toMap());
    }
  }

  /// تعبئة الأفكار
  Future<void> _populateThoughts() async {
    final currentDate = DateTime.now();

    final thoughts = [
      Thought(title: "تفكر",content: "تفكر في خلق السماوات والأرض",
          category: 1,date: currentDate),
      Thought(title: "شكر",content: "التفكر في نعم الله التي لا تعد ولا تحصى",
          category: 1,date: currentDate),
      Thought(title: "تذكير",content: "تذكر الموت فإنه يزهد في الدنيا",
          category: 2,date: currentDate)
    ];

    for (var thought in thoughts) {
      await _databaseHelper.insert(AppDatabase.tableThought, thought.toMap());
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
    final currentAdhan = await _databaseHelper.query(AppDatabase.tableCurrentAdhan);
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
    // التأكد من وجود سجل لكل موقع في جدول أوقات الأذان الحالية
    try {
      final now = DateTime.now().toIso8601String().split('T')[0];
      final List<Map<String, dynamic>> locations =
          await _databaseHelper.query(AppDatabase.tableLocation);

      for (var location in locations) {
        int locationId = location['id'];

        // إضافة سجل في جدول أوقات الأذان لكل موقع للتاريخ الحالي
        // استخدام ConflictAlgorithm.replace لتجنب مشكلة UNIQUE constraint
        await _databaseHelper.insert(
          AppDatabase.tableAdhanTimes,
          {
            'location_id': locationId,
            'date': now,
            'fajr_time': '00:00',
            'sunrise_time': '00:00',
            'dhuhr_time': '00:00',
            'asr_time': '00:00',
            'maghrib_time': '00:00',
            'isha_time': '00:00',
          },
        );
      }
    } catch (e) {
      print(e);
      print("error in populateAdhanTimes");
    }
  }
}
