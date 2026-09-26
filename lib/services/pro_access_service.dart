import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_data_model.dart';

class ProAccessService extends ChangeNotifier {
  ProAccessService({
    UserDataModel? user,
    this.preferences,
    this.firebaseAuth,
    this.firestore,
  }) : _user = user ?? const UserDataModel(uid: '');

  static const proStatusKey = 'is_pro_active';

  UserDataModel _user;
  SharedPreferences? preferences;
  final FirebaseAuth? firebaseAuth;
  final FirebaseFirestore? firestore;
  SharedPreferences? _loadedPreferences;
  StreamSubscription<User?>? _authSubscription;

  bool get isProUser => _user.isProUser;
  UserDataModel get user => _user;

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

  Future<void> setProUser(bool value) async {
    final currentUser = _tryGetAuth()?.currentUser;
    final firestore = _tryGetFirestore();
    if (currentUser != null && firestore != null) {
      await firestore.collection('users').doc(currentUser.uid).set({
        'uid': currentUser.uid,
        'isPro': value,
        'subscriptionStatus': value ? 'pro' : 'free',
      }, SetOptions(merge: true));
    }

    await _applyStatus(
      uid: currentUser?.uid ?? '',
      isPro: value,
      preferences: await _getPreferences(),
    );
  }

  Future<void> activateFreeTrial() => setProUser(true);

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
    final firestore = _tryGetFirestore();
    if (firestore != null) {
      try {
        final document = await firestore.collection('users').doc(uid).get();
        if (!document.exists) {
          await firestore.collection('users').doc(uid).set({
            'uid': uid,
            'email': firebaseUser.email,
            'isPro': false,
            'subscriptionStatus': 'free',
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          final data = document.data() ?? const <String, dynamic>{};
          isPro = _readProStatus(data);
        }
      } catch (error) {
        debugPrint('Firestore PRO status sync failed for $uid: $error');
      }
    }

    if (_tryGetAuth()?.currentUser?.uid != uid) return;
    await _applyStatus(uid: uid, isPro: isPro, preferences: storedPreferences);
  }

  bool _readProStatus(Map<String, dynamic> data) {
    final isPro = data['isPro'];
    if (isPro is bool) return isPro;
    final status = data['subscriptionStatus'];
    return status == 'pro' || status == 'active';
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
