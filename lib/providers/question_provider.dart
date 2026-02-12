import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';


import '../models/asked_question_model.dart';
import 'auth_provider.dart';

class QuestionState {
  final int freeUsed;
  final int purchasedRemaining;
  final int purchasedCustomRemaining;
  final List<AskedQuestion> history;

  QuestionState({
    this.freeUsed = 0,
    this.purchasedRemaining = 0,
    this.purchasedCustomRemaining = 0,
    this.history = const [],
  });

  QuestionState copyWith({
    int? freeUsed,
    int? purchasedRemaining,
    int? purchasedCustomRemaining,
    List<AskedQuestion>? history,
  }) {
    return QuestionState(
      freeUsed: freeUsed ?? this.freeUsed,
      purchasedRemaining:
      purchasedRemaining ?? this.purchasedRemaining,
      purchasedCustomRemaining: purchasedCustomRemaining ?? this.purchasedCustomRemaining,
      history: history ?? this.history,
    );
  }
}


final questionProvider =
StateNotifierProvider<QuestionNotifier, QuestionState>((ref) {
  return QuestionNotifier();
});

final userQuestionsProvider =
StreamProvider.autoDispose<List<AskedQuestion>>((ref) {

  final authUser = ref.watch(authStateProvider).asData?.value;

  if (authUser == null) {
    return Stream.value(<AskedQuestion>[]);

  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(authUser.uid)
      .collection('questions')
      .orderBy('askedAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return AskedQuestion(
        id: doc.id,
        text: doc['text'],
        type: doc['type'] == 'premade'
            ? AskedQuestionType.premade
            : AskedQuestionType.custom,
        askedAt: (doc['askedAt'] as Timestamp).toDate(),
        status: doc['status'] ?? 'pending',
        answer: doc['answer'],
        userReply: doc['userReply'],
      );
    }).toList();
  });
});


final questionDetailProvider =
StreamProvider.family<AskedQuestion, String>((ref, questionId) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("Not logged in");
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('questions')
      .doc(questionId)
      .snapshots()
      .map((doc) {
    return AskedQuestion(
      id: doc.id,
      text: doc['text'],
      type: doc['type'] == 'premade'
          ? AskedQuestionType.premade
          : AskedQuestionType.custom,
      askedAt: (doc['askedAt'] as Timestamp).toDate(),
      status: doc['status'],
      answer: doc['answer'], userReply: doc["userReply"] ?? null
    );
  });
});


class QuestionNotifier extends StateNotifier<QuestionState> {
  QuestionNotifier() : super(QuestionState());

  bool canAskFree() => state.freeUsed < 2;

  Future<void> useFreeQuestion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userSnap = await userRef.get();

    if (!userSnap.exists) return;

    final freeRemaining = (userSnap['freePremadeRemaining'] as num?)?.toInt() ?? 2;

    if (freeRemaining > 0) {
      await userRef.update({
        'freePremadeRemaining': freeRemaining - 1,
      });

      state = state.copyWith(freeUsed: state.freeUsed + 1);
    }
  }

  Future<void> usePurchasedQuestion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userSnap = await userRef.get();

    if (!userSnap.exists) return;

    final purchasedRemaining = (userSnap['purchasedRemaining'] as num?)?.toInt() ?? 0;

    if (purchasedRemaining > 0) {
      await userRef.update({
        'purchasedRemaining': purchasedRemaining - 1,
      });

      state = state.copyWith(purchasedRemaining: purchasedRemaining - 1);
    }
  }

  void addPurchasedQuestions(int count) {
    state = state.copyWith(
      purchasedRemaining: state.purchasedRemaining + count,
    );
  }

  Future<void> addPremadeQuestions(int count) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Not logged in");

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userSnap = await userRef.get();

    if (!userSnap.exists) throw Exception("User document not found");

    final currentPurchased = (userSnap['purchasedRemaining'] as num?)?.toInt() ?? 0;
    final newTotal = currentPurchased + count;

    // Update Firestore
    await userRef.update({
      'purchasedRemaining': newTotal,
    });

    // Update local state
    state = state.copyWith(purchasedRemaining: newTotal);
  }

  Future<void> addCustomQuestions(int count) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Not logged in");

    final userRef =
    FirebaseFirestore.instance.collection('users').doc(user.uid);

    final newTotal = state.purchasedCustomRemaining + count;

    // Update Firestore
    await userRef.update({
      'purchasedCustomRemaining': newTotal,
    });

    // Update local state
    state = state.copyWith(purchasedCustomRemaining: newTotal);
  }


  /// ⭐ NEW — save asked question
  void saveQuestion({
    required String text,
    required AskedQuestionType type,
  }) {
    final newQuestion = AskedQuestion(
      id: "0",
      text: text,
      type: type,
      askedAt: DateTime.now(),
      status: "pending", answer: '', userReply: null,
    );

    state = state.copyWith(
      history: [newQuestion, ...state.history],
    );
  }

  Future<void> loadFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userSnap = await userRef.get();

    if (!userSnap.exists) return;

    // Read from Firestore
    final int freeRemaining = (userSnap['freePremadeRemaining'] as num?)?.toInt() ?? 2;
    final int purchasedRemaining = (userSnap['purchasedRemaining'] as num?)?.toInt() ?? 0;
    final int purchasedCustomRemaining = (userSnap['purchasedCustomRemaining'] as num?)?.toInt() ?? 0;

    // Calculate freeUsed from freeRemaining
    final int freeUsed = 2 - freeRemaining;

    // Fetch questions
    final questionsSnap = await userRef
        .collection('questions')
        .orderBy('askedAt', descending: true)
        .get();

    final history = questionsSnap.docs.map((doc) {
      return AskedQuestion(
        id: doc.id,
        text: doc['text'],
        type: doc['type'] == 'premade'
            ? AskedQuestionType.premade
            : AskedQuestionType.custom,
        askedAt: (doc['askedAt'] as Timestamp).toDate(),
        status: doc['status'] ?? 'pending',
        answer: doc['answer'],
        userReply: doc['userReply'],
      );
    }).toList();

    state = state.copyWith(
      freeUsed: freeUsed,
      purchasedRemaining: purchasedRemaining,
      purchasedCustomRemaining: purchasedCustomRemaining,
      history: history,
    );
  }

  Future<void> askQuestion({
    required String text,
    required AskedQuestionType type,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Not logged in");

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userSnap = await userRef.get();

    if (!userSnap.exists) throw Exception("User document not found");

    // 🔒 LIMIT CHECKS
    if (type == AskedQuestionType.premade) {
      final freeRemaining = (userSnap['freePremadeRemaining'] as num?)?.toInt() ?? 2;
      final purchasedRemaining = (userSnap['purchasedRemaining'] as num?)?.toInt() ?? 0;

      if (freeRemaining > 0) {
        // Use free question
        await userRef.update({
          'freePremadeRemaining': freeRemaining - 1,
        });

        // Update local state
        state = state.copyWith(
          freeUsed: state.freeUsed + 1,
        );
      } else if (purchasedRemaining > 0) {
        // Use purchased question
        await userRef.update({
          'purchasedRemaining': purchasedRemaining - 1,
        });

        // Update local state
        state = state.copyWith(
          purchasedRemaining: purchasedRemaining - 1,
        );
      } else {
        throw Exception("No questions left");
      }
    }

    if (type == AskedQuestionType.custom) {
      final purchasedCustomRemaining = (userSnap['purchasedCustomRemaining'] as num?)?.toInt() ?? 0;

      if (purchasedCustomRemaining <= 0) {
        throw Exception("No custom questions remaining");
      }

      await userRef.update({
        'purchasedCustomRemaining': purchasedCustomRemaining - 1,
      });

      // Update local state
      state = state.copyWith(
        purchasedCustomRemaining: purchasedCustomRemaining - 1,
      );
    }

    final id = FirebaseAuth.instance.currentUser?.uid;


    // Save to Firestore first
    final questionRef = await userRef.collection('questions').add({
      'text': text,
      'type': describeEnum(type), // premade / custom
      'userId': id,
      'status': 'pending',
      'answer': null,
      'answeredAt': null,
      'userReply': null,
      'askedAt': FieldValue.serverTimestamp(),
    });

    // Save locally with the correct ID
    final newQuestion = AskedQuestion(
      id: questionRef.id, // Get the Firestore document ID
      text: text,
      type: type,
      askedAt: DateTime.now(),
      status: 'pending',
      answer: null,
      userReply: null,
    );

    state = state.copyWith(
      history: [newQuestion, ...state.history],
    );

  }

}
