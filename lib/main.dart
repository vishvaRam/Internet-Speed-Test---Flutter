import 'package:flutter/material.dart';
import './Pages/Home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Internet Speed Tester",
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: ThemeData(
        brightness: Brightness.dark
      ),
    );
  }
}
