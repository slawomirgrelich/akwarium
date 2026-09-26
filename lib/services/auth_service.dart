import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    this._preferences,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final SharedPreferences? _preferences;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Firebase Auth sign-in failed: code=${error.code}, '
        'message=${error.message}',
      );
      throw AuthException(_messageForCode(error.code));
    }
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user != null) await _createUserProfile(user);
      return credential;
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Firebase Auth registration failed: code=${error.code}, '
        'message=${error.message}',
      );
      throw AuthException(_messageForCode(error.code));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Firebase Auth password reset failed: code=${error.code}, '
        'message=${error.message}',
      );
      throw AuthException(_messageForCode(error.code));
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      final preferences = _preferences ?? await SharedPreferences.getInstance();
      await preferences.setBool('is_pro_active', false);
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Firebase Auth sign-out failed: code=${error.code}, '
        'message=${error.message}',
      );
      throw AuthException(_messageForCode(error.code));
    }
  }

  Future<void> _createUserProfile(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'isPro': false,
        'subscriptionStatus': 'free',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: false));
    } catch (error) {
      debugPrint('Firestore user profile creation failed: $error');
    }
  }

  String _messageForCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Podany adres e-mail jest nieprawidłowy.';
      case 'user-disabled':
        return 'To konto zostało wyłączone.';
      case 'user-not-found':
      case 'invalid-credential':
        return 'Nieprawidłowy e-mail lub hasło.';
      case 'wrong-password':
        return 'Nieprawidłowe hasło.';
      case 'email-already-in-use':
        return 'Konto z tym adresem e-mail już istnieje.';
      case 'weak-password':
        return 'Hasło jest zbyt słabe. Użyj co najmniej 6 znaków.';
      case 'operation-not-allowed':
        return 'Logowanie e-mailem jest obecnie niedostępne.';
      case 'too-many-requests':
        return 'Zbyt wiele prób. Spróbuj ponownie za chwilę.';
      case 'network-request-failed':
        return 'Brak połączenia z internetem. Sprawdź sieć i spróbuj ponownie.';
      case 'requires-recent-login':
        return 'Zaloguj się ponownie, aby wykonać tę operację.';
      default:
        return 'Wystąpił problem z autoryzacją. Spróbuj ponownie.';
    }
  }
}
