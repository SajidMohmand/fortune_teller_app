import 'package:flutter/material.dart';
import '../providers/question_provider.dart';

class Header extends StatelessWidget {
  final QuestionState state;

  const Header({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose your question",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.purchasedRemaining > 0
                ? "💎 ${state.purchasedRemaining} paid questions left"
                : "✨ ${2 - state.freeUsed} free questions remaining",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
