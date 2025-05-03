import 'package:intl/intl.dart';

/// نموذج يمثل الأذان الحالي (الأذان النشط حالياً)
class CurrentAdhan {
  final int? id;
  final DateTime date; // تاريخ اليوم بتنسيق YYYY-MM-DD
  final String fajrTime; // وقت أذان الفجر
  final String sunriseTime; // وقت الشروق
  final String dhuhrTime; // وقت أذان الظهر
  final String asrTime; // وقت أذان العصر
  final String maghribTime; // وقت أذان المغرب
  final String ishaTime; // وقت أذان العشاء
  final String? suhoorTime; // وقت السحور (اختياري)

  CurrentAdhan({
    this.id,
    required this.date,
    required this.fajrTime,
    required this.sunriseTime,
    required this.dhuhrTime,
    required this.asrTime,
    required this.maghribTime,
    required this.ishaTime,
    this.suhoorTime,
  });

  /// إنشاء نموذج من خريطة بيانات
  factory CurrentAdhan.fromMap(Map<String, dynamic> map) {
    return CurrentAdhan(
      id: map['id'],
      date: DateTime.parse(map['date']),
      fajrTime: map['fajr_time'],
      sunriseTime: map['sunrise_time'],
      dhuhrTime: map['dhuhr_time'],
      asrTime: map['asr_time'],
      maghribTime: map['maghrib_time'],
      ishaTime: map['isha_time'],
      suhoorTime: map['suhoor_time'],
    );
  }

  /// تحويل النموذج إلى خريطة بيانات لحفظها في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'fajr_time': fajrTime,
      'sunrise_time': sunriseTime,
      'dhuhr_time': dhuhrTime,
      'asr_time': asrTime,
      'maghrib_time': maghribTime,
      'isha_time': ishaTime,
      'suhoor_time': suhoorTime,
    };
  }

  /// إنشاء نسخة معدلة من هذا النموذج
  CurrentAdhan copyWith({
    int? id,
    DateTime? date,
    String? fajrTime,
    String? sunriseTime,
    String? dhuhrTime,
    String? asrTime,
    String? maghribTime,
    String? ishaTime,
    String? suhoorTime,
  }) {
    return CurrentAdhan(
      id: id ?? this.id,
      date: date ?? this.date,
      fajrTime: fajrTime ?? this.fajrTime,
      sunriseTime: sunriseTime ?? this.sunriseTime,
      dhuhrTime: dhuhrTime ?? this.dhuhrTime,
      asrTime: asrTime ?? this.asrTime,
      maghribTime: maghribTime ?? this.maghribTime,
      ishaTime: ishaTime ?? this.ishaTime,
      suhoorTime: suhoorTime ?? this.suhoorTime,
    );
  }
}
