import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fortune_teller_app/core/utils/code_generator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../models/asked_question_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential credential;
      try {
        // Try LOGIN
        credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // SIGN UP
          credential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else if (e.code == 'wrong-password') {
          throw Exception("Incorrect password");
        } else {
          throw Exception(e.message);
        }
      }
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // WEB — Firebase handles Google directly
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // MOBILE — using google_sign_in package
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          // User canceled the sign-in
          return null;
        }
        // Get authentication details
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        // Create a credential from Google auth
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        UserCredential userCredential = await _auth.signInWithCredential(credential);
        print("google $userCredential");

        // Sign in to Firebase with the credential
        return userCredential;
      }
    } catch (e) {

      print("!Error: $e");
      rethrow;
    }
  }

  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) {
        throw Exception(result.message);
      }
      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      print("facebook $userCredential");
      return userCredential;
    } catch (e) {
      print("!Error $e");
      rethrow;
    }
  }

  Future<void> saveUserToFirestore(User user, int selectedPlan) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await userRef.get();

    // If user is NEW
    if (!snapshot.exists) {
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? '',
        'photo': user.photoURL ?? '',
        'provider': user.providerData.first.providerId,
        'plan': selectedPlan,
        'freePremadeRemaining': 0,
        'purchasedRemaining': 0, // Note: Changed from purchasedPremadeRemaining
        'purchasedCustomRemaining': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Existing user → update only
      await userRef.update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> addQuestion({
    required String text,
    required AskedQuestionType type,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef =
    FirebaseFirestore.instance.collection('users').doc(user.uid);

    final userSnapshot = await userRef.get();

    if (!userSnapshot.exists) return;

    // Check premade limit
    if (type == AskedQuestionType.premade) {
      int remaining = userSnapshot['freePremadeRemaining'] ?? 0;

      if (remaining <= 0) {
        throw Exception("No free premade questions left");
      }

      // Decrease count
      await userRef.update({
        'freePremadeRemaining': remaining - 1,
      });
    }

    final id = FirebaseAuth.instance.currentUser?.uid;

    final code = await generateUniqueCode(userRef.collection('questions'));
    // Save question
    await userRef.collection('questions').add({
      'code': code,
      'text': text,
      'type': describeEnum(type), // premade / custom
      "status": "pending",
      'userId': id,
      "answer": null,
      "answeredAt": null,
      "userReply" : null,
      'askedAt': FieldValue.serverTimestamp(),
    });
  }
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Not logged in");

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
  }


  Future<List<AskedQuestion>> fetchQuestions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('questions')
        .orderBy('askedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return AskedQuestion(
        id: doc['id'],
        text: doc['text'],
        type: doc['type'] == 'premade'
            ? AskedQuestionType.premade
            : AskedQuestionType.custom,
        askedAt: (doc['askedAt'] as Timestamp).toDate(),
        status: doc['status'],
        answer: doc['answer'], userReply: doc['userReply'] ?? null
      );
    }).toList();
  }


  Future<void> signOut() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      for (final provider in user.providerData) {
        if (provider.providerId == 'google.com') {
          await _googleSignIn.signOut();
        }

        if (provider.providerId == 'facebook.com') {
          await FacebookAuth.instance.logOut();
        }
      }
    }

    await FirebaseAuth.instance.signOut();
  }

}