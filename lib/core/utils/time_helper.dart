import 'package:intl/intl.dart';

/// مساعد للتعامل مع الأوقات وحساباتها
class TimeHelper {
  /// تحويل وقت بتنسيق HH:MM إلى دقائق منذ منتصف الليل
  static int timeToMinutes(String time) {
    List<String> parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// تحويل دقائق منذ منتصف الليل إلى وقت بتنسيق HH:MM
  static String minutesToTime(int minutes) {
    int hours = minutes ~/ 60;
    int mins = minutes % 60;

    // تنسيق الساعات والدقائق مع ضمان وجود صفرين
    String hoursStr = hours.toString().padLeft(2, '0');
    String minsStr = mins.toString().padLeft(2, '0');

    return '$hoursStr:$minsStr';
  }

  /// حساب الفرق بين وقتين بالدقائق
  static int timeDifferenceInMinutes(String time1, String time2) {
    int minutes1 = timeToMinutes(time1);
    int minutes2 = timeToMinutes(time2);

    // إذا كان الوقت الثاني أقل من الأول، فهذا يعني أنه في اليوم التالي
    if (minutes2 < minutes1) {
      minutes2 += 24 * 60; // إضافة 24 ساعة
    }

    return minutes2 - minutes1;
  }

  /// تنسيق مدة زمنية بالدقائق إلى نص سهل القراءة
  static String formatDuration(int minutes) {
    int hours = minutes ~/ 60;
    int mins = minutes % 60;

    if (hours > 0 && mins > 0) {
      return '$hours ساعة و $mins دقيقة';
    } else if (hours > 0) {
      return '$hours ساعة';
    } else {
      return '$mins دقيقة';
    }
  }

  /// الحصول على تاريخ اليوم بتنسيق YYYY-MM-DD
  static String getToday() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  /// الحصول على تاريخ الغد بتنسيق YYYY-MM-DD
  static String getTomorrow() {
    return DateFormat('yyyy-MM-dd')
        .format(DateTime.now().add(const Duration(days: 1)));
  }

  /// التحقق مما إذا كان الوقت الحالي بين وقتين معينين
  static bool isCurrentTimeBetween(String startTime, String endTime) {
    String now = DateFormat('HH:mm').format(DateTime.now());
    int nowMinutes = timeToMinutes(now);
    int startMinutes = timeToMinutes(startTime);
    int endMinutes = timeToMinutes(endTime);

    // إذا كان وقت النهاية أقل من وقت البداية، فهذا يعني أنه يمتد للغد
    if (endMinutes < startMinutes) {
      endMinutes += 24 * 60; // إضافة 24 ساعة

      // إذا كان الوقت الحالي أقل من وقت البداية، فيجب إضافة 24 ساعة إليه أيضًا
      if (nowMinutes < startMinutes) {
        nowMinutes += 24 * 60;
      }
    }

    return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
  }

  /// الحصول على الوقت المتبقي حتى موعد معين
  static String getRemainingTimeUntil(String targetTime) {
    String now = DateFormat('HH:mm').format(DateTime.now());
    int minutesRemaining = timeDifferenceInMinutes(now, targetTime);
    return formatDuration(minutesRemaining);
  }
}
