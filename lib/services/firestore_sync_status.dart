import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreSyncStatus {
  FirestoreSyncStatus._();

  static const _lastSuccessKeyPrefix = 'firestore_last_successful_sync';

  static String? _keyForCurrentUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid == null || uid.isEmpty ? null : '${_lastSuccessKeyPrefix}_$uid';
  }

  static Future<void> recordSuccessfulSync() async {
    try {
      final key = _keyForCurrentUser();
      if (key == null) return;
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        key,
        DateTime.now().toIso8601String(),
      );
    } on Object {
      // A local status write must not fail an already-successful cloud operation.
    }
  }

  static Future<DateTime?> getLastSuccessfulSync() async {
    try {
      final key = _keyForCurrentUser();
      if (key == null) return null;
      final preferences = await SharedPreferences.getInstance();
      final value = preferences.getString(key);
      return value == null ? null : DateTime.tryParse(value)?.toLocal();
    } on Object {
      return null;
    }
  }
}
