import 'package:flutter/material.dart';
import '../../widgets/social_button.dart';
import '../home_main_screen.dart';
import '../home_screen.dart';
import 'auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF203A43),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      backgroundColor: const Color(0xFF203A43),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "🔮 Welcome to Olirian",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              SocialButton(
                text: "Continue with Google",
                icon: Icons.g_mobiledata,
                color: Colors.white,
                textColor: Colors.black,
                onTap: () async {
                  try {
                    await authService.signInWithGoogle();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeMainScreen()),
                          (route) => false,
                    );
                  } catch (e) {
                    _showError(context, e.toString());
                  }
                },
              ),

              const SizedBox(height: 16),

              SocialButton(
                text: "Continue with Facebook",
                icon: Icons.facebook,
                color: const Color(0xFF1877F2),
                textColor: Colors.white,
                onTap: () async {
                  try {
                    await authService.signInWithFacebook();

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeMainScreen()),
                          (route) => false,
                    );
                  } catch (e) {
                    _showError(context, e.toString());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
