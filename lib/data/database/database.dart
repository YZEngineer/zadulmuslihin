/// ثوابت قاعدة البيانات
class DatabaseConstants {
  // اسم قاعدة البيانات
  static const String DATABASE_NAME = 'zad_muslimin.db';
  
  // إصدار قاعدة البيانات
  static const int DATABASE_VERSION = 1;
  
  // أسماء الجداول
  static const String TABLE_ADHAN_TIMES = 'adhan_times';
  static const String TABLE_CURRENT_ADHAN = 'current_adhan';
  static const String TABLE_ATHKAR = 'athkar';
  static const String TABLE_DAILY_TASK = 'daily_task';
  static const String TABLE_DAILY_WORSHIP = 'daily_worship';
  static const String TABLE_HADITH = 'hadith';
  static const String TABLE_ISLAMIC_INFORMATION = 'islamic_information';
  static const String TABLE_LOCATION = 'location';
  static const String TABLE_CURRENT_LOCATION = 'current_location';
  
  // أسماء الأعمدة المشتركة
  static const String COLUMN_ID = 'id';
  static const String COLUMN_DATE = 'date';
  static const String COLUMN_TITLE = 'title';
  static const String COLUMN_CONTENT = 'content';
  static const String COLUMN_CATEGORY = 'category';
  static const String COLUMN_SOURCE = 'source';
  
  // أعمدة أوقات الأذان
  static const String COLUMN_FAJR_TIME = 'fajr_time';
  static const String COLUMN_SUNRISE_TIME = 'sunrise_time';
  static const String COLUMN_DHUHR_TIME = 'dhuhr_time';
  static const String COLUMN_ASR_TIME = 'asr_time';
  static const String COLUMN_MAGHRIB_TIME = 'maghrib_time';
  static const String COLUMN_ISHA_TIME = 'isha_time';
  static const String COLUMN_SUHOOR_TIME = 'suhoor_time';
  
  // أعمدة الموقع
  static const String COLUMN_NAME = 'name';
  static const String COLUMN_LATITUDE = 'latitude';
  static const String COLUMN_LONGITUDE = 'longitude';
  static const String COLUMN_COUNTRY = 'country';
  static const String COLUMN_CITY = 'city';
  static const String COLUMN_METHOD_ID = 'method_id';
  static const String COLUMN_LOCATION_ID = 'location_id';
  
  // أعمدة المهام اليومية
  static const String COLUMN_DESCRIPTION = 'description';
  static const String COLUMN_IS_COMPLETED = 'isCompleted';
  static const String COLUMN_DUE_DATE = 'due_date';
  static const String COLUMN_CREATED_AT = 'created_at';
  
  // أعمدة الأذكار
  static const String COLUMN_COUNT = 'count';
  static const String COLUMN_FADL = 'fadl';
  
  // أعمدة الحديث
  static const String COLUMN_NARRATOR = 'narrator';
  static const String COLUMN_BOOK = 'book';
  static const String COLUMN_CHAPTER = 'chapter';
  static const String COLUMN_HADITH_NUMBER = 'hadithNumber';
  
  // أعمدة العبادة اليومية
  static const String COLUMN_FAJR_PRAYER = 'fajr_prayer';
  static const String COLUMN_DHUHR_PRAYER = 'dhuhr_prayer';
  static const String COLUMN_ASR_PRAYER = 'asr_prayer';
  static const String COLUMN_MAGHRIB_PRAYER = 'maghrib_prayer';
  static const String COLUMN_ISHA_PRAYER = 'isha_prayer';
  static const String COLUMN_SUHOOR = 'suhoor';
  static const String COLUMN_TAHAJJUD = 'tahajjud';
  static const String COLUMN_QIYAM = 'qiyam';
  static const String COLUMN_QURAN = 'quran';
  static const String COLUMN_THIKR = 'thikr';
  
  // أعمدة الصلاة
  static const String COLUMN_FARZ = 'farz';
  static const String COLUMN_SUNNAH = 'sunnah';
  static const String COLUMN_IN_MOSQUE = 'in_mosque';
}
