import 'package:flutter/material.dart';
import 'view/main_layout.dart';
import 'core/database/database_initializer.dart';
// سنقوم بتعليق استيراد خدمات Firebase مؤقتاً
// import 'services/firebase_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة قاعدة البيانات قبل بدء التطبيق
  await DatabaseInitializer.initializeDatabase();

  // تهيئة خدمة الإشعارات
  try {
    await NotificationService().init();
  } catch (e) {
    print('حدث خطأ أثناء تهيئة خدمة الإشعارات: $e');
  }

  // تعليق تهيئة Firebase مؤقتاً حتى تتم تكوينها بشكل صحيح
  /*
  try {
    await FirebaseService.init();
  } catch (e) {
    print('حدث خطأ أثناء تهيئة Firebase: $e');
    // استمر في تشغيل التطبيق حتى لو فشلت تهيئة Firebase
  }
  */

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'زاد المصلحين',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        // دعم اللغة العربية
        fontFamily: 'Cairo',
      ),
      // استخدام التخطيط الرئيسي مع القائمة السفلية
      home: MainLayout(),
      // تعريف المسارات
      routes: {
        '/home': (context) => MainLayout(initialTabIndex: 0),
        '/library': (context) => MainLayout(initialTabIndex: 1),
        '/lessons': (context) => MainLayout(initialTabIndex: 2),
        '/prayer_times': (context) => MainLayout(initialTabIndex: 3),
        '/adhkar': (context) => MainLayout(initialTabIndex: 4),
      },
    );
  }
}
