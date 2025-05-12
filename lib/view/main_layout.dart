import 'package:flutter/material.dart';
import 'home.dart';
import 'lessons.dart';
import 'library.dart';
import 'prayer_times.dart';
import 'quran.dart';
import 'settings.dart';
import '../widgets/app_drawer.dart';

class MainLayout extends StatefulWidget {
  final int initialTabIndex;

  MainLayout({this.initialTabIndex = 0});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    if (_currentIndex >= _pages.length) {
      _currentIndex = 0;
    }
  }

  final List<Widget> _pages = [
    Home(),
    LibraryPage(),
    LessonsPage(),
    PrayerTimesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'المكتبة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'الدروس',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'أوقات الصلاة',
          ),
        ],
      ),
    );
  }
}
