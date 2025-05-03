import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_task.dart';
import '../models/adhan_time.dart';
import '../models/islamic_information.dart';
import '../models/hadith.dart';
import '../models/athkar.dart';
import '../models/daily_prayers.dart';
import '../models/location.dart';
import '../models/current_adhan.dart';
import 'database_helper.dart';
import 'daily_task_dao.dart';
import 'adhan_times_dao.dart';
import 'islamic_information_dao.dart';
import 'hadith_dao.dart';
import 'athkar_dao.dart';
import 'daily_prayer_dao.dart';
import 'location_dao.dart';
import 'current_location_dao.dart';
import 'current_adhan_dao.dart';

class DatabaseManager {
  static final DatabaseManager instance = DatabaseManager._privateConstructor();

  final dailyTaskDao = DailyTaskDao();
  final adhanTimesDao = AdhanTimesDao();
  final islamicInformationDao = IslamicInformationDao();
  final hadithDao = HadithDao();
  final athkarDao = AthkarDao();
  final dailyPrayerDao = DailyPrayerDao();
  final locationDao = LocationDao();
  final currentLocationDao = CurrentLocationDao();
  final currentAdhanDao = CurrentAdhanDao();

  DatabaseManager._privateConstructor();

  /// إعادة تعيين قاعدة البيانات
  Future<void> resetDatabase() async {
    print('جاري إعادة تعيين قاعدة البيانات...');
    // استخدام دالة إعادة التعيين في DatabaseHelper
    await DatabaseHelper.instance.resetDatabase();
  }

  /// تهيئة قاعدة البيانات
  Future<void> initializeDatabase() async {
    try {
      // التأكد من أن قاعدة البيانات جاهزة
      await DatabaseHelper.instance.database;

      // تحميل بعض البيانات الافتراضية للاختبار
      await _loadSampleData();
    } catch (e) {
      print('خطأ أثناء تهيئة قاعدة البيانات: $e');

      // في حالة وجود مشكلة، نقوم بإعادة تعيين قاعدة البيانات
      print('جاري إعادة تعيين قاعدة البيانات...');
      await DatabaseHelper.instance.resetDatabase();

      // محاولة تحميل البيانات مرة أخرى
      await _loadSampleData();
    }
  }

  /// تحميل بيانات افتراضية للاختبار
  Future<void> _loadSampleData() async {
    await _loadSampleLocations();
    await _loadSampleAdhanTimes();
    await _loadSampleCurrentAdhan();
    await _loadSampleAthkar();
    await _loadSampleHadiths();
    await _loadSampleDailyPrayers();
    await _loadSampleIslamicInformation();
  }

  // تحميل مواقع افتراضية
  Future<void> _loadSampleLocations() async {
    // التحقق من وجود مواقع مسبقًا
    List<Location> existingLocations = await locationDao.getAllLocations();
    if (existingLocations.isNotEmpty) {
      return; // لا تقم بإضافة مواقع إذا كانت موجودة بالفعل
    }

    // قائمة المواقع الافتراضية
    List<Location> defaultLocations = [
      Location(
        name: "مكة المكرمة، السعودية",
        latitude: 21.4225,
        longitude: 39.8262,
        country: "السعودية",
        city: "مكة المكرمة",
        methodId: 4, // أم القرى
      ),
      Location(
        name: "المدينة المنورة، السعودية",
        latitude: 24.5247,
        longitude: 39.5692,
        country: "السعودية",
        city: "المدينة المنورة",
        methodId: 4,
      ),
      Location(
        name: "القاهرة، مصر",
        latitude: 30.0444,
        longitude: 31.2357,
        country: "مصر",
        city: "القاهرة",
        methodId: 5, // الأزهر
      ),
      Location(
        name: "إسطنبول، تركيا",
        latitude: 41.0082,
        longitude: 28.9784,
        country: "تركيا",
        city: "إسطنبول",
        methodId: 2, // اتحاد منظمات إسلامية في أوروبا
      ),
    ];

    // إضافة المواقع الافتراضية
    for (Location location in defaultLocations) {
      int locationId = await locationDao.insert(location);

      // تعيين أول موقع كموقع افتراضي
      if (defaultLocations.indexOf(location) == 0) {
        await currentLocationDao.setCurrentLocation(locationId);
      }
    }
  }

  // تحميل الأذان الحالي الافتراضي
  Future<void> _loadSampleCurrentAdhan() async {
    // التحقق من وجود أذان حالي مسبقًا
    bool hasCurrentAdhan = await currentAdhanDao.hasCurrentAdhan();
    if (hasCurrentAdhan) {
      return; // لا تقم بإضافة أذان حالي إذا كان موجوداً بالفعل
    }

    // استخراج المعلومات من أوقات الأذان اليوم
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    AdhanTimes? todayTimes =
        await adhanTimesDao.getAdhanTimesByDate(DateTime.parse(today));

    if (todayTimes != null) {
      // إنشاء كائن الأذان الحالي
      CurrentAdhan currentAdhan = CurrentAdhan(
        date: DateTime.parse(today),
        fajrTime: todayTimes.fajrTime,
        sunriseTime: todayTimes.sunriseTime,
        dhuhrTime: todayTimes.dhuhrTime,
        asrTime: todayTimes.asrTime,
        maghribTime: todayTimes.maghribTime,
        ishaTime: todayTimes.ishaTime,
        suhoorTime: todayTimes.suhoorTime,
      );

      // حفظ الأذان الحالي في قاعدة البيانات
      await currentAdhanDao.setCurrentAdhan(currentAdhan);
    }
  }

  // تحويل وقت بتنسيق HH:MM إلى دقائق منذ منتصف الليل
  int _timeToMinutes(String time) {
    List<String> parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  // تحميل أوقات أذان افتراضية
  Future<void> _loadSampleAdhanTimes() async {
    // اليوم الحالي
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // إنشاء أوقات الأذان لليوم الحالي
    AdhanTimes todayAdhanTimes = AdhanTimes(
      date: DateTime.parse(today),
      fajrTime: '04:30',
      sunriseTime: '06:05',
      dhuhrTime: '12:15',
      asrTime: '15:30',
      maghribTime: '18:10',
      ishaTime: '19:45',
      suhoorTime: '03:45',
    );

    // حفظ أوقات الأذان في قاعدة البيانات
    await adhanTimesDao.save(todayAdhanTimes);

    // إنشاء أوقات الأذان للغد
    String tomorrow =
        DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 1)));

    AdhanTimes tomorrowAdhanTimes = AdhanTimes(
      date: DateTime.parse(tomorrow),
      fajrTime: '04:28',
      sunriseTime: '06:03',
      dhuhrTime: '12:15',
      asrTime: '15:32',
      maghribTime: '18:12',
      ishaTime: '19:47',
      suhoorTime: '03:43',
    );

    // حفظ أوقات الأذان للغد في قاعدة البيانات
    await adhanTimesDao.save(tomorrowAdhanTimes);
  }

  // تحميل بعض الأذكار
  Future<void> _loadSampleAthkar() async {
    List<Athkar> athkarList = [
      Athkar(
        content: 'سبحان الله',
        category: 'أذكار الصباح',
        count: 33,
        fadl:
            'من ذكره في الصباح والمساء ثلاثة وثلاثين مرة كتبت له ثلاثة وثلاثون حسنة',
      ),
      Athkar(
        content: 'الحمد لله',
        category: 'أذكار الصباح',
        count: 33,
        fadl:
            'من ذكره في الصباح والمساء ثلاثة وثلاثين مرة كتبت له ثلاثة وثلاثون حسنة',
      ),
      Athkar(
        content: 'الله أكبر',
        category: 'أذكار الصباح',
        count: 33,
        fadl:
            'من ذكره في الصباح والمساء ثلاثة وثلاثين مرة كتبت له ثلاثة وثلاثون حسنة',
      ),
      Athkar(
        content: 'أستغفر الله',
        category: 'أذكار المساء',
        count: 100,
        fadl: 'من استغفر الله مائة مرة غفرت ذنوبه ولو كانت مثل زبد البحر',
      ),
    ];

    for (var athkar in athkarList) {
      await athkarDao.insert(athkar);
    }
  }

  // تحميل بعض الأحاديث
  Future<void> _loadSampleHadiths() async {
    List<Hadith> hadiths = [
      Hadith(
        content: 'إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى',
        narrator: 'عمر بن الخطاب',
        source: 'متفق عليه',
        book: 'صحيح البخاري',
        hadithNumber: '1',
      ),
      Hadith(
        content: 'من حسن إسلام المرء تركه ما لا يعنيه',
        narrator: 'أبو هريرة',
        source: 'الترمذي',
        book: 'سنن الترمذي',
        hadithNumber: '2318',
      ),
    ];

    for (var hadith in hadiths) {
      await hadithDao.insert(hadith);
    }
  }

  // تحميل بعض الأدعية
  Future<void> _loadSampleDailyPrayers() async {
    List<DailyPrayer> prayers = [
      DailyPrayer(
        content:
            'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
        occasion: 'دعاء عام',
        arabic:
            'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
        translation:
            'ربنا أعطنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار',
        source: 'البقرة: 201',
      ),
      DailyPrayer(
        content:
            'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى، وَالتُّقَى، وَالْعَفَافَ، وَالْغِنَى',
        occasion: 'دعاء الصباح',
        arabic:
            'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى، وَالتُّقَى، وَالْعَفَافَ، وَالْغِنَى',
        translation: 'اللهم إني أسألك الهداية والتقوى والعفاف والغنى',
        source: 'صحيح مسلم',
      ),
    ];

    for (var prayer in prayers) {
      await dailyPrayerDao.insert(prayer);
    }
  }

  // تحميل بعض المعلومات الإسلامية
  Future<void> _loadSampleIslamicInformation() async {
    List<IslamicInformation> information = [
      IslamicInformation(
        title: 'أركان الإسلام',
        content:
            'أركان الإسلام خمسة: شهادة أن لا إله إلا الله وأن محمداً رسول الله، وإقام الصلاة، وإيتاء الزكاة، وصوم رمضان، وحج البيت لمن استطاع إليه سبيلا.',
        category: 'أساسيات الإسلام',
        source: 'حديث جبريل المشهور',
      ),
      IslamicInformation(
        title: 'أركان الإيمان',
        content:
            'أركان الإيمان ستة: الإيمان بالله، وملائكته، وكتبه، ورسله، واليوم الآخر، والقدر خيره وشره.',
        category: 'أساسيات الإسلام',
        source: 'حديث جبريل المشهور',
      ),
    ];

    for (var info in information) {
      await islamicInformationDao.insert(info);
    }
  }
}
