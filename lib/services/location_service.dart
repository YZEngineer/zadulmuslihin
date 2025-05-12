import 'package:geocoding/geocoding.dart';

/// خدمة الموقع المبسطة للحصول على العنوان من الإحداثيات
class LocationService {
  /// الحصول على اسم المدينة والبلد من الإحداثيات
  static Future<Map<String, String>> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
        localeIdentifier: 'ar',
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return {
          'city': place.locality ?? place.subAdministrativeArea ?? 'غير معروف',
          'country': place.country ?? 'غير معروف',
        };
      }
    } catch (e) {
      print('خطأ في الحصول على العنوان من الإحداثيات: $e');
    }

    // في حالة الخطأ، نعود بمكة المكرمة كموقع افتراضي
    return {
      'city': 'مكة المكرمة',
      'country': 'المملكة العربية السعودية',
    };
  }

  /// الموقع الافتراضي (مكة المكرمة)
  static Map<String, double> getDefaultLocation() {
    return {
      'latitude': 21.3891,
      'longitude': 39.8579,
    };
  }

  /// معلومات الموقع كاملة (مكة المكرمة - افتراضي)
  static Future<Map<String, dynamic>> getDefaultLocationInfo() async {
    final coordinates = getDefaultLocation();
    final address = await getAddressFromCoordinates(
      coordinates['latitude']!,
      coordinates['longitude']!,
    );

    return {
      'latitude': coordinates['latitude'],
      'longitude': coordinates['longitude'],
      'city': address['city'],
      'country': address['country'],
      'success': true,
    };
  }
}
