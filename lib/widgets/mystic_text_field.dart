import 'package:flutter/material.dart';

class MysticTextField extends StatelessWidget {
  final TextEditingController controller;

  const MysticTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: TextField(
        controller: controller,
        maxLines: 6,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.deepPurpleAccent,
        decoration: const InputDecoration(
          hintText: "Write your personalized question here...",
          hintStyle: TextStyle(color: Colors.white54),
          contentPadding: EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
