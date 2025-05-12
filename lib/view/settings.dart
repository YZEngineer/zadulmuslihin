import 'package:flutter/material.dart';
import '../data/database/current_location_dao.dart';
import '../data/models/current_location.dart';
import '../services/prayer_times_service.dart';
import 'contact_links.dart';
import 'prayer_notifications_settings.dart';
import 'location_demo.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final CurrentLocationDao _locationDao = CurrentLocationDao();
  final PrayerTimesService _prayerTimesService = PrayerTimesService();

  TextEditingController _cityController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _latitudeController = TextEditingController();
  TextEditingController _longitudeController = TextEditingController();

  bool _isDarkMode = false;
  bool _isNotificationsEnabled = true;
  String _selectedLanguage = 'العربية';
  String _selectedTheme = 'الافتراضي';
  bool _isLoading = false;
  String? _errorMessage;
  CurrentLocation? _currentLocation;

  final List<String> _languages = ['العربية', 'English'];
  final List<String> _themes = ['الافتراضي', 'أخضر', 'أزرق', 'ذهبي', 'مظلم'];

  @override
  void initState() {
    super.initState();
    _loadLocationSettings();
  }

  Future<void> _loadLocationSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _currentLocation = await _locationDao.getCurrentLocation();
      if (_currentLocation != null) {
        _cityController.text = _currentLocation!.city;
        _countryController.text = _currentLocation!.country;
        _latitudeController.text = _currentLocation!.latitude.toString();
        _longitudeController.text = _currentLocation!.longitude.toString();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تحميل إعدادات الموقع: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveLocationSettings() async {
    if (_cityController.text.isEmpty ||
        _countryController.text.isEmpty ||
        _latitudeController.text.isEmpty ||
        _longitudeController.text.isEmpty) {
      setState(() {
        _errorMessage = 'يرجى ملء جميع حقول الموقع';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      double latitude = double.parse(_latitudeController.text);
      double longitude = double.parse(_longitudeController.text);

      CurrentLocation location = CurrentLocation(
        city: _cityController.text,
        country: _countryController.text,
        latitude: latitude,
        longitude: longitude,
      );

      if (_currentLocation == null) {
        await _locationDao.insertCurrentLocation(location);
      } else {
        await _locationDao.updateCurrentLocation(location);
      }

      // تحديث أوقات الصلاة بعد تغيير الموقع
      await _prayerTimesService.updatePrayerTimes(latitude, longitude);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ إعدادات الموقع بنجاح')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في حفظ إعدادات الموقع: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _countryController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null)
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
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
                  _buildSectionTitle('إعدادات الموقع'),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _cityController,
                            decoration: InputDecoration(
                              labelText: 'المدينة',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _countryController,
                            decoration: InputDecoration(
                              labelText: 'البلد',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _latitudeController,
                                  decoration: InputDecoration(
                                    labelText: 'خط العرض',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _longitudeController,
                                  decoration: InputDecoration(
                                    labelText: 'خط الطول',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _saveLocationSettings,
                                  child: Text('حفظ إعدادات الموقع'),
                                ),
                              ),
                              SizedBox(width: 16),
                              IconButton(
                                icon: Icon(Icons.my_location),
                                tooltip: 'استخدام الموقع الحالي',
                                onPressed: () {
                                  // في تطبيق حقيقي، سيتم استخدام خدمة تحديد الموقع GPS
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'هذه الميزة غير متوفرة في النسخة التجريبية')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildSectionTitle('إعدادات العرض'),
                  Card(
                    child: Column(
                      children: [
                        _buildSettingsListTile(
                          title: 'الوضع المظلم',
                          subtitle: _isDarkMode ? 'مفعل' : 'معطل',
                          trailing: Switch(
                            value: _isDarkMode,
                            onChanged: (value) {
                              setState(() {
                                _isDarkMode = value;
                              });
                              // في تطبيق حقيقي، يمكن حفظ هذا الإعداد
                            },
                          ),
                        ),
                        Divider(height: 1),
                        _buildSettingsListTile(
                          title: 'اللغة',
                          subtitle: _selectedLanguage,
                          onTap: () => _showLanguageDialog(),
                        ),
                        Divider(height: 1),
                        _buildSettingsListTile(
                          title: 'السمة',
                          subtitle: _selectedTheme,
                          onTap: () => _showThemeDialog(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildSectionTitle('إعدادات التنبيهات'),
                  Card(
                    child: Column(
                      children: [
                        _buildSettingsListTile(
                          title: 'تنبيهات الصلاة',
                          subtitle: _isNotificationsEnabled ? 'مفعلة' : 'معطلة',
                          trailing: Switch(
                            value: _isNotificationsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _isNotificationsEnabled = value;
                              });
                              // في تطبيق حقيقي، يمكن حفظ هذا الإعداد
                            },
                          ),
                        ),
                        Divider(height: 1),
                        _buildSettingsListTile(
                          title: 'أصوات التنبيهات',
                          subtitle: 'تعديل صوت الأذان والتنبيهات',
                          onTap: () {
                            // في تطبيق حقيقي، يمكن فتح صفحة لتغيير الأصوات
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'هذه الميزة غير متوفرة في النسخة التجريبية')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildSectionTitle('حول التطبيق'),
                  Card(
                    child: Column(
                      children: [
                        _buildSettingsListTile(
                          title: 'عن التطبيق',
                          subtitle: 'زاد المصلحين الإصدار 1.0.0',
                          onTap: () => _showAboutDialog(),
                        ),
                        Divider(height: 1),
                        _buildSettingsListTile(
                          title: 'سياسة الخصوصية',
                          onTap: () {
                            // في تطبيق حقيقي، يمكن فتح صفحة السياسة
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildSectionTitle('خدمة تحديد الموقع'),
                  _buildSettingItem(
                    context,
                    'خدمة تحديد الموقع',
                    Icons.location_on,
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LocationDemoPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildSettingsListTile({
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختر اللغة'),
        content: Container(
          width: double.minPositive,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              return RadioListTile<String>(
                title: Text(_languages[index]),
                value: _languages[index],
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختر السمة'),
        content: Container(
          width: double.minPositive,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _themes.length,
            itemBuilder: (context, index) {
              return RadioListTile<String>(
                title: Text(_themes[index]),
                value: _themes[index],
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('عن التطبيق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.mosque,
                size: 64,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'زاد المصلحين',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('الإصدار 1.0.0'),
            SizedBox(height: 16),
            Text(
              'تطبيق زاد المصلحين هو مشروع غير ربحي يهدف إلى نشر المحتوى الإسلامي المفيد بطريقة سهلة وميسرة.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '© 2023 زاد المصلحين. جميع الحقوق محفوظة.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: onTap,
    );
  }
}
