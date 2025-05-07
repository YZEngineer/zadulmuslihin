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


  /// تنسيق الوقت من صيغة 24 ساعة إلى صيغة 12 ساعة
  /// وضع لادوال في مجلد الدوال
  String formatTime(String time24) {
    try {
      // التحقق من تنسيق الوقت
      if (time24.contains(' ')) {
        // إذا كان الوقت بتنسيق 12 ساعة، قم بتحويله إلى تنسيق 24 ساعة
        final parts = time24.split(' ');
        final timePart = parts[0];
        final ampm = parts[1];

        final timeComponents = timePart.split(':');
        int hours = int.parse(timeComponents[0]);

        if (ampm.toLowerCase() == 'pm' && hours < 12) {
          hours += 12;
        } else if (ampm.toLowerCase() == 'am' && hours == 12) {
          hours = 0;
        }

        return '${hours.toString().padLeft(2, '0')}:${timeComponents[1]}';
      } else {
        // إذا كان الوقت بالفعل بتنسيق 24 ساعة، تأكد من أنه بتنسيق HH:MM
        final timeComponents = time24.split(':');
        return '${timeComponents[0].padLeft(2, '0')}:${timeComponents[1]}';
      }
    } catch (e) {
      print('خطأ في تنسيق الوقت: $e');
      return time24;
    }
  }
