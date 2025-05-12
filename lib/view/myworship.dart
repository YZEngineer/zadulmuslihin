import 'package:flutter/material.dart';
import '../data/database/daily_worship_dao.dart';
import '../data/models/daily_worship.dart';
import '../data/database/worship_history_dao.dart';
import '../data/models/worship_history.dart';
import 'package:intl/intl.dart';

class MyWorshipView extends StatefulWidget {
  @override
  _MyWorshipViewState createState() => _MyWorshipViewState();
}

class _MyWorshipViewState extends State<MyWorshipView>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final DailyWorshipDao _dailyWorshipDao = DailyWorshipDao();
  final WorshipHistoryDao _worshipHistoryDao = WorshipHistoryDao();
  DailyWorship? _dailyWorship;
  List<WorshipHistory> _worshipHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDailyWorship();
    _loadWorshipHistory();
  }

  Future<void> _loadDailyWorship() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final worships = await _dailyWorshipDao.getAll();

      if (worships.isNotEmpty) {
        setState(() {
          _dailyWorship = worships.first;
        });
      } else {
        // إنشاء سجل عبادات افتراضي إذا لم يكن موجودًا
        final defaultWorship = DailyWorship(
          fajrPrayer: false,
          dhuhrPrayer: false,
          asrPrayer: false,
          maghribPrayer: false,
          ishaPrayer: false,
          witr: false,
          qiyam: false,
          quran: false,
          thikr: false,
        );

        await _dailyWorshipDao.insert(defaultWorship);
        setState(() {
          _dailyWorship = defaultWorship;
        });
      }
    } catch (e) {
      print('خطأ في تحميل العبادات اليومية: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWorshipHistory() async {
    try {
      final history = await _worshipHistoryDao.getAll();
      setState(() {
        _worshipHistory = history;
      });
    } catch (e) {
      print('خطأ في تحميل سجل العبادات: $e');
    }
  }

  Future<void> _saveToHistory() async {
    if (_dailyWorship == null) return;

    // حساب النسب المئوية للإنجاز
    int prayerCount = 0;
    if (_dailyWorship!.fajrPrayer) prayerCount++;
    if (_dailyWorship!.dhuhrPrayer) prayerCount++;
    if (_dailyWorship!.asrPrayer) prayerCount++;
    if (_dailyWorship!.maghribPrayer) prayerCount++;
    if (_dailyWorship!.ishaPrayer) prayerCount++;

    final percentFard = (prayerCount / 5 * 100).round();
    final qiyamValue = _dailyWorship!.qiyam ? 100 : 0;
    final quranValue = _dailyWorship!.quran ? 100 : 0;
    final thikrValue = _dailyWorship!.thikr ? 100 : 0;

    final history = WorshipHistory(
      precentFard: percentFard,
      qiyam: qiyamValue,
      quran: quranValue,
      thikr: thikrValue,
    );

    await _worshipHistoryDao.insert(history);
    _loadWorshipHistory();

    // إعادة ضبط العبادات اليومية لليوم الجديد
    await _dailyWorshipDao.setAllWorship(0);
    _loadDailyWorship();
  }

  Future<void> _updatePrayerStatus(String prayerName, bool value) async {
    try {
      await _dailyWorshipDao.updatePrayerStatus(prayerName, value);
      _loadDailyWorship();
    } catch (e) {
      print('خطأ في تحديث حالة الصلاة: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('عباداتي'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'اليوم'),
            Tab(text: 'السجل'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: _tabController?.index == 0
          ? FloatingActionButton(
              onPressed: _saveToHistory,
              child: Icon(Icons.save),
              tooltip: 'حفظ في السجل',
            )
          : null,
    );
  }

  Widget _buildDailyTab() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_dailyWorship == null) {
      return Center(child: Text('لا توجد بيانات متاحة'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الفروض اليومية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildPrayerCheckbox(
                      'fajr_prayer', 'الفجر', _dailyWorship!.fajrPrayer),
                  _buildPrayerCheckbox(
                      'dhuhr_prayer', 'الظهر', _dailyWorship!.dhuhrPrayer),
                  _buildPrayerCheckbox(
                      'asr_prayer', 'العصر', _dailyWorship!.asrPrayer),
                  _buildPrayerCheckbox(
                      'maghrib_prayer', 'المغرب', _dailyWorship!.maghribPrayer),
                  _buildPrayerCheckbox(
                      'isha_prayer', 'العشاء', _dailyWorship!.ishaPrayer),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'النوافل والأذكار',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildPrayerCheckbox(
                      'witr', 'صلاة الوتر', _dailyWorship!.witr),
                  _buildPrayerCheckbox(
                      'qiyam', 'قيام الليل', _dailyWorship!.qiyam),
                  _buildPrayerCheckbox(
                      'quran_reading', 'قراءة القرآن', _dailyWorship!.quran),
                  _buildPrayerCheckbox(
                      'thikr', 'الأذكار', _dailyWorship!.thikr),
                ],
              ),
            ),
          ),
          SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: () => _dailyWorshipDao
                  .setAllWorship(0)
                  .then((_) => _loadDailyWorship()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('إعادة ضبط'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCheckbox(String prayerName, String label, bool value) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: (newValue) {
        if (newValue != null) {
          _updatePrayerStatus(prayerName, newValue);
        }
      },
      activeColor: Colors.green,
      dense: true,
    );
  }

  Widget _buildHistoryTab() {
    if (_worshipHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا يوجد سجل للعبادات'),
            SizedBox(height: 8),
            Text(
              'أكمل عباداتك اليومية واضغط على زر الحفظ لإضافتها للسجل',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _worshipHistory.length,
      itemBuilder: (context, index) {
        final item = _worshipHistory[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اليوم: ${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                _buildProgressBar('الفروض', item.precentFard),
                SizedBox(height: 8),
                _buildProgressBar('قيام الليل', item.qiyam),
                SizedBox(height: 8),
                _buildProgressBar('القرآن', item.quran),
                SizedBox(height: 8),
                _buildProgressBar('الأذكار', item.thikr),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(String label, int percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $percentage%'),
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          minHeight: 10,
          backgroundColor: Colors.grey[300],
          color: percentage == 100 ? Colors.green : Colors.orange,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}
