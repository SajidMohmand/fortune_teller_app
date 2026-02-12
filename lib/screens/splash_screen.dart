import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fortune_teller_app/screens/home_main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'disclaimer_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? acceptedDisclaimer = prefs.getBool('acceptedDisclaimer');

    // Wait 2 seconds to show splash
    await Future.delayed(const Duration(seconds: 2));

    if (acceptedDisclaimer == null || !acceptedDisclaimer) {
      // First launch → show disclaimer
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DisclaimerScreen()));
    } else {
      // Already accepted → go to home
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeMainScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.star, size: 100, color: Colors.deepPurple),
              SizedBox(height: 20),
              Text(
                'Olirian Fortune Teller',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
