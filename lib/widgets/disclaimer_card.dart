import 'package:flutter/material.dart';

class DisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Text(
        "This app is for entertainment purposes only.\n\n"
            "You must be 18 years or older to use this app.\n\n"
            "No content provided should be considered medical, "
            "legal, or financial advice.",
        style: TextStyle(
          color: Colors.white70,
          height: 1.5,
          fontSize: 14,
        ),
      ),
    );
  }
}
