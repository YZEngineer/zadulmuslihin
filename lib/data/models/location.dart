import '../../core/functions/utils.dart';

/// نموذج يمثل موقعًا جغرافيًا يمكن تخزينه
/// 
class Location {
  final int? id;
  final double latitude;
  final double longitude;
  final String? country;
  final String? city;
  final String? timezone;
  final String? madhab;
  final int? methodId;

  // حدود خطوط العرض والطول
  static const double minLatitude = -90.0;
  static const double maxLatitude = 90.0;
  static const double minLongitude = -180.0;
  static const double maxLongitude = 180.0;

  // قائمة بطرق حساب أوقات الصلاة المدعومة
  static const List<int> supportedMethods = [
    1, // رابطة العالم الإسلامي
    2, // الجامعة الإسلامية، كراتشي
    3, // جمعية أمريكا الشمالية الإسلامية
    4, // الهيئة المصرية العامة للمساحة (أم القرى)
    5, // جامعة الأزهر، القاهرة
    7, // معهد الجيوفيزياء، جامعة طهران
    8, // منطقة الخليج
    9, // الكويت
    10, // قطر
    11, // مجلس سنغافورة الإسلامي
    12, // الاتحاد الإسلامي الفرنسي
    13, // ديوان المظالم، تركيا
    14, // الإدارة الروحية لمسلمي روسيا
    15, // مجلس البحوث الإسلامية، بنغلاديش
  ];

  Location({
    this.id,
    required this.latitude,
    required this.longitude,
    this.country,
    this.city,
    this.timezone,
    this.methodId,
    this.madhab,
  }) {
    // التحقق من صحة الإحداثيات
    if (latitude < minLatitude || latitude > maxLatitude) {
      throw ArgumentError(
          'خط العرض يجب أن يكون بين $minLatitude و $maxLatitude');
    }
    if (longitude < minLongitude || longitude > maxLongitude) {
      throw ArgumentError(
          'خط الطول يجب أن يكون بين $minLongitude و $maxLongitude');
    }

    // التحقق من طريقة الحساب إذا تم توفيرها
    if (methodId != null && !supportedMethods.contains(methodId)) {
      throw ArgumentError('طريقة الحساب غير مدعومة: $methodId');
    }


  }

  /// إنشاء نموذج من خريطة بيانات
  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'],
      latitude: parseDouble(map['latitude']),
      longitude: parseDouble(map['longitude']),
      country: map['country'],
      city: map['city'],
      timezone: map['timezone'],
      madhab: map['madhab'],
      methodId: map['method_id'],
    );
  }



  /// تحويل النموذج إلى خريطة بيانات لحفظها في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'city': city,
      'timezone': timezone,
      'madhab': madhab,
      'method_id': methodId,
    };
  }

  /// إنشاء نسخة معدلة من هذا النموذج
  Location copyWith({
    int? id,
    double? latitude,
    double? longitude,
    String? country,
    String? city,
    String? timezone,
    String? madhab,
    int? methodId,
  }) {
    return Location(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      country: country ?? this.country,
      city: city ?? this.city,
      timezone: timezone ?? this.timezone,
      madhab: madhab ?? this.madhab,
      methodId: methodId ?? this.methodId,
    );
  }

  @override
  String toString() {
    return 'Location(id: $id, latitude: $latitude, longitude: $longitude, country: $country, city: $city, timezone: $timezone, madhab: $madhab, methodId: $methodId)';
  }
}
