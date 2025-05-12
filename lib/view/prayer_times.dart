import 'package:flutter/material.dart';
import '../services/prayer_times_service.dart';
import '../data/models/adhan_time.dart';
import '../data/database/adhan_times_dao.dart';
import '../data/database/current_location_dao.dart';
import '../data/database/location_dao.dart';
import '../data/database/current_adhan_dao.dart';
import 'prayer_notifications_settings.dart';
import '../services/location_service.dart';
import 'package:intl/intl.dart';
import '../data/database/database_helper.dart';

class PrayerTimesPage extends StatefulWidget {
  @override
  _PrayerTimesPageState createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  final CurrentAdhanDao _currentAdhanDao = CurrentAdhanDao();
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  final AdhanTimesDao _adhanTimesDao = AdhanTimesDao();
  final CurrentLocationDao _currentLocationDao = CurrentLocationDao();
  final LocationDao _locationDao = LocationDao();

  List<AdhanTimes> _monthlyPrayerTimes = [];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();
  String _locationName = "تحميل...";
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  // تحميل أوقات الصلاة من قاعدة البيانات
  Future<void> _loadPrayerTimes() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // الحصول على معرف الموقع الحالي
      final locationId = await _currentLocationDao.getCurrentLocationId();

      // الحصول على معلومات الموقع
      final locationData = await _locationDao.getLocationById(locationId);
      if (locationData != null) {
        setState(() {
          _locationName = "${locationData.city}, ${locationData.country}";
        });
      }

      // تحديد الشهر الحالي
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      // محاولة الحصول على أوقات الصلاة للشهر الحالي
      final monthlyTimes = await _adhanTimesDao.getByDateRange(
        firstDayOfMonth,
        lastDayOfMonth,
        locationId,
      );

      // إذا لم تكن البيانات موجودة، نقوم بتحميلها
      if (monthlyTimes.isEmpty) {
        await _prayerTimesService.fetchPrayerTimesForDateRange(
          startDate: firstDayOfMonth,
          endDate: lastDayOfMonth,
          locationId: locationId,
        );

        // محاولة الحصول على البيانات مرة أخرى
        final updatedTimes = await _adhanTimesDao.getByDateRange(
          firstDayOfMonth,
          lastDayOfMonth,
          locationId,
        );

        setState(() {
          _monthlyPrayerTimes = updatedTimes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _monthlyPrayerTimes = monthlyTimes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('خطأ في تحميل أوقات الصلاة: $e');
      if (mounted) {
        setState(() {
          _errorMessage =
              "حدث خطأ أثناء تحميل أوقات الصلاة. يرجى المحاولة مرة أخرى.";
          _isLoading = false;
        });
      }
    }
  }

  // تحديث الموقع باستخدام خدمة الموقع
  Future<void> _updateLocation() async {
    if (!mounted || _isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      // استخدام موقع مكة المكرمة كافتراضي
      final locationInfo = await LocationService.getDefaultLocationInfo();

      if (locationInfo['success'] == true) {
        final db = await DatabaseHelper.instance.database;

        // إضافة موقع جديد أو تحديث موقع حالي
        final Map<String, dynamic> locationData = {
          'latitude': locationInfo['latitude'],
          'longitude': locationInfo['longitude'],
          'city': locationInfo['city'],
          'country': locationInfo['country'],
          'timezone': 'Asia/Riyadh', // افتراضي للمنطقة العربية
          'madhab': 'شافعي', // افتراضي
          'method_id': 4 // طريقة أم القرى
        };

        // إضافة الموقع الجديد إلى جدول المواقع
        final locationResult = await db.insert('locations', locationData);

        // تحديث الموقع الحالي في جدول current_location
        await db.update(
          'current_location',
          {'location_id': locationResult},
          where: 'id = ?',
          whereArgs: [1],
        );

        // تحديث اسم الموقع في الواجهة
        setState(() {
          _locationName = "${locationInfo['city']}, ${locationInfo['country']}";
          _isLoadingLocation = false;
        });

        // إعادة تحميل أوقات الصلاة للموقع الجديد
        await _loadPrayerTimes();

        // إظهار رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديث الموقع بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = "تعذر تحديد موقعك الحالي";
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      print('خطأ في تحديث الموقع: $e');
      if (mounted) {
        setState(() {
          _errorMessage = "حدث خطأ أثناء تحديث الموقع";
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أوقات الصلاة'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_active),
            tooltip: 'إعدادات الإشعارات',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PrayerNotificationsSettingsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadPrayerTimes,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // معلومات الموقع والتاريخ
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.green.shade200),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            _locationName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _isLoadingLocation ? null : _updateLocation,
                        icon: _isLoadingLocation
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.my_location),
                        label: Text(_isLoadingLocation
                            ? 'جاري التحديث...'
                            : 'تحديد موقعي الحالي'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'أوقات الصلاة لشهر ${_getMonthName(DateTime.now().month)}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // رسالة خطأ إن وجدت
                if (_errorMessage != null)
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(8),
                    color: Colors.red.shade100,
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),

                // جدول أوقات الصلاة
                Expanded(
                  child: _monthlyPrayerTimes.isEmpty
                      ? Center(
                          child: Text('لا توجد بيانات لأوقات الصلاة'),
                        )
                      : ListView.builder(
                          itemCount: _monthlyPrayerTimes.length,
                          itemBuilder: (context, index) {
                            final prayerTime = _monthlyPrayerTimes[index];
                            final isToday = _isToday(prayerTime.date);

                            return Card(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              color: isToday ? Colors.green.shade50 : null,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${prayerTime.date.day} ${_getMonthName(prayerTime.date.month)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (isToday)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'اليوم',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    _buildPrayerTimeRow(
                                        'الفجر', prayerTime.fajrTime),
                                    _buildPrayerTimeRow(
                                        'الشروق', prayerTime.sunriseTime),
                                    _buildPrayerTimeRow(
                                        'الظهر', prayerTime.dhuhrTime),
                                    _buildPrayerTimeRow(
                                        'العصر', prayerTime.asrTime),
                                    _buildPrayerTimeRow(
                                        'المغرب', prayerTime.maghribTime),
                                    _buildPrayerTimeRow(
                                        'العشاء', prayerTime.ishaTime),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildPrayerTimeRow(String name, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Text(time),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getMonthName(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return months[month - 1];
  }
}
