import 'package:flutter/material.dart';
import 'data/database/database_manager.dart';
import 'view/home.dart';
import 'test_db.dart'; // استيراد ملف الاختبار

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة قاعدة البيانات
  await DatabaseManager.instance.initialize();

  // اختبار قاعدة البيانات
  await testDatabase();

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
      // استخدام الصفحة الرئيسية الجديدة
      home: HomePage(),
    );
  }
}
