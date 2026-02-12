import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'model/question.dart';
import 'widgets/message_bubble.dart';
import 'model/message.dart';

class QuestionDetailScreen extends StatefulWidget {
  final Question question;

  const QuestionDetailScreen({super.key, required this.question});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [
    Message(
      text: 'Hi, could you help me with this issue?',
      sender: 'user',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Message(
      text: 'Sure, I\'d be happy to help. Can you provide more details?',
      sender: 'dashboard',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 30,),
                  _buildQuestionHeader(),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 24),
                  // _buildMessageTimeline(),
                ],
              ),
            ),
          ),
          // Input area and action buttons
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text with professional typography
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Text(
                  'QUESTION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                // Question content
                Text(
                  widget.question.text,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const SizedBox(height: 20),

          // Status section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.question.status).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(widget.question.status).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STATUS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.question.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _getStatusText(widget.question.status),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(widget.question.status),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Additional content based on status
          if (widget.question.status == 'waiting' && widget.question.answer != null)
            _buildInfoSection(
              context: context,
              title: 'REQUEST FOR MORE INFORMATION',
              content: widget.question.answer!,
              icon: Icons.info_outline,
              color: Colors.orange,
            ),

          if (widget.question.status == 'answered' && widget.question.answer != null)
            _buildInfoSection(
              context: context,
              title: 'FINAL ANSWER',
              content: widget.question.answer!,
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),

          if (widget.question.userReply != null &&
              widget.question.userReply!.trim().isNotEmpty)
            _buildInfoSection(
              context: context,
              title: 'USER REPLY',
              content: widget.question.userReply!,
              icon: Icons.person_outline,
              color: Colors.blue,
            ),

        ],
      ),
    );
  }

// Helper method for styled info sections
  Widget _buildInfoSection({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 8),
                // ✅ Wrap Text with Expanded to avoid overflow
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center, // optional, keeps text centered
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


// Helper method for status colors
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
      case 'pending':
        return Colors.blue;
      case 'waiting':
        return Colors.orange;
      case 'answered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

// Helper method for status display text
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return 'New - Needs Review';
      case 'pending':
        return 'Pending Response';
      case 'waiting':
        return 'Waiting for User Info';
      case 'answered':
        return 'Answered';
      default:
        return status;
    }
  }

// Format date method
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      // Show time if today
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      // Show date if older
      return '${date.day}/${date.month}/${date.year}';
    }
  }


  Widget _buildMessageTimeline() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return MessageBubble(
          message: message,
          isFromDashboard: message.sender == 'dashboard',
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.grey.shade800)),
      ),
      child: Column(
        children: [
          // Action buttons
          _buildActionButtons(),
          const SizedBox(height: 36),
          // Message input
          // _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {

    if (widget.question.status == 'answered') {
      return const SizedBox(); // No buttons
    }

    if (widget.question.status == 'waiting') {
      return
        Row(
          children: [
            Expanded(
                child: _buildActionButton(
                  text: 'Send Final Answer',
                  icon: Icons.send,
                  color: Colors.green,
                  onTap: () => _showMessageDialog(
                    title: 'Send Final Answer',
                    hint: 'Type your answer here...',
                    onSend: (text) {
                      _sendMessage(text, sender: 'dashboard', status: 'answered');
                    },
                  ),
                ))
          ],
        );
    }

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            text: 'Request More Info',
            icon: Icons.info_outline,
            color: Colors.blue,
            onTap: () => _showMessageDialog(
              title: 'Request More Info',
              hint: 'Type your request here...',
              onSend: (text) {
                _sendMessage(text, sender: 'dashboard', status: 'waiting');
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            text: 'Send Final Answer',
            icon: Icons.send,
            color: Colors.green,
            onTap: () => _showMessageDialog(
              title: 'Send Final Answer',
              hint: 'Type your answer here...',
              onSend: (text) {
                _sendMessage(text, sender: 'dashboard', status: 'answered');
              },
            ),
          ),
        ),
        // Expanded(
        //   child: _buildActionButton(
        //     text: 'Mark as Answered',
        //     icon: Icons.check_circle,
        //     color: Colors.purple,
        //     onTap: () {
        //       setState(() {
        //         widget.question.status = 'answered';
        //       });
        //       FirebaseFirestore.instance
        //         .collection('users')
        //         .doc(widget.question.id)
        //         .collection('questions')
        //         .doc(widget.question.id)
        //         .update({'status': 'answered'});
        //     },
        //   ),
        // ),
      ],
    );
  }

  void _sendMessage(String text, {required String sender, String? status}) {
    setState(() {
      _messages.add(Message(
        text: text,
        sender: sender,
        timestamp: DateTime.now(),
      ));
      if (status != null) {
        widget.question.status = status;
      }
    });

    print("khan");
    print(widget.question.userId);
    print(widget.question.id);

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.question.userId)
        .collection('questions')
        .doc(widget.question.id)
        .update({
          'status': status,
          'answer': text,
        });
  }


  void _showMessageDialog({
    required String title,
    required String hint,
    required Function(String) onSend,
  }) {
    final TextEditingController dialogController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: dialogController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (dialogController.text.trim().isNotEmpty) {
                  onSend(dialogController.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }
  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            maxLines: 4,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'Type your message...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          onPressed: () {},
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.send),
        ),
      ],
    );
  }

  // String _formatDate(DateTime date) {
  //   return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  // }
}
