import 'package:flutter/material.dart';
import 'package:fortune_teller_app/fortune_teller_screens/question_detail_screen.dart';

import '../model/question.dart';
import 'question_card.dart';

class QuestionList extends StatelessWidget {
  final List<Question> questions;

  const QuestionList({super.key, required this.questions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: QuestionCard(
            question: questions[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionDetailScreen(
                    question: questions[index],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
