import 'package:flutter/material.dart';
import '../services/location_service.dart';

class LocationDemoPage extends StatefulWidget {
  const LocationDemoPage({Key? key}) : super(key: key);

  @override
  _LocationDemoPageState createState() => _LocationDemoPageState();
}

class _LocationDemoPageState extends State<LocationDemoPage> {
  Map<String, dynamic>? _defaultLocation;
  Map<String, String>? _locationAddress;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultLocation();
  }

  Future<void> _loadDefaultLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // الحصول على الموقع الافتراضي (مكة المكرمة)
      final location = LocationService.getDefaultLocation();
      final address = await LocationService.getAddressFromCoordinates(
        location['latitude']!,
        location['longitude']!,
      );

      setState(() {
        _defaultLocation = location;
        _locationAddress = address;
        _isLoading = false;
      });
    } catch (e) {
      print('خطأ في تحميل معلومات الموقع: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('معلومات الموقع'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDefaultLocation,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    'الموقع الافتراضي',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'هذا المشروع يستخدم موقع افتراضي (مكة المكرمة) لعرض أوقات الصلاة.'),
                        SizedBox(height: 16),
                        if (_defaultLocation != null) ...[
                          Text('الإحداثيات:'),
                          SizedBox(height: 8),
                          Text('خط العرض: ${_defaultLocation!['latitude']}'),
                          Text('خط الطول: ${_defaultLocation!['longitude']}'),
                          SizedBox(height: 16),
                        ],
                        if (_locationAddress != null) ...[
                          Text('العنوان:'),
                          SizedBox(height: 8),
                          Text('المدينة: ${_locationAddress!['city']}'),
                          Text('البلد: ${_locationAddress!['country']}'),
                        ],
                      ],
                    ),
                  ),
                  _buildSectionCard(
                    'ملاحظة',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'لاستخدام موقعك الفعلي، يمكن تفعيل مكتبات تحديد الموقع المعلقة في ملف pubspec.yaml '
                            'وتكوين الأذونات المناسبة.'),
                        SizedBox(height: 8),
                        Text(
                            'تم تعليق الوظائف المتقدمة لتحديد الموقع مؤقتاً لتجنب مشاكل التوافق.'),
                      ],
                    ),
                  ),
                  _buildSectionCard(
                    'استخدام في المستقبل',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('لتفعيل تحديد الموقع الفعلي، ستحتاج إلى:'),
                        SizedBox(height: 8),
                        _buildListItem('تفعيل مكتبات الموقع في pubspec.yaml'),
                        _buildListItem(
                            'ضبط إصدار Kotlin المناسب في ملفات Android'),
                        _buildListItem(
                            'إضافة الأذونات المناسبة في AndroidManifest.xml و Info.plist'),
                        _buildListItem(
                            'تحديث خدمة الموقع للحصول على الموقع الفعلي'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard(String title, Widget content) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(),
            SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
