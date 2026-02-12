import 'package:flutter/material.dart';

import '../model/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isFromDashboard;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isFromDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isFromDashboard
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isFromDashboard)
            const CircleAvatar(
              radius: 12,
              child: Icon(Icons.person, size: 16),
            ),
          if (!isFromDashboard) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isFromDashboard
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isFromDashboard
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          if (isFromDashboard) const SizedBox(width: 8),
          if (isFromDashboard)
            const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.support_agent, size: 12),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}