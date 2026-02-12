import 'package:flutter/material.dart';

import '../models/question_model.dart';

class QuestionCard extends StatefulWidget {
  final QuestionModel question;
  final int index;
  final VoidCallback onTap;
  final bool isLocked;

  const QuestionCard({
    required this.question,
    required this.index,
    required this.onTap,
    required this.isLocked,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isHovered
                    ? [
                  Colors.deepPurpleAccent.withOpacity(0.15),
                  Colors.purpleAccent.withOpacity(0.1),
                ]
                    : [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isLocked
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(_isHovered ? 0.2 : 0.1),
              ),
              boxShadow: _isHovered && !widget.isLocked
                  ? [
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(widget.question.category).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getCategoryColor(widget.question.category).withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          widget.question.category.toUpperCase(),
                          style: TextStyle(
                            color: _getCategoryColor(widget.question.category),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Question text
                      Text(
                        widget.question.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.question_answer,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Question ${widget.index + 1}",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.isLocked
                                    ? [
                                  Colors.grey.withOpacity(0.3),
                                  Colors.grey.withOpacity(0.1),
                                ]
                                    : [
                                  Colors.blueAccent.withOpacity(0.3),
                                  Colors.purpleAccent.withOpacity(0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  widget.isLocked ? Icons.lock : Icons.auto_awesome,
                                  color: widget.isLocked ? Colors.white70 : Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.isLocked ? "Locked" : "Ask Now",
                                  style: TextStyle(
                                    color: widget.isLocked ? Colors.white70 : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.isLocked)
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orange.withOpacity(0.4)),
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.orange,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'love':
        return Colors.pinkAccent;
      case 'career':
        return Colors.blueAccent;
      case 'finance':
        return Colors.greenAccent;
      case 'health':
        return Colors.tealAccent;
      case 'spirituality':
        return Colors.purpleAccent;
      default:
        return Colors.deepPurpleAccent;
    }
  }
}