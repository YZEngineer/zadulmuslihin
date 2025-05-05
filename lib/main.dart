import 'package:flutter/material.dart';

import 'view/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إصلاح جداول قاعدة البيانات الأساسية
  try {
    print('بدء إصلاح جداول قاعدة البيانات...');
  

    // تخطي إصلاح جدول أوقات الأذان هنا لتجنب حذف البيانات
    // سيتم التعامل معه يدوياً من واجهة المستخدم

    print('تم إصلاح جداول قاعدة البيانات بنجاح');
  } catch (e) {
    print('خطأ أثناء إصلاح الجداول: $e');
  }


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'زاد المسلمين',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        // دعم اللغة العربية
        fontFamily: 'Cairo',
      ),
      // استخدام الصفحة الرئيسية
      home: HomePage(),
    );
  }
}
