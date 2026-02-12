import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../fortune_teller_screens/question_dashboard_app.dart';
import '../providers/disclaimer_provider.dart';
import '../widgets/disclaimer_card.dart';
import 'home_main_screen.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DisclaimerScreen extends ConsumerStatefulWidget {
  const DisclaimerScreen({super.key});

  @override
  ConsumerState<DisclaimerScreen> createState() =>
      _DisclaimerScreenState();
}

class _DisclaimerScreenState
    extends ConsumerState<DisclaimerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _fade =
  const AlwaysStoppedAnimation(0);

  late Animation<double> _float =
  const AlwaysStoppedAnimation(12);


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _float = Tween<double>(
      begin: 12,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                  Navigator.pop(context);
                  _goToFortuneDashboard(context);
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

  void _goToFortuneDashboard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QuestionDashboardApp(), // or DashboardScreen
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final agreed = ref.watch(disclaimerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Disclaimer"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.admin_panel_settings),
          color: Colors.white,
          tooltip: 'Fortune Teller Dashboard',
          onPressed: () {
            _showPasswordDialog(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF1C313A),
              Color(0xFF243B55),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fade.value,
                child: Transform.translate(
                  offset: Offset(0, _float.value),
                  child: child,
                ),
              );
            },
            child: SafeArea(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fade.value,
                    child: Transform.translate(
                      offset: Offset(0, _float.value),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // 🔹 Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),

                              const Text(
                                "Before we begin",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 8),

                              const Text(
                                "Please review and accept the terms below to continue.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 28),

                              DisclaimerCard(),

                              const SizedBox(height: 20),

                              Theme(
                                data: Theme.of(context).copyWith(
                                  unselectedWidgetColor: Colors.white54,
                                ),
                                child: CheckboxListTile(
                                  value: agreed,
                                  activeColor: Colors.deepPurpleAccent,
                                  onChanged: (v) {
                                    ref.read(disclaimerProvider.notifier).state =
                                        v ?? false;
                                  },
                                  title: const Text(
                                    "I confirm that I am 18+ and agree",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                  ListTileControlAffinity.leading,
                                ),
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),

                      // 🔹 Fixed bottom button (keyboard-aware)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: agreed
                                ? [
                              BoxShadow(
                                color: Colors.deepPurpleAccent
                                    .withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                                : [],
                          ),
                          child: ElevatedButton(
                            onPressed: agreed
                                ? () => _acceptDisclaimer(context)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              disabledBackgroundColor: Colors.white12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: agreed ? Colors.white : Colors.white54,
                              ),
                            ),

                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ),
        ),
      ),
    );
  }


  Future<void> _acceptDisclaimer(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('acceptedDisclaimer', true);

    // Navigate to home
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomeMainScreen()));
  }

}
