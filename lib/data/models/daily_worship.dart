/// نموذج يمثل العبادات اليومية للمستخدم
class DailyWorship {
  final int id;
  final bool fajrPrayer; // صلاة الفجر
  final bool dhuhrPrayer; // صلاة الظهر
  final bool asrPrayer; // صلاة العصر
  final bool maghribPrayer; // صلاة المغرب
  final bool ishaPrayer; // صلاة العشاء
  final bool witr; // صلاة الوتر
  final bool qiyam; // قيام الليل
  final bool quran; // قراءة القرآن
  final bool thikr; // الأذكار

  DailyWorship({
    this.id = 1,
    required this.fajrPrayer,
    required this.dhuhrPrayer,
    required this.asrPrayer,
    required this.maghribPrayer,
    required this.ishaPrayer,
    required this.witr,
    required this.qiyam,
    required this.quran,
    required this.thikr,
  });

  /// إنشاء نموذج من خريطة بيانات قاعدة البيانات
  factory DailyWorship.fromMap(Map<String, dynamic> map) {
    return DailyWorship(
      id: map['id'] ?? 1,
      fajrPrayer: map['fajr_prayer'] == 1 || map['fajr_prayer'] == true,
      dhuhrPrayer: map['dhuhr_prayer'] == 1 || map['dhuhr_prayer'] == true,
      asrPrayer: map['asr_prayer'] == 1 || map['asr_prayer'] == true,
      maghribPrayer:
          map['maghrib_prayer'] == 1 || map['maghrib_prayer'] == true,
      ishaPrayer: map['isha_prayer'] == 1 || map['isha_prayer'] == true,
      witr: map['witr'] == 1 || map['witr'] == true,
      qiyam: map['qiyam'] == 1 || map['qiyam'] == true,
      quran: map['quran_reading'] == 1 || map['quran_reading'] == true,
      thikr: map['thikr'] == 1 || map['thikr'] == true,
    );
  }

  /// تحويل النموذج إلى خريطة بيانات لحفظها في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fajr_prayer': fajrPrayer ? 1 : 0,
      'dhuhr_prayer': dhuhrPrayer ? 1 : 0,
      'asr_prayer': asrPrayer ? 1 : 0,
      'maghrib_prayer': maghribPrayer ? 1 : 0,
      'isha_prayer': ishaPrayer ? 1 : 0,
      'witr': witr ? 1 : 0,
      'qiyam': qiyam ? 1 : 0,
      'quran_reading': quran ? 1 : 0,
      'thikr': thikr ? 1 : 0,
    };
  }

  /// إنشاء نسخة معدلة من هذا النموذج
  DailyWorship copyWith({
    int? id,
    bool? fajrPrayer,
    bool? dhuhrPrayer,
    bool? asrPrayer,
    bool? maghribPrayer,
    bool? ishaPrayer,
    bool? witr,
    bool? qiyam,
    bool? quran,
    bool? thikr,
  }) {
    return DailyWorship(
      id: id ?? this.id,
      fajrPrayer: fajrPrayer ?? this.fajrPrayer,
      dhuhrPrayer: dhuhrPrayer ?? this.dhuhrPrayer,
      asrPrayer: asrPrayer ?? this.asrPrayer,
      maghribPrayer: maghribPrayer ?? this.maghribPrayer,
      ishaPrayer: ishaPrayer ?? this.ishaPrayer,
      witr: witr ?? this.witr,
      qiyam: qiyam ?? this.qiyam,
      quran: quran ?? this.quran,
      thikr: thikr ?? this.thikr,
    );
  }

  @override
  String toString() {
    return 'DailyWorship(id: $id, fajrPrayer: $fajrPrayer, dhuhrPrayer: $dhuhrPrayer, '
        'asrPrayer: $asrPrayer, maghribPrayer: $maghribPrayer, ishaPrayer: $ishaPrayer, '
        'witr: $witr, qiyam: $qiyam, quran: $quran, thikr: $thikr)';
  }
}
