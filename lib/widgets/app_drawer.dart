import 'package:flutter/material.dart';
import '../view/settings.dart';
import '../view/location_demo.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.menu_book,
                        size: 80,
                        color: Colors.white,
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    'زاد المصلحين',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('الرئيسية'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.library_books),
            title: Text('المكتبة الإسلامية'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/library');
            },
          ),
          ListTile(
            leading: Icon(Icons.school),
            title: Text('الدروس التعليمية'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/lessons');
            },
          ),
          ListTile(
            leading: Icon(Icons.access_time),
            title: Text('مواقيت الصلاة'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/prayer_times');
            },
          ),
          ListTile(
            leading: Icon(Icons.mosque),
            title: Text('أذكار المسلم'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/adhkar');
            },
          ),
          ListTile(
            leading: Icon(Icons.explore),
            title: Text('القبلة'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/qibla');
            },
          ),
          ListTile(
            leading: Icon(Icons.location_on, color: Colors.blue),
            title: Text('خدمة تحديد الموقع'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LocationDemoPage()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('الإعدادات'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('عن التطبيق'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/about');
            },
          ),
        ],
      ),
    );
  }
}
