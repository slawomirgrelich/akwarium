import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class UserActivityService with WidgetsBindingObserver {
  UserActivityService._();

  static final UserActivityService instance = UserActivityService._();

  bool _initialized = false;
  bool _isActive = true;
  DateTime? _lastWrite;
  StreamSubscription<User?>? _authSubscription;
  Timer? _timer;

  void initialize() {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        unawaited(recordActivity(force: true));
      }
    });
    _timer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => unawaited(recordActivity()),
    );
    unawaited(recordActivity(force: true));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isActive = state == AppLifecycleState.resumed;
    if (_isActive) {
      unawaited(recordActivity(force: true));
    }
  }

  Future<void> recordActivity({bool force = false}) async {
    if (!_isActive) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final now = DateTime.now();
    if (!force &&
        _lastWrite != null &&
        now.difference(_lastWrite!) < const Duration(minutes: 5)) {
      return;
    }
    try {
      final reference = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(reference);
        if (!snapshot.exists) {
          transaction.set(reference, {
            'uid': user.uid,
            if (user.email != null) 'email': user.email,
            'isPro': false,
            'successfulReferralsCount': 0,
            'subscriptionStatus': 'free',
            'hasUsedTrial': false,
            'has_used_trial_v1': false,
            'createdAt': FieldValue.serverTimestamp(),
            'lastActiveAt': FieldValue.serverTimestamp(),
          });
          return;
        }
        transaction.update(reference, {
          'lastActiveAt': FieldValue.serverTimestamp(),
        });
      });
      _lastWrite = now;
    } on Object catch (error, stackTrace) {
      debugPrint('Last activity update failed: $error\n$stackTrace');
    }
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    await _authSubscription?.cancel();
  }
}
