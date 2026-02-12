import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String text;
  final String userId;
  String status;
  final String type;
  final DateTime askedAt;
  String? answer; // Nullable answer field
  final String? userReply;

  Question({
    required this.id,
    required this.text,
    required this.userId,
    required this.status,
    required this.type,
    required this.askedAt,
    this.answer, // Optional parameter
    this.userReply

  });

  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Question(
      id: doc.id,
      text: data['text'] ?? '',
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'pending',
      type: data['type'] ?? '',
      askedAt: (data['askedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      answer: data['answer'], // Can be null
      userReply: data['userReply']
    );
  }

  // Optional: convert back to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'userId': userId,
      'status': status,
      'type': type,
      'askedAt': Timestamp.fromDate(askedAt),
      'answer': answer,
    };
  }
}
