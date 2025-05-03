/// نموذج يمثل موقعًا جغرافيًا يمكن تخزينه
class Location {
  final int? id; // معرف الموقع في قاعدة البيانات
  final String name; // اسم الموقع (مثل "القاهرة، مصر")
  final double latitude; // خط العرض
  final double longitude; // خط الطول
  final String? country; // اسم الدولة (اختياري)
  final String? city; // اسم المدينة (اختياري)
  final int? methodId; // معرف طريقة حساب أوقات الصلاة (1-15)

  Location({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.city,
    this.methodId,
  });

  /// إنشاء نموذج من خريطة بيانات
  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'],
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      country: map['country'],
      city: map['city'],
      methodId: map['method_id'],
    );
  }

  /// تحويل النموذج إلى خريطة بيانات لحفظها في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'city': city,
      'method_id': methodId,
    };
  }

  /// إنشاء نسخة معدلة من هذا النموذج
  Location copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    String? country,
    String? city,
    int? methodId,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      country: country ?? this.country,
      city: city ?? this.city,
      methodId: methodId ?? this.methodId,
    );
  }
}
