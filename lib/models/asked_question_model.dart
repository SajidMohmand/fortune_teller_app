enum AskedQuestionType {
  premade,
  custom,
}

class AskedQuestion {
  final String id;
  final String text;
  final AskedQuestionType type;
  final DateTime askedAt;
  String status;
  String? answer;
  String? userReply;

  AskedQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.askedAt,
    required this.status,
    required this.answer,
    required this.userReply,
  });
}
