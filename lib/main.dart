import 'package:flutter/material.dart';

import 'view/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


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
