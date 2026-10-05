import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firestore_sync_status.dart';

class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;
  final String? code;

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
  static Future<void>? _googleSignInInitialization;
  static const _googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
  static const _googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final UserCredential credential;
      if (kIsWeb) {
        credential = await _firebaseAuth.signInWithPopup(GoogleAuthProvider());
      } else {
        if (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.macOS) {
          throw const AuthException(
            'Google Sign-In is not supported on this platform.',
            code: 'google-sign-in-unsupported',
          );
        }

        await _ensureGoogleSignInInitialized();
        final googleAccount = await GoogleSignIn.instance.authenticate();
        final idToken = googleAccount.authentication.idToken;
        if (idToken == null || idToken.isEmpty) {
          throw const AuthException(
            'Google Sign-In is not configured for this app.',
            code: 'google-sign-in-configuration',
          );
        }

        credential = await _firebaseAuth.signInWithCredential(
          GoogleAuthProvider.credential(idToken: idToken),
        );
      }

      final user = credential.user;
      if (user != null) {
        if (credential.additionalUserInfo?.isNewUser ?? false) {
          unawaited(_createUserProfile(user));
        } else {
          unawaited(_updateGoogleUserIdentity(user));
        }
      }
      return credential;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      debugPrint('Google Sign-In failed: $error');
      final code = switch (error.code) {
        GoogleSignInExceptionCode.clientConfigurationError ||
        GoogleSignInExceptionCode.providerConfigurationError =>
          'google-sign-in-configuration',
        GoogleSignInExceptionCode.uiUnavailable => 'google-sign-in-unsupported',
        _ => 'google-sign-in-failed',
      };
      throw AuthException('Google sign-in failed.', code: code);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'popup-closed-by-user') return null;
      debugPrint(
        'Firebase Google credential exchange failed: '
        'code=${error.code}, message=${error.message}',
      );
      if (error.code == 'operation-not-allowed') {
        throw const AuthException(
          'Google Sign-In is not configured for this app.',
          code: 'google-sign-in-configuration',
        );
      }
      throw AuthException(_messageForCode(error.code), code: error.code);
    } on AuthException {
      rethrow;
    } on UnsupportedError catch (error) {
      debugPrint('Google Sign-In unavailable on this platform: $error');
      throw const AuthException(
        'Google Sign-In is not supported on this platform.',
        code: 'google-sign-in-unsupported',
      );
    } on Object catch (error, stackTrace) {
      debugPrint('Google Sign-In failed unexpectedly: $error\n$stackTrace');
      throw const AuthException(
        'Google Sign-In failed.',
        code: 'google-sign-in-failed',
      );
    }
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    var initialization = _googleSignInInitialization;
    if (initialization == null) {
      final iosClientId = _googleIosClientId.trim();
      final serverClientId = _googleServerClientId.trim();
      initialization = GoogleSignIn.instance.initialize(
        clientId:
            (defaultTargetPlatform == TargetPlatform.iOS ||
                    defaultTargetPlatform == TargetPlatform.macOS) &&
                iosClientId.isNotEmpty
            ? iosClientId
            : null,
        serverClientId: serverClientId.isEmpty ? null : serverClientId,
      );
      _googleSignInInitialization = initialization;
    }
    try {
      await initialization;
    } on Object {
      if (identical(_googleSignInInitialization, initialization)) {
        _googleSignInInitialization = null;
      }
      rethrow;
    }
  }

  Future<void> _updateGoogleUserIdentity(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        if (user.email != null) 'email': user.email,
        if (user.displayName != null) 'displayName': user.displayName,
        if (user.photoURL != null) 'photoURL': user.photoURL,
      }, SetOptions(merge: true));
      await FirestoreSyncStatus.recordSuccessfulSync();
    } on Object catch (error, stackTrace) {
      debugPrint('Google user profile refresh failed: $error\n$stackTrace');
    }
  }

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
      throw AuthException(_messageForCode(error.code), code: error.code);
    }
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (_isTemporaryEmail(normalizedEmail)) {
      throw const AuthException(
        'Użyj stałego adresu e-mail, aby utworzyć konto.',
      );
    }

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.sendEmailVerification();
        await _createUserProfile(user);
      }
      return credential;
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Firebase Auth registration failed: code=${error.code}, '
        'message=${error.message}',
      );
      throw AuthException(_messageForCode(error.code), code: error.code);
    }
  }

  bool _isTemporaryEmail(String email) {
    const blockedDomains = {
      '10minutemail.com',
      '10minutemail.net',
      'dispostable.com',
      'guerrillamail.com',
      'maildrop.cc',
      'mailinator.com',
      'inboxkitten.com',
      'sharklasers.com',
      'temp-mail.org',
      'tempmail.com',
      'tempmail.dev',
      'yopmail.com',
    };
    final atIndex = email.lastIndexOf('@');
    return atIndex == -1 ||
        blockedDomains.contains(email.substring(atIndex + 1));
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Firebase Auth password reset failed: code=${error.code}, '
        'message=${error.message}',
      );
      throw AuthException(_messageForCode(error.code), code: error.code);
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      final googleInitialization = _googleSignInInitialization;
      if (googleInitialization != null) {
        try {
          await googleInitialization;
          await GoogleSignIn.instance.signOut();
        } on Object catch (error, stackTrace) {
          debugPrint('Google Sign-In sign-out failed: $error\n$stackTrace');
        }
      }
      final preferences = _preferences ?? await SharedPreferences.getInstance();
      await preferences.setBool('is_pro_active', false);
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Firebase Auth sign-out failed: code=${error.code}, '
        'message=${error.message}',
      );
      throw AuthException(_messageForCode(error.code), code: error.code);
    }
  }

  Future<void> _createUserProfile(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'isPro': false,
        'successfulReferralsCount': 0,
        'subscriptionStatus': 'free',
        'hasUsedTrial': false,
        'has_used_trial_v1': false,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await FirestoreSyncStatus.recordSuccessfulSync();
    } catch (error) {
      debugPrint('Firestore user profile creation failed: $error');
    }
  }

  String _messageForCode(String code) {
    switch (code) {
      case 'google-sign-in-configuration':
        return 'Google Sign-In is not configured for this app.';
      case 'google-sign-in-unsupported':
        return 'Google Sign-In is not supported on this platform.';
      case 'google-sign-in-failed':
        return 'Google Sign-In failed. Try again.';
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
