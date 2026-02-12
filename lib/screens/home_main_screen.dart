import 'package:flutter/material.dart';
import 'package:fortune_teller_app/fortune_teller_screens/question_dashboard_app.dart';
import 'package:fortune_teller_app/screens/purchase_screen.dart';

import '../widgets/drawer.dart';
import 'home_screen.dart';
import 'pre_made_question/premade_questions_screen.dart';
import 'custom_question/custom_question_screen.dart';
import 'profile_screen.dart';

class HomeMainScreen extends StatelessWidget {
  const HomeMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeScaffold();
  }
}




class _HomeScaffold extends StatefulWidget {
  const _HomeScaffold();

  @override
  State<_HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<_HomeScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    PremadeQuestionsScreen(),
    CustomQuestionScreen(),
    ProfileScreen(),
    PurchaseScreen(),
  ];

  DateTime? _lastBackPress;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (_currentIndex != 0) {
            setState(() => _currentIndex = 0);
            return false;
          }

          final now = DateTime.now();
          if (_lastBackPress == null ||
              now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
            _lastBackPress = now;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Press back again to exit")),
            );
            return false;
          }

          return true;
        },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Olirian",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0F2027),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: AppDrawer(
          onSelect: (index) {
            setState(() => _currentIndex = index);
            Navigator.pop(context);
          },
        ),
        body: _screens[_currentIndex],
      ),
    );
  }

}


