import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

String generate8CharCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();

  return List.generate(
    8,
        (index) => chars[random.nextInt(chars.length)],
  ).join();
}
Future<String> generateUniqueCode(CollectionReference ref) async {
  String code;
  bool exists = true;

  do {
    code = generate8CharCode();
    final snapshot = await ref.where('code', isEqualTo: code).limit(1).get();
    exists = snapshot.docs.isNotEmpty;
  } while (exists);

  return code;
}
