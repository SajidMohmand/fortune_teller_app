import 'package:flutter/material.dart';

import '../../models/asked_question_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/question_provider.dart';
import '../../widgets/dialog.dart';
import '../../widgets/mystic_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/dialog.dart';

class CustomQuestionScreen extends ConsumerStatefulWidget {
  const CustomQuestionScreen({super.key});

  @override
  ConsumerState<CustomQuestionScreen> createState() =>
      _CustomQuestionScreenState();
}

class _CustomQuestionScreenState extends ConsumerState<CustomQuestionScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(
      parent: _anim,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _anim,
        curve: Curves.easeOutCubic,
      ),
    );

    _anim.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final customRemaining =
        ref.watch(questionProvider).purchasedCustomRemaining;


    return Container(

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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            "Ask a Question",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: customRemaining > 0
                      ? Colors.deepPurpleAccent
                      : Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.edit_note,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$customRemaining left",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),




        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              top: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                        submitHelper();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      "Submit • \$1.99",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "⏳ Replies may take 1–5 business days depending on demand.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ask wisely",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Your question will be personally interpreted by an Olirian fortune teller.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 28),

                      MysticTextField(controller: _controller),


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

  void submitHelper() async{


    final authAsync = ref.read(authStateProvider);
    final isLoggedIn = authAsync.asData?.value != null;
    if (!isLoggedIn) {
      showLoginDialog(context);
      return;
    }

    final state = ref.read(questionProvider);
    if (state.purchasedCustomRemaining <= 0) {
      showOutOfCustomQuestionsDialog(context);
      return;
    }



    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a question."),
        ),
      );
      return;
    }

    try {
      await ref.read(questionProvider.notifier).askQuestion(
        text: _controller.text.trim(),
        type: AskedQuestionType.custom,
      );

      _controller.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✨ Submitted. Response in 1–5 business days."),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
    // ref.read(questionProvider.notifier).saveQuestion(
    //   text: _controller.text.trim(),
    //   type: AskedQuestionType.custom,
    // );


  }
}
