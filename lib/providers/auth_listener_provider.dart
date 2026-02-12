import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fortune_teller_app/providers/question_provider.dart';

import '../screens/authentication/auth_service.dart';
import 'auth_provider.dart';

final authListenerProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<User?>>(
    authStateProvider,
        (previous, next) async {
      final user = next.asData?.value;
      if (user == null) return;

      // Ensure user exists in Firestore
      final authService = AuthService();
      await authService.saveUserToFirestore(user, 0);

      // 🔥 LOAD USER QUESTION DATA
      await ref.read(questionProvider.notifier).loadFromFirestore();
    },
  );
});

