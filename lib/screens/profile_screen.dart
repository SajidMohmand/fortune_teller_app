import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData; // Facebook user data
  User? _firebaseUser; // Google / Firebase user

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Check Firebase user (Google login)
    _firebaseUser = FirebaseAuth.instance.currentUser;

    // Check Facebook login
    final fbData = await FacebookAuth.instance.accessToken;
    if (fbData != null) {
      final userData = await FacebookAuth.instance.getUserData();
      print(userData);
      setState(() {
        _userData = userData;
      });
    } else if (_firebaseUser != null) {
      setState(() {}); // Only Firebase user
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
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // 1️⃣ Facebook user
    if (_userData != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_userData!['picture'] != null)
            CircleAvatar(
              radius: 40,
              backgroundImage:
              NetworkImage(_userData!['picture']['data']['url']),
            ),
          const SizedBox(height: 12),
          Text(
            _userData!['name'] ?? "No Name",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(_userData!['email'] ?? "No Email"),
        ],
      );
    }

    // 2️⃣ Google / Firebase user
    if (_firebaseUser != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_firebaseUser!.photoURL != null)
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(_firebaseUser!.photoURL!),
            ),
          const SizedBox(height: 12),
          Text(
            _firebaseUser!.displayName ?? "No Name",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(_firebaseUser!.email ?? "No Email"),
        ],
      );
    }

    // 3️⃣ Not logged in
    return const Text(
      "⚠️ Please log in to see your profile",
      style: TextStyle(fontSize: 18,color: Colors.white),
      textAlign: TextAlign.center,

    );
  }
}
