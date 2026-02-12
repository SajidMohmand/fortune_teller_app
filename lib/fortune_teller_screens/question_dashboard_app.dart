import 'package:flutter/material.dart';

import 'dashboard_home_screen.dart';

class QuestionDashboardApp extends StatelessWidget {
  const QuestionDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Question Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const DashboardHomeScreen(),
    );
  }
}