class Message {
  final String text;
  final String sender;
  final DateTime timestamp;

  const Message({
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}