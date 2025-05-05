import 'package:flutter/material.dart';
import 'core/services/app_initializer.dart';
import 'core/tools/fix_tables.dart';
import 'view/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إصلاح جداول قاعدة البيانات الأساسية
  final tableFixer = TableFixer();
  try {
    print('بدء إصلاح جداول قاعدة البيانات...');



    // ثم إصلاح جدول الأذان الحالي
    await tableFixer.fixCurrentAdhanTable();

    // تخطي إصلاح جدول أوقات الأذان هنا لتجنب حذف البيانات
    // سيتم التعامل معه يدوياً من واجهة المستخدم

    print('تم إصلاح جداول قاعدة البيانات بنجاح');
  } catch (e) {
    print('خطأ أثناء إصلاح الجداول: $e');
  }

  // تهيئة التطبيق وقاعدة البيانات
  final appInitializer = AppInitializer();
  await appInitializer.initialize();

  // طباعة معلومات قاعدة البيانات في وضع التطوير
  await appInitializer.logDatabaseInfo();

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
