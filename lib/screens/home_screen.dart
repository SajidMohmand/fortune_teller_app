import 'package:flutter/material.dart';
import 'package:fortune_teller_app/screens/question_details/user_question_detail_screen.dart';
import '../models/asked_question_model.dart';
import '../providers/question_provider.dart';
import 'pre_made_question/premade_questions_screen.dart';
import 'custom_question/custom_question_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load user data from Firestore when app starts
      ref.read(questionProvider.notifier).loadFromFirestore();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(userQuestionsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "🔮 Olirian Fortune Teller",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Seek wisdom beyond the veil",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      const SizedBox(height: 48),

                      questionsAsync.when(

                        data: (history) {
                          if (history.isEmpty) {
                            return Center(child: _emptyStateUI());
                          }

                          return Expanded(
                            child: ListView(
                              children: [
                                const Text(
                                  "Your Questions",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ...history.map(
                                      (q) => _QuestionCard(question: q),
                                ),
                              ],
                            ),
                          );
                        },

                        loading: () => const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        error: (e, _) => Text(
                          'Error loading questions',
                          style: TextStyle(color: Colors.red[300]),
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

  Widget _emptyStateUI() {
    return Column(
      children: [
        _ActionButton(
          label: "Choose a Pre-Made Question",
          icon: Icons.auto_awesome,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PremadeQuestionsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _ActionButton(
          label: "Write My Own Question  •  \$1.99",
          icon: Icons.edit,
          primary: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CustomQuestionScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final AskedQuestion question;

  const _QuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    if(question.userReply != null && question.status == 'waiting'){
      statusColor = Colors.orange;
      statusText = 'wait for final answer';
    } else {
      switch (question.status) {
        case 'waiting':
          statusColor = Colors.orange;
          statusText = 'Needs Info';
          break;
        case 'answered':
          statusColor = Colors.green;
          statusText = 'Answered';
          break;
        default:
          statusColor = Colors.blueGrey;
          statusText = 'Pending';
      }
    }


      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  UserQuestionDetailScreen(question: question),
            ),
          );
        },

        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                question.type == AskedQuestionType.premade
                    ? Icons.auto_awesome
                    : Icons.edit,
                color: Colors.deepPurpleAccent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: statusColor.withOpacity(0.15),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      );

  }


}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 6,
          backgroundColor: primary ? Colors.deepPurpleAccent : Colors.white10,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}