import 'package:flutter/material.dart';
import 'package:qibla_tracker/screens/home_clock_screen.dart';
import 'package:qibla_tracker/screens/qibla_screen.dart';

void main() {
  runApp(const QiblaApp());
}

class QiblaApp extends StatelessWidget {
  const QiblaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qibla Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}
