import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_data_model.dart';

enum TrialActivationResult {
  activated,
  alreadyUsed,
  emailNotVerified,
  temporaryEmail,
  unavailable,
}

class ProAccessService extends ChangeNotifier {
  ProAccessService({
    UserDataModel? user,
    this.preferences,
    this.firebaseAuth,
    this.firestore,
  }) : _user = user ?? const UserDataModel(uid: '');

  static const proStatusKey = 'is_pro_active';
  static const _hasUsedTrialKey = 'has_used_trial';
  static const _hasUsedTrialFirestoreKey = 'has_used_trial_v1';
  static const _deviceIdKey = 'trial_device_id';
  static const _trialCollection = 'trial_registrations';
  static const _trialDuration = Duration(days: 7);
  static const _temporaryEmailDomains = <String>{
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

  UserDataModel _user;
  SharedPreferences? preferences;
  final FirebaseAuth? firebaseAuth;
  final FirebaseFirestore? firestore;
  SharedPreferences? _loadedPreferences;
  StreamSubscription<User?>? _authSubscription;
  bool _trialExpired = false;
  String? _lastTrialError;

  bool get isProUser => _user.isProUser;
  UserDataModel get user => _user;
  bool get trialExpired => _trialExpired;
  String? get lastTrialError => _lastTrialError;

  bool consumeTrialExpired() {
    if (!_trialExpired) return false;
    _trialExpired = false;
    return true;
  }

  Future<void> init() async {
    final storedPreferences = await _getPreferences();
    final auth = _tryGetAuth();
    if (auth == null) {
      await _applyStatus(uid: '', isPro: false, preferences: storedPreferences);
      return;
    }

    await _authSubscription?.cancel();
    _authSubscription = auth.authStateChanges().listen(_syncUser);
    await _syncUser(auth.currentUser);
  }

  Future<TrialActivationResult> startFreeTrial() async {
    _lastTrialError = null;
    final auth = _tryGetAuth();
    var currentUser = auth?.currentUser;
    if (currentUser == null) return TrialActivationResult.unavailable;

    try {
      await currentUser.reload();
      currentUser = auth?.currentUser;
    } on FirebaseAuthException catch (error) {
      _lastTrialError = _messageForFirebaseError(error);
      debugPrint(
        'Firebase Auth trial user refresh failed: code=${error.code}, '
        'message=${error.message}',
      );
      return TrialActivationResult.unavailable;
    }

    if (currentUser == null) {
      _lastTrialError = 'Sesja wygasła. Zaloguj się ponownie.';
      return TrialActivationResult.unavailable;
    }
    if (!currentUser.emailVerified) {
      _lastTrialError = 'Potwierdź adres e-mail, a następnie odśwież konto i spróbuj ponownie.';
      return TrialActivationResult.emailNotVerified;
    }

    final email = currentUser.email?.trim().toLowerCase() ?? '';
    if (_isTemporaryEmail(email)) {
      return TrialActivationResult.temporaryEmail;
    }

    final firestore = _tryGetFirestore();
    if (firestore == null) {
      _lastTrialError = 'Firebase Firestore nie jest dostępny.';
      return TrialActivationResult.unavailable;
    }

    try {
      final storedPreferences = await _getPreferences();
      if (storedPreferences.getBool(_hasUsedTrialKey) ?? false) {
        await _setFreeForCurrentUser();
        return TrialActivationResult.alreadyUsed;
      }

      final deviceId = await _getDeviceId();
      final emailKey = email.replaceAll(RegExp(r'[^a-z0-9]'), '_');
      final userReference = firestore.collection('users').doc(currentUser.uid);
      final accountReference = firestore
          .collection(_trialCollection)
          .doc('account_${currentUser.uid}');
      final deviceReference = firestore
          .collection(_trialCollection)
          .doc('device_$deviceId');
      final emailReference = firestore
          .collection(_trialCollection)
          .doc('email_$emailKey');
      final trialEndsAt = DateTime.now().toUtc().add(_trialDuration);
      final trialActivatedAt = DateTime.now().toUtc();
      final registration = {
        'uid': currentUser.uid,
        'email': email,
        'deviceId': deviceId,
        'registeredAt': FieldValue.serverTimestamp(),
        _hasUsedTrialFirestoreKey: true,
        'trialActivatedAt': Timestamp.fromDate(trialActivatedAt),
        'trialEndsAt': Timestamp.fromDate(trialEndsAt),
      };
      await firestore.runTransaction((transaction) async {
        final user = await transaction.get(userReference);
        final account = await transaction.get(accountReference);
        final device = await transaction.get(deviceReference);
        final emailRegistration = await transaction.get(emailReference);
        final userData = user.data() ?? const <String, dynamic>{};
        final profileUsed =
            userData['hasUsedTrial'] == true ||
            userData[_hasUsedTrialFirestoreKey] == true ||
            userData['trialActivatedAt'] != null;
        if (profileUsed ||
            account.exists ||
            device.exists ||
            emailRegistration.exists) {
          throw const _TrialAlreadyUsed();
        }
        transaction.set(accountReference, registration);
        transaction.set(deviceReference, registration);
        transaction.set(emailReference, registration);
      });
      await userReference.set({
        'uid': currentUser.uid,
        'isPro': true,
        'subscriptionStatus': 'trial',
        'hasUsedTrial': true,
        _hasUsedTrialFirestoreKey: true,
        'trialActivatedAt': Timestamp.fromDate(trialActivatedAt),
        'trialEndsAt': Timestamp.fromDate(trialEndsAt),
      }, SetOptions(merge: true));
      _trialExpired = false;
      await storedPreferences.setBool(_hasUsedTrialKey, true);
      await _applyStatus(
        uid: currentUser.uid,
        isPro: true,
        preferences: await _getPreferences(),
      );
      return TrialActivationResult.activated;
    } on _TrialAlreadyUsed {
      await _setFreeForCurrentUser();
      return TrialActivationResult.alreadyUsed;
    } catch (error) {
      _lastTrialError = _messageForFirebaseError(error);
      debugPrint('Free PRO trial activation failed: $error');
      return TrialActivationResult.unavailable;
    }
  }

  Future<void> setProUser(bool value) async {
    final currentUser = _tryGetAuth()?.currentUser;
    final firestore = _tryGetFirestore();
    if (currentUser != null && firestore != null) {
      await firestore.collection('users').doc(currentUser.uid).set({
        'uid': currentUser.uid,
        'isPro': value,
        'subscriptionStatus': value ? 'pro' : 'free',
        if (!value) 'trialEndsAt': FieldValue.delete(),
      }, SetOptions(merge: true));
    }

    await _applyStatus(
      uid: currentUser?.uid ?? '',
      isPro: value,
      preferences: await _getPreferences(),
    );
  }

  Future<void> activateFreeTrial() async {
    await startFreeTrial();
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    super.dispose();
  }

  Future<void> _syncUser(User? firebaseUser) async {
    final storedPreferences = await _getPreferences();
    if (firebaseUser == null) {
      await _applyStatus(uid: '', isPro: false, preferences: storedPreferences);
      return;
    }

    final uid = firebaseUser.uid;
    var isPro = false;
    var expiredTrial = false;
    final firestore = _tryGetFirestore();
    if (firestore != null) {
      try {
        final reference = firestore.collection('users').doc(uid);
        final document = await reference.get();
        if (!document.exists) {
          await reference.set({
            'uid': uid,
            'email': firebaseUser.email,
            'isPro': false,
            'subscriptionStatus': 'free',
            'hasUsedTrial': false,
            _hasUsedTrialFirestoreKey: false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          final data = document.data() ?? const <String, dynamic>{};
          final trialEndsAt = _readTimestamp(data['trialEndsAt']);
          final subscriptionActive =
              data['subscriptionStatus'] == 'active' ||
              data['subscriptionStatus'] == 'pro';
          final trialActive =
              trialEndsAt != null &&
              trialEndsAt.isAfter(DateTime.now().toUtc());
          isPro = subscriptionActive || trialActive;
          expiredTrial =
              data['subscriptionStatus'] == 'trial' &&
              trialEndsAt != null &&
              !trialActive;
          if (expiredTrial) {
            await reference.set({
              'isPro': false,
              'subscriptionStatus': 'free',
              'trialEndsAt': FieldValue.delete(),
            }, SetOptions(merge: true));
          }
        }
      } catch (error) {
        debugPrint('Firestore PRO status sync failed for $uid: $error');
      }
    }

    if (_tryGetAuth()?.currentUser?.uid != uid) return;
    _trialExpired = expiredTrial;
    await _applyStatus(uid: uid, isPro: isPro, preferences: storedPreferences);
  }

  bool _isTemporaryEmail(String email) {
    final atIndex = email.lastIndexOf('@');
    if (atIndex == -1) return true;
    return _temporaryEmailDomains.contains(email.substring(atIndex + 1));
  }

  String _messageForFirebaseError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-token-expired':
        case 'requires-recent-login':
          return 'Sesja wygasła. Zaloguj się ponownie i spróbuj jeszcze raz.';
        case 'network-request-failed':
          return 'Brak połączenia z internetem. Spróbuj ponownie.';
        default:
          return error.message ?? 'Nie udało się odświeżyć danych konta.';
      }
    }
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Brak uprawnień do zapisu trialu w Firestore. Sprawdź reguły bezpieczeństwa.';
        case 'unauthenticated':
          return 'Sesja wygasła. Zaloguj się ponownie.';
        case 'unavailable':
          return 'Firestore jest chwilowo niedostępny. Spróbuj ponownie.';
        case 'network-request-failed':
          return 'Brak połączenia z internetem. Spróbuj ponownie.';
        default:
          return 'Firestore zwrócił błąd: ${error.code}.';
      }
    }
    return 'Nie udało się zapisać aktywacji trialu: $error';
  }

  DateTime? _readTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value.toUtc();
    return null;
  }

  Future<String> _getDeviceId() async {
    final storedPreferences = await _getPreferences();
    final existing = storedPreferences.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final random = Random.secure();
    final deviceId = List<String>.generate(
      32,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
    await storedPreferences.setString(_deviceIdKey, deviceId);
    return deviceId;
  }

  Future<void> _setFreeForCurrentUser() async {
    final currentUser = _tryGetAuth()?.currentUser;
    final firestore = _tryGetFirestore();
    final storedPreferences = await _getPreferences();
    await storedPreferences.setBool(_hasUsedTrialKey, true);
    if (currentUser == null || firestore == null) return;

    try {
      await firestore.collection('users').doc(currentUser.uid).set({
        'isPro': false,
        'subscriptionStatus': 'free',
        'hasUsedTrial': true,
        _hasUsedTrialFirestoreKey: true,
        'trialEndsAt': FieldValue.delete(),
      }, SetOptions(merge: true));
      await _applyStatus(
        uid: currentUser.uid,
        isPro: false,
        preferences: storedPreferences,
      );
    } catch (error) {
      _lastTrialError = _messageForFirebaseError(error);
      debugPrint('Free plan fallback failed: $error');
    }
  }

  Future<void> _applyStatus({
    required String uid,
    required bool isPro,
    required SharedPreferences preferences,
  }) async {
    await preferences.setBool(proStatusKey, isPro);
    if (_user.uid == uid && _user.isProUser == isPro) return;
    _user = _user.copyWith(uid: uid, isProUser: isPro);
    notifyListeners();
  }

  Future<SharedPreferences> _getPreferences() async {
    return _loadedPreferences ??=
        preferences ?? await SharedPreferences.getInstance();
  }

  FirebaseAuth? _tryGetAuth() {
    try {
      if (firebaseAuth == null && Firebase.apps.isEmpty) return null;
      return firebaseAuth ?? FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? _tryGetFirestore() {
    try {
      return firestore ?? FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }
}

class _TrialAlreadyUsed implements Exception {
  const _TrialAlreadyUsed();
}
