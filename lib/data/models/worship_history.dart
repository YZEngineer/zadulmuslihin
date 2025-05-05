/// نموذج يمثل سجل العبادات السابقة ونسب الإنجاز
class WorshipHistory {
  final int? id;
  final int precentFard;
  final int qiyam;
  final int quran;
  final int thikr;

  WorshipHistory({
    this.id,
    required this.precentFard,
    required this.qiyam,
    required this.quran,
    required this.thikr});

  /// إنشاء نموذج من خريطة بيانات
  factory WorshipHistory.fromMap(Map<String, dynamic> map) {
    return WorshipHistory(
      id: map['id'],
      precentFard: map['precentFard'],
      qiyam: map['qiyam'],
      quran: map['quran'],
      thikr: map['thikr'],
    );
  }

  /// تحويل النموذج إلى خريطة بيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'precentFard': precentFard,
      'qiyam': qiyam,
      'quran': quran,
      'thikr': thikr,
    };
  }

  /// للتوافق مع الأنماط القديمة
  factory WorshipHistory.fromJson(Map<String, dynamic> json) =>
      WorshipHistory.fromMap(json);

  /// للتوافق مع الأنماط القديمة
  Map<String, dynamic> toJson() => toMap();
}
