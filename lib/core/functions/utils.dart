  /// تحويل قيمة إلى double مع التعامل مع الأنواع المختلفة
    double parseDouble(dynamic value) {
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

    /// التحقق من صحة صيغة الوقت
  bool isValidTimeFormat(String time) {
    final RegExp timeRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    return timeRegex.hasMatch(time);
  }
