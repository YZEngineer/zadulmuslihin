import 'package:flutter/material.dart';
import 'package:zadulmuslihin/services/database_info_service.dart';
import 'package:zadulmuslihin/view/database_table_view.dart';
import 'package:zadulmuslihin/data/database/current_adhan_dao.dart';
import 'package:zadulmuslihin/services/prayer_times_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseInfoService _databaseInfoService = DatabaseInfoService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _tablesInfo = [];
  bool _showSystemTables = false;
  final PrayerTimesService _prayerTimesService = PrayerTimesService();

  @override
  void initState() {
    super.initState();
    _loadTablesInfo();
  }

  @override
  void dispose() {super.dispose();}

  Future<void> _loadTablesInfo() async {
    setState(() {_isLoading = true;});

    try {
      List<Map<String, dynamic>> tablesInfo;
      if (_showSystemTables) {
        // الحصول على جميع الجداول بما فيها جداول النظام
        final allTables = await _databaseInfoService.getAllSystemTables();
        tablesInfo = [];

        for (var table in allTables) {
          int rowCount = await _databaseInfoService.getTableRowCount(table);
          tablesInfo.add({'name': table, 'rows': rowCount,
          'isSystemTable': table.startsWith('sqlite_') || table.startsWith('android_')});
        }
      } else {
        // الحصول على الجداول الأساسية فقط
        tablesInfo = await _databaseInfoService.getTablesInfo();
      }

      setState(() {_tablesInfo = tablesInfo;_isLoading = false;});
    } catch (e) {
      print('خطأ في تحميل معلومات الجداول: $e');
      setState(() {_isLoading = false;});
    }}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('زاد المصلحين - معلومات قاعدة البيانات'),
        centerTitle: true,
        actions: [
          // إضافة زر تحديث الأذان الحالي
          IconButton(
            icon: Icon(Icons.mosque),
            tooltip: 'تحديث الأذان الحالي',
            onPressed: _updateCurrentAdhan,
          ),

          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTablesInfo,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.cloud_download),
                    label: Text(
                      'جلب أوقات الصلاة من الإنترنت',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding:EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                    onPressed: _fetchPrayerTimesFromAPI),
                ),
                Expanded(child: _buildTablesList()),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTablesList() {
    if (_tablesInfo.isEmpty) {
      return Center(
        child: Text(
          'لا توجد جداول في قاعدة البيانات',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: _tablesInfo.length,
        itemBuilder: (context, index) {
          final tableInfo = _tablesInfo[index];
          final bool isSystemTable = tableInfo['isSystemTable'] ?? false;

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            // تغيير لون الخلفية لجداول النظام
            color: isSystemTable ? Colors.grey.shade100 : null,
            child: ListTile(
              title: Text(
                tableInfo['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  // تغيير لون النص لجداول النظام
                  color: isSystemTable ? Colors.grey.shade700 : null,
                ),
              ),
              subtitle: Text('عدد السجلات: ${tableInfo['rows']}'),
              // إضافة أيقونة للجداول النظامية
              leading: isSystemTable
                  ? Icon(Icons.settings, color: Colors.grey)
                  : Icon(Icons.table_chart),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DatabaseTableView(
                      tableName: tableInfo['name'],
                    ),
                  ),
                ).then((_) =>
                    _loadTablesInfo()); // إعادة تحميل البيانات بعد العودة
              },
            ),
          );
        },
      ),
    );
  }

  // دالة لتحديث الأذان الحالي /// نقل الى مجلد الدوال
  Future<void> _updateCurrentAdhan() async {
    try {
      // عرض مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // تحديث الأذان الحالي
      final currentAdhanDao = CurrentAdhanDao();
      await currentAdhanDao.UpdateCurrentAdhan();

      // إغلاق مؤشر التحميل
      Navigator.pop(context);

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث بيانات الأذان الحالي بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // إعادة تحميل معلومات الجداول
      _loadTablesInfo();
    } catch (e) {
      // إغلاق مؤشر التحميل في حالة الخطأ
      Navigator.pop(context);

      // عرض رسالة الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحديث بيانات الأذان الحالي: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  ///نقل الى مجلد السيرفيس
  // دالة لجلب أوقات الصلاة من API
  Future<void> _fetchPrayerTimesFromAPI() async {
    try {
      // عرض حوار التأكيد
      bool confirmFetch = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('تأكيد جلب البيانات'),
                content: Text(
                    'هل تريد جلب أوقات الصلاة من الإنترنت لجميع السجلات الموجودة في قاعدة البيانات؟'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('تأكيد'),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (!confirmFetch) return;

      // عرض مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // جلب أوقات الصلاة
      final success =
          await _prayerTimesService.refreshAllPrayerTimes(forceUpdate: true);

      // إغلاق مؤشر التحميل
      Navigator.pop(context);

      // عرض رسالة النتيجة
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم جلب أوقات الصلاة لجميع السجلات بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('حدث خطأ أثناء جلب أوقات الصلاة أو لا توجد سجلات للتحديث'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }

      // إعادة تحميل معلومات الجداول
      _loadTablesInfo();
    } catch (e) {
      // إغلاق مؤشر التحميل في حالة الخطأ
      Navigator.pop(context);

      // عرض رسالة الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء جلب أوقات الصلاة: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

}
