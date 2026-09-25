import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageForCode(error.code));
    }
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageForCode(error.code));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageForCode(error.code));
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageForCode(error.code));
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
