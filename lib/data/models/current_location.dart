/// نموذج يمثل الموقع الحالي المختار
class CurrentLocation {
  final int id; // دائما 1 لأنه سجل واحد فقط
  final int locationId; // معرف الموقع المختار

  CurrentLocation({
    this.id = 1,
    required this.locationId,
  }) {
    if (locationId <= 0) {
      throw ArgumentError('معرف الموقع يجب أن يكون رقمًا موجبًا');
    }
    if (id != 1) {
      throw ArgumentError('معرف CurrentLocation يجب أن يكون دائمًا 1');
    }
  }

  /// إنشاء نموذج من خريطة بيانات
  factory CurrentLocation.fromMap(Map<String, dynamic> map) {
    if (map['location_id'] == null) {
      throw ArgumentError('البيانات غير كاملة: يجب توفير location_id');
    }

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

  /// إنشاء نسخة معدلة من هذا النموذج
  CurrentLocation copyWith({
    int? id,
    int? locationId,
  }) {
    return CurrentLocation(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
    );
  }

  int getCurrentLocationId() {
    return locationId;
  }

  @override
  String toString() {
    return 'CurrentLocation(id: $id, locationId: $locationId)';
  }
}
