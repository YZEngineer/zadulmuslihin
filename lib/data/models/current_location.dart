/// نموذج يمثل الموقع الحالي المختار
class CurrentLocation {
  final int id; // دائما 1 لأنه سجل واحد فقط
  final int locationId; // معرف الموقع المختار

  CurrentLocation({
    this.id = 1,
    required this.locationId,
  });

  /// إنشاء نموذج من خريطة بيانات
  factory CurrentLocation.fromMap(Map<String, dynamic> map) {
    return CurrentLocation(
      id: map['id'] ?? 1,
      locationId: map['location_id'],
    );
  }

  /// تحويل النموذج إلى خريطة بيانات لحفظها في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'location_id': locationId,
    };
  }
}
