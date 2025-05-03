/// نموذج يمثل موقعًا جغرافيًا يمكن تخزينه
class Location {
  final int? id; // معرف الموقع في قاعدة البيانات
  final String name; // اسم الموقع (مثل "القاهرة، مصر")
  final double latitude; // خط العرض
  final double longitude; // خط الطول
  final String? country; // اسم الدولة (اختياري)
  final String? city; // اسم المدينة (اختياري)
  final int? methodId; // معرف طريقة حساب أوقات الصلاة (1-15)

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
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.city,
    this.methodId,
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

    // التحقق من الاسم
    if (name.isEmpty) {
      throw ArgumentError('يجب توفير اسم للموقع');
    }
  }

  /// إنشاء نموذج من خريطة بيانات
  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'],
      name: map['name'] ?? '',
      latitude: _parseDouble(map['latitude']),
      longitude: _parseDouble(map['longitude']),
      country: map['country'],
      city: map['city'],
      methodId: map['method_id'],
    );
  }

  /// تحويل قيمة إلى double مع التعامل مع الأنواع المختلفة
  static double _parseDouble(dynamic value) {
    if (value == null) {
      throw ArgumentError('قيمة null غير مقبولة للإحداثيات');
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.parse(value);
    }
    throw ArgumentError('لا يمكن تحويل القيمة إلى double: $value');
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

  @override
  String toString() {
    return 'Location(id: $id, name: $name, latitude: $latitude, longitude: $longitude, country: $country, city: $city, methodId: $methodId)';
  }
}
