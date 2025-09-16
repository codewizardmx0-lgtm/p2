import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/api_data_provider.dart';
import 'screens/api_demo_screen.dart';

// ملف اختبار بسيط لتشغيل شاشة API Demo مباشرة
void main() {
  runApp(TestApiApp());
}

class TestApiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ApiDataProvider(),
      child: MaterialApp(
        title: 'اختبار API Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Arial',
        ),
        home: ApiDemoScreen(),
      ),
    );
  }
}