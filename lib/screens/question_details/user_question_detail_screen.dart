import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fortune_teller_app/models/asked_question_model.dart';

import '../../fortune_teller_screens/model/question.dart';

class UserQuestionDetailScreen extends StatefulWidget {
  final AskedQuestion question;

  const UserQuestionDetailScreen({super.key, required this.question});

  @override
  State<UserQuestionDetailScreen> createState() =>
      _UserQuestionDetailScreenState();
}

class _UserQuestionDetailScreenState extends State<UserQuestionDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Question')),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statusChip(),
              const SizedBox(height: 16),

              _questionCard(),
              const SizedBox(height: 24),

              if (widget.question.status == 'pending') _pendingView(),
              if (widget.question.status == 'waiting') _waitingView(),
              if (widget.question.status == 'answered') _answeredView(),

              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI SECTIONS ----------------

  Widget _statusChip() {
    Color color;
    String label;

    switch (widget.question.status) {
      case 'waiting':
        color = Colors.orange;
        label = 'More Info Requested';
        break;
      case 'answered':
        color = Colors.green;
        label = 'Answered';
        break;
      default:
        color = Colors.blueGrey;
        label = 'Pending';
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }

  Widget _questionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: Text(
        widget.question.text,
        style: const TextStyle(fontSize: 16, height: 1.4),
      ),
    );
  }

  Widget _pendingView() {
    return const Text(
      '✨ Your question is being reviewed.\nPlease check back soon.',
      style: TextStyle(fontSize: 14),
    );
  }

  Widget _waitingView() {
    final bool hasUserReply =
        widget.question.userReply != null &&
            widget.question.userReply!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The fortune teller needs more information:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Teller's request
        _answerBubble(widget.question.answer),

        const SizedBox(height: 20),

        // ✅ If user already replied → show reply + waiting text
        if (hasUserReply) ...[
          const Text(
            '🧑 Your reply',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          _answerBubble(widget.question.userReply),

          const SizedBox(height: 16),

          const Text(
            '⏳ Please wait for the fortune teller’s final answer.',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ]

        // ❌ If no reply yet → show input + button
        else ...[
          TextField(
            controller: _replyController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Provide more details...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sending ? null : _sendMoreInfo,
              child: _sending
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Send Info'),
            ),
          ),
        ],
      ],
    );
  }


  Widget _answeredView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          '🔮 Your Answer',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        _answerBubble(widget.question.answer),
      ],
    );
  }

  Widget _answerBubble(String? text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text ?? 'No message',
        style: const TextStyle(fontSize: 15, height: 1.5),
      ),
    );
  }

  // ---------------- LOGIC ----------------

  Future<void> _sendMoreInfo() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);

    final id = FirebaseAuth.instance.currentUser?.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('questions')
        .doc(widget.question.id)
        .update({
      // 'status': 'pending',
      'userReply': text,
    });

    if (mounted) Navigator.pop(context);
  }
}
