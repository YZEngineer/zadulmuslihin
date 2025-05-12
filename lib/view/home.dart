import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/prayer_times_service.dart';
import '../data/models/adhan_time.dart';
import '../data/database/adhan_times_dao.dart';
import '../data/database/current_location_dao.dart';
import '../data/database/current_adhan_dao.dart';
import '../data/database/database_helper.dart';
import '../core/database/database_initializer.dart';
import '../data/models/daily_message.dart';
import 'dart:math';
import 'db_manager.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  final AdhanTimesDao _adhanTimesDao = AdhanTimesDao();
  final CurrentLocationDao _currentLocationDao = CurrentLocationDao();
  final CurrentAdhanDao _currentAdhanDao = CurrentAdhanDao();
  final _databaseHelper = DatabaseHelper.instance;
  AdhanTimes? _currentPrayerTimes;
  DailyMessage? _dailyMessage;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
    _loadDailyMessage();
    printAllTables();
  }

  Future<void> _loadDailyMessage() async {
    // في التطبيق الحقيقي، هذه الرسائل ستكون في قاعدة البيانات
    final List<DailyMessage> messages = [
      DailyMessage(
        content: "إنما الأعمال بالنيات وإنما لكل امرئ ما نوى",
        title: "حديث",
        source: "حديث",
        category: "حديث",
        date: DateTime.now(),
      ),
      DailyMessage(
        content: "وَقُلْ رَبِّ زِدْنِي عِلْمًا",
        title: "آية",
        source: "سورة طه: 114",
        category: "آية",
        date: DateTime.now(),
      ),
      DailyMessage(
        content:
            "من سلك طريقًا يلتمس فيه علمًا سهل الله له به طريقًا إلى الجنة",
        title: "حديث",
        source: "حديث",
        category: "حديث",
        date: DateTime.now(),
      ),
      DailyMessage(
        content: "إن الله يحب إذا عمل أحدكم عملا أن يتقنه",
        title: "حديث",
        source: "حديث",
        category: "حديث",
        date: DateTime.now(),
      ),
      DailyMessage(
        content:
            "وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ عَلَيْهِ تَوَكَّلْتُ وَإِلَيْهِ أُنِيبُ",
        title: "آية",
        source: "سورة هود: 88",
        category: "آية",
        date: DateTime.now(),
      ),
    ];

    // اختيار رسالة عشوائية
    final random = Random();
    if (mounted) {
      setState(() {
        _dailyMessage = messages[random.nextInt(messages.length)];
      });
    }
  }

  Future<void> printAllTables() async {
    final db = await _databaseHelper.database;
    final tables =
        await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
    print(tables);
    for (var table in tables) {
      printAllRecords(table['name'] as String);
    }
  }

  Future<void> printAllRecords(String tableName) async {
    try {
      final result = await _databaseHelper.query(tableName);
      print(result);
    } catch (e) {
      print("خطأ في طباعة سجلات $tableName: $e");
    }
  }

  Future<void> _loadPrayerTimes() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // التحقق من وجود قاعدة البيانات
      await DatabaseInitializer.initializeDatabase();

      // محاولة الحصول على معرف الموقع الحالي
      int locationId;
      try {
        locationId = await _currentLocationDao.getCurrentLocationId();
      } catch (e) {
        print("خطأ في الحصول على معرف الموقع الحالي: $e");

        // إنشاء موقع افتراضي
        final db = await _databaseHelper.database;
        final locationResult = await db.insert('locations', {
          'latitude': 21.3891,
          'longitude': 39.8579,
          'city': 'مكة المكرمة',
          'country': 'المملكة العربية السعودية',
          'timezone': 'Asia/Riyadh',
          'madhab': 'شافعي',
          'method_id': 4 // طريقة أم القرى
        });

        // إضافة إشارة للموقع الحالي
        await db.insert('current_location', {'location_id': locationResult});

        locationId = locationResult;
      }

      final today = DateTime.now();

      // 1. محاولة الحصول على أوقات الصلاة من جدول current_adhan أولاً
      _currentPrayerTimes =
          await _currentAdhanDao.getCurrentAdhanTimes(locationId);

      // 2. إذا لم تكن موجودة في current_adhan، نتحقق من adhan_times
      if (_currentPrayerTimes == null) {
        _currentPrayerTimes = await _adhanTimesDao.getByDateAndLocation(
          today,
          locationId,
        );

        // 3. إذا وجدنا الأوقات في adhan_times، نقوم بتحديث current_adhan
        if (_currentPrayerTimes != null) {
          await _currentAdhanDao.UpdateCurrentAdhan();
          // نحاول الحصول على الأوقات المحدثة من current_adhan
          _currentPrayerTimes =
              await _currentAdhanDao.getCurrentAdhanTimes(locationId);
        }
      }

      // 4. إذا لم تكن موجودة في أي من الجدولين، نقوم بجلبها من الخادم
      if (_currentPrayerTimes == null) {
        final success = await _prayerTimesService.fetchAndStorePrayerTimes(
          locationId: locationId,
          date: today,
        );

        if (success) {
          // تحديث current_adhan بعد جلب البيانات الجديدة
          await _currentAdhanDao.UpdateCurrentAdhan();

          // الحصول على أوقات الصلاة المحدثة من جدول current_adhan
          _currentPrayerTimes =
              await _currentAdhanDao.getCurrentAdhanTimes(locationId);

          // إذا لم نتمكن من الحصول عليها من current_adhan، نحاول من adhan_times
          if (_currentPrayerTimes == null) {
            _currentPrayerTimes = await _adhanTimesDao.getByDateAndLocation(
              today,
              locationId,
            );
          }
        }
      }
    } catch (e) {
      print('خطأ في تحميل أوقات الصلاة: $e');
      if (mounted) {
        setState(() {
          _errorMessage =
              "تعذر تحميل أوقات الصلاة. يرجى التحقق من اتصال الإنترنت وإعادة المحاولة.";
        });
      }

      // إنشاء أوقات صلاة افتراضية للعرض
      _currentPrayerTimes = AdhanTimes(
          locationId: 1,
          date: DateTime.now(),
          fajrTime: "00:00",
          sunriseTime: "00:00",
          dhuhrTime: "00:00",
          asrTime: "00:00",
          maghribTime: "00:00",
          ishaTime: "00:00");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// تحديث أوقات الصلاة وإعادة تحميلها
  Future<void> _refreshPrayerTimes() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
      });

      // الحصول على معرف الموقع الحالي
      int locationId = await _currentLocationDao.getCurrentLocationId();
      final today = DateTime.now();

      // طلب تحديث البيانات من الخادم
      final success = await _prayerTimesService.fetchAndStorePrayerTimes(
        locationId: locationId,
        date: today,
        forceUpdate: true,
      );

      if (success) {
        // تحديث جدول current_adhan
        await _currentAdhanDao.UpdateCurrentAdhan();

        // الحصول على البيانات المحدثة
        final updatedTimes =
            await _currentAdhanDao.getCurrentAdhanTimes(locationId);

        if (updatedTimes != null && mounted) {
          setState(() {
            _currentPrayerTimes = updatedTimes;
            _errorMessage = null;
          });
        }
      } else if (mounted) {
        setState(() {
          _errorMessage =
              "تعذر تحديث أوقات الصلاة. يرجى التحقق من اتصال الإنترنت وإعادة المحاولة.";
        });
      }
    } catch (e) {
      print("خطأ في تحديث أوقات الصلاة: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "حدث خطأ أثناء تحديث أوقات الصلاة: $e";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildPrayerTimeCard(String title, String time) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              time,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyMessageCard() {
    if (_dailyMessage == null) {
      return SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.format_quote, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "رسالة اليوم",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _dailyMessage!.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _dailyMessage!.content,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "- ${_dailyMessage!.title}",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimesInfo() {
    if (_currentPrayerTimes == null) {
      return SizedBox.shrink();
    }

    // تنسيق التاريخ بالعربية
    final dateFormat = DateFormat('yyyy-MM-dd');
    final formattedDate = dateFormat.format(_currentPrayerTimes!.date);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'التاريخ: $formattedDate',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                FutureBuilder<String>(
                  future: _getLocationName(_currentPrayerTimes!.locationId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('جاري تحميل الموقع...');
                    } else if (snapshot.hasError) {
                      return Text('موقع غير معروف');
                    } else {
                      return Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text(
                            snapshot.data ?? 'موقع غير معروف',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 4),
            Divider(),
            Text(
              'أوقات الصلاة للتاريخ المحدد',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // الحصول على اسم الموقع من معرفه
  Future<String> _getLocationName(int locationId) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'locations',
        columns: ['city', 'country'],
        where: 'id = ?',
        whereArgs: [locationId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final city = result.first['city'] as String?;
        final country = result.first['country'] as String?;

        if (city != null && country != null) {
          return '$city, $country';
        } else if (city != null) {
          return city;
        } else if (country != null) {
          return country;
        }
      }

      return 'موقع غير معروف';
    } catch (e) {
      print('خطأ في الحصول على اسم الموقع: $e');
      return 'موقع غير معروف';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('زاد المسلمين'),
        actions: [
          _isLoading
              ? Container(
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.refresh),
                  tooltip: 'تحديث أوقات الصلاة',
                  onPressed: _refreshPrayerTimes,
                ),
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'إعدادات الأذان',
            onPressed: () {
              // سيتم تنفيذ هذا الكود عند النقر على زر الإعدادات
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DatabaseManager()),
              ).then((_) {
                // إعادة تحميل البيانات عند العودة من إدارة قاعدة البيانات
                if (mounted) {
                  _loadPrayerTimes();
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildDailyMessageCard(),
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
                  if (_currentPrayerTimes != null) ...[
                    _buildPrayerTimesInfo(),
                    _buildPrayerTimeCard(
                        'الفجر', _currentPrayerTimes!.fajrTime),
                    _buildPrayerTimeCard(
                        'الشروق', _currentPrayerTimes!.sunriseTime),
                    _buildPrayerTimeCard(
                        'الظهر', _currentPrayerTimes!.dhuhrTime),
                    _buildPrayerTimeCard('العصر', _currentPrayerTimes!.asrTime),
                    _buildPrayerTimeCard(
                        'المغرب', _currentPrayerTimes!.maghribTime),
                    _buildPrayerTimeCard(
                        'العشاء', _currentPrayerTimes!.ishaTime),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refreshPrayerTimes,
                      icon: Icon(Icons.sync),
                      label: Text('تحديث أوقات الصلاة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ] else
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'لا توجد أوقات صلاة متاحة',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _refreshPrayerTimes,
                              icon: Icon(Icons.sync),
                              label: Text('تحديث أوقات الصلاة'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DatabaseManager()),
                      ).then((_) {
                        // إعادة تحميل البيانات عند العودة من إدارة قاعدة البيانات
                        if (mounted) {
                          _loadPrayerTimes();
                        }
                      });
                    },
                    child: Text('إدارة قاعدة البيانات'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (!mounted) return;
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              await DatabaseInitializer.initializeDatabase();
                              if (mounted) _loadPrayerTimes();
                            } catch (e) {
                              print("خطأ في إعادة تهيئة قاعدة البيانات: $e");
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                  _errorMessage =
                                      "تعذر إعادة تهيئة قاعدة البيانات: $e";
                                });
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text('إصلاح قاعدة البيانات'),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    print("تم تدمير صفحة الرئيسية");
    // إلغاء أي عمليات غير متزامنة تم تحفيزها من هذه الصفحة
    super.dispose();
  }
}
