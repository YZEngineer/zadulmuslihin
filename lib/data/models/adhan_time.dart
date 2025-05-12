/// نموذج لتمثيل أوقات الصلاة لتاريخ ومكان معين
class AdhanTimes {
  final int? id;
  final int locationId;
  final DateTime date;
  final String fajrTime;
  final String sunriseTime;
  final String dhuhrTime;
  final String asrTime;
  final String maghribTime;
  final String ishaTime;

  AdhanTimes({
    this.id,
    required this.locationId,
    required this.date,
    required this.fajrTime,
    required this.sunriseTime,
    required this.dhuhrTime,
    required this.asrTime,
    required this.maghribTime,
    required this.ishaTime,
  });

  /// إنشاء نسخة من النموذج من خريطة بيانات
  factory AdhanTimes.fromMap(Map<String, dynamic> map) {
    return AdhanTimes(
      id: map['id'],
      locationId: map['location_id'],
      date: map['date'] is String ? DateTime.parse(map['date']) : map['date'],
      fajrTime: map['fajr_time'],
      sunriseTime: map['sunrise_time'],
      dhuhrTime: map['dhuhr_time'],
      asrTime: map['asr_time'],
      maghribTime: map['maghrib_time'],
      ishaTime: map['isha_time'],
    );
  }

  /// تحويل النموذج إلى خريطة بيانات للتخزين
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'location_id': locationId,
      'date': date.toIso8601String().split('T').first,
      'fajr_time': fajrTime,
      'sunrise_time': sunriseTime,
      'dhuhr_time': dhuhrTime,
      'asr_time': asrTime,
      'maghrib_time': maghribTime,
      'isha_time': ishaTime,
    };
  }

  /// إنشاء نسخة جديدة من النموذج مع تعديل بعض القيم
  AdhanTimes copyWith({
    int? id,
    int? locationId,
    DateTime? date,
    String? fajrTime,
    String? sunriseTime,
    String? dhuhrTime,
    String? asrTime,
    String? maghribTime,
    String? ishaTime,
  }) {
    return AdhanTimes(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      date: date ?? this.date,
      fajrTime: fajrTime ?? this.fajrTime,
      sunriseTime: sunriseTime ?? this.sunriseTime,
      dhuhrTime: dhuhrTime ?? this.dhuhrTime,
      asrTime: asrTime ?? this.asrTime,
      maghribTime: maghribTime ?? this.maghribTime,
      ishaTime: ishaTime ?? this.ishaTime,
    );
  }

  @override
  String toString() {
    return 'AdhanTimes(id: $id, locationId: $locationId, date: $date, '
        'fajr: $fajrTime, sunrise: $sunriseTime, dhuhr: $dhuhrTime, '
        'asr: $asrTime, maghrib: $maghribTime, isha: $ishaTime)';
  }
}
