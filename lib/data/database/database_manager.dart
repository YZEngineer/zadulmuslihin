import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_task.dart';
import '../models/adhan_time.dart';
import '../models/islamic_information.dart';
import '../models/hadith.dart';
import '../models/athkar.dart';
import '../models/daily_worship.dart';
import '../models/location.dart';
import '../models/current_adhan.dart';
import 'database_helper.dart';
import 'daily_task_dao.dart';
import 'adhan_times_dao.dart';
import 'islamic_information_dao.dart';
import 'hadith_dao.dart';
import 'athkar_dao.dart';
import 'location_dao.dart';
import 'current_location_dao.dart';
import 'current_adhan_dao.dart';
import 'daily_worship_dao.dart';

class DatabaseManager {
  static final DatabaseManager instance = DatabaseManager._privateConstructor();

  final dailyTaskDao = DailyTaskDao();
  final adhanTimesDao = AdhanTimesDao();
  final islamicInformationDao = IslamicInformationDao();
  final hadithDao = HadithDao();
  final athkarDao = AthkarDao();
  final locationDao = LocationDao();
  final currentLocationDao = CurrentLocationDao();
  final currentAdhanDao = CurrentAdhanDao();
  final dailyWorshipDao = DailyWorshipDao();

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
    await _loadSampleIslamicInformation();
    await _loadSampleDailyWorship();
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
        fajrTime: todayTimes.fajrTime,
        sunriseTime: todayTimes.sunriseTime,
        dhuhrTime: todayTimes.dhuhrTime,
        asrTime: todayTimes.asrTime,
        maghribTime: todayTimes.maghribTime,
        ishaTime: todayTimes.ishaTime,
       
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
     
    );

    // حفظ أوقات الأذان في قاعدة البيانات
    await adhanTimesDao.save(todayAdhanTimes);
    await currentAdhanDao.setCurrentAdhan(todayAdhanTimes);


  }

  // تحميل بعض الأذكار
  Future<void> _loadSampleAthkar() async {
    List<Athkar> athkarList = [
      Athkar(
        content: 'الحمد لله',
        title: 'أذكار الصباح',
       
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

  // تحميل عبادات يومية افتراضية
  Future<void> _loadSampleDailyWorship() async {
    // التحقق من وجود عبادات يومية مسبقاً
    bool exists = await dailyWorshipDao.exists();
    if (exists) {
      return; // لا تقم بإضافة عبادات يومية إذا كانت موجودة بالفعل
    }

    // إنشاء عبادة يومية افتراضية
    DailyWorship defaultWorship = DailyWorship(
      fajrPrayer: false,
      dhuhrPrayer: false,
      asrPrayer: false,
      maghribPrayer: false,
      ishaPrayer: false,
      tahajjud: false,
      qiyam: false,
      quran: false,
      thikr: false,
    );

    // حفظ العبادة اليومية في قاعدة البيانات
    await dailyWorshipDao.saveDailyWorship(defaultWorship);
  }

  /// إدارة العبادات اليومية
  Future<void> updateDailyWorship(DailyWorship dailyWorship) async {
    await dailyWorshipDao.saveDailyWorship(dailyWorship);
  }

  Future<DailyWorship?> getDailyWorship() async {
    return await dailyWorshipDao.getDailyWorship();
  }
}
