import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fortune_teller_app/fortune_teller_screens/question_dashboard_app.dart';
import 'package:fortune_teller_app/screens/authentication/auth_service.dart';

import '../screens/authentication/login_screen.dart';

class AppDrawer extends StatelessWidget {
  final Function(int) onSelect;

  const AppDrawer({super.key, required this.onSelect});

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout",style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await AuthService().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF203A43),
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final isLoggedIn = snapshot.hasData;
          final user = snapshot.data;

          return Column(
            children: [
              const DrawerHeader(
                child: Text(
                  "🔮 Olirian",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title: const Text("Home", style: TextStyle(color: Colors.white)),
                onTap: () => onSelect(0),
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome, color: Colors.white),
                title: const Text("Pre-Made Questions",
                    style: TextStyle(color: Colors.white)),
                onTap: () => onSelect(1),
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text("Custom Question",
                    style: TextStyle(color: Colors.white)),
                onTap: () => onSelect(2),
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text("Profile",
                    style: TextStyle(color: Colors.white)),
                onTap: () => onSelect(3),
              ),
              ListTile(
                leading: const Icon(Icons.local_grocery_store_sharp, color: Colors.white),
                title: const Text("Purchase",
                    style: TextStyle(color: Colors.white)),
                onTap: () => onSelect(4),
              ),

              if (user?.email == "DrayaWill@gmail.com")
                ListTile(
                  leading: const Icon(Icons.face, color: Colors.white),
                  title: const Text("Fortune Teller login",
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _showPasswordDialog(context);

                  },
                ),


              const Spacer(),

              if (isLoggedIn)
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text("Logout", style: TextStyle(color: Colors.white)),
                  onTap: () => _confirmLogout(context),
                )
              else
                ListTile(
                  leading: const Icon(Icons.login, color: Colors.white),
                  title: const Text("Login", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),

            ],
          );
        },
      ),
    );
  }


  void _showPasswordDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Fortune Teller Login"),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Enter password",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text == "f9zMSob8aXYEucgfndtZuF69ZL6eM") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuestionDashboardApp()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Incorrect password"),
                    ),
                  );
                }
              },
              child: const Text("Login"),
            ),
          ],
        );
      },
    );
  }
}
