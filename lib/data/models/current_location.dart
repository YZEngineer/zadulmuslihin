/// نموذج يمثل الموقع الحالي المختار
class CurrentLocation {
  final int? locationId;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String? timezone;
  final String? madhab;
  final int? methodId;

  CurrentLocation({
    this.locationId,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.timezone,
    this.madhab,
    this.methodId,
  });

  /// إنشاء نموذج من خريطة بيانات
  factory CurrentLocation.fromMap(Map<String, dynamic> map) {
    return CurrentLocation(
      locationId: map['location_id'],
      city: map['city'],
      country: map['country'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timezone: map['timezone'],
      madhab: map['madhab'],
      methodId: map['method_id'],
    );
  }

  /// تحويل النموذج إلى خريطة بيانات لحفظها في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'location_id': locationId,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'madhab': madhab,
      'method_id': methodId,
    };
  }

  /// إنشاء نسخة معدلة من هذا النموذج
  CurrentLocation copyWith({
    int? locationId,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? timezone,
    String? madhab,
    int? methodId,
  }) {
    return CurrentLocation(
      locationId: locationId ?? this.locationId,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
      madhab: madhab ?? this.madhab,
      methodId: methodId ?? this.methodId,
    );
  }

  @override
  String toString() {
    return 'CurrentLocation(locationId: $locationId, city: $city, country: $country, latitude: $latitude, longitude: $longitude, timezone: $timezone, madhab: $madhab, methodId: $methodId)';
  }
}
