import 'package:shared_preferences/shared_preferences.dart';

class FirestoreSyncStatus {
  FirestoreSyncStatus._();

  static const _lastSuccessKey = 'firestore_last_successful_sync';

  static Future<void> recordSuccessfulSync() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        _lastSuccessKey,
        DateTime.now().toIso8601String(),
      );
    } on Object {
      // A local status write must not fail an already-successful cloud operation.
    }
  }

  static Future<DateTime?> getLastSuccessfulSync() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final value = preferences.getString(_lastSuccessKey);
      return value == null ? null : DateTime.tryParse(value)?.toLocal();
    } on Object {
      return null;
    }
  }
}
