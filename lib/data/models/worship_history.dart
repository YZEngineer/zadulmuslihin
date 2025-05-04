/// نموذج يمثل سجل العبادات السابقة ونسب الإنجاز
class WorshipHistory {
  final int? id;
  final int precentOf0; // نسبة إنجاز الفئة الأولى
  final int precentOf1; // نسبة إنجاز الفئة الثانية
  final int precentOf2; // نسبة إنجاز الفئة الثالثة
  final int totalday; // إجمالي عدد الأيام

  WorshipHistory({
    this.id,
    required this.precentOf0,
    required this.precentOf1,
    required this.precentOf2,
    required this.totalday,
  });

  /// إنشاء نموذج من خريطة بيانات
  factory WorshipHistory.fromMap(Map<String, dynamic> map) {
    return WorshipHistory(
      id: map['id'],
      precentOf0: map['precentOf0'],
      precentOf1: map['precentOf1'],
      precentOf2: map['precentOf2'],
      totalday: map['totalday'],
    );
  }

  /// تحويل النموذج إلى خريطة بيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'precentOf0': precentOf0,
      'precentOf1': precentOf1,
      'precentOf2': precentOf2,
      'totalday': totalday,
    };
  }

  /// للتوافق مع الأنماط القديمة
  factory WorshipHistory.fromJson(Map<String, dynamic> json) =>
      WorshipHistory.fromMap(json);

  /// للتوافق مع الأنماط القديمة
  Map<String, dynamic> toJson() => toMap();
}
