import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/referral_models.dart';

class ReferralException implements Exception {
  const ReferralException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ReferralService extends ChangeNotifier {
  ReferralService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    this._preferences,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
      _functions = functions ?? FirebaseFunctions.instance;

  static const _deviceIdKey = 'referral_device_id_v1';
  static const _fallbackCodeKey = 'referral_code_v1';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  SharedPreferences? _preferences;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _referralsSubscription;

  String _referralCode = '';
  List<ReferralModel> _referrals = const [];
  bool _isLoading = false;
  String? _errorMessage;

  String get referralCode => _referralCode;
  List<ReferralModel> get referrals => List.unmodifiable(_referrals);
  int get successfulReferralsCount =>
      _referrals.where((referral) => referral.status == ReferralStatus.completed).length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    await _authSubscription?.cancel();
    _authSubscription = _auth.authStateChanges().listen(_syncUser);
    await _syncUser(_auth.currentUser);
  }

  Future<ReferralCodeValidation> validateCode(String value) async {
    final code = _normalizeCode(value);
    if (code.length < 6) {
      return const ReferralCodeValidation(isValid: false, message: 'Kod jest za krótki.');
    }
    try {
      final result = await _call('validateReferralCode', {'code': code});
      final data = Map<String, dynamic>.from(result.data as Map);
      return ReferralCodeValidation(
        isValid: data['valid'] == true,
        message: data['valid'] == true ? null : 'Nie znaleziono takiego kodu.',
      );
    } on FirebaseFunctionsException catch (error) {
      return ReferralCodeValidation(isValid: false, message: _messageForCode(error.code));
    }
  }

  Future<void> applyCode(String value) async {
    final code = _normalizeCode(value);
    if (code.isEmpty) return;
    try {
      await _call('applyReferralCode', {
        'code': code,
        'deviceId': await _getDeviceId(),
      });
    } on FirebaseFunctionsException catch (error) {
      throw ReferralException(_messageForCode(error.code));
    }
  }

  Future<void> completeReferral() async {
    try {
      await _call('completeReferral', const <String, dynamic>{});
    } on FirebaseFunctionsException catch (error) {
      throw ReferralException(_messageForCode(error.code));
    }
  }

  Future<String> _ensureCode() async {
    final result = await _call('ensureReferralCode', const <String, dynamic>{});
    final data = Map<String, dynamic>.from(result.data as Map);
    final code = data['referralCode'] as String? ?? '';
    if (code.isNotEmpty) {
      _referralCode = code;
      final preferences = await _getPreferences();
      await preferences.setString(_fallbackCodeKey, code);
      notifyListeners();
    }
    return code;
  }

  Future<void> _syncUser(User? user) async {
    await _referralsSubscription?.cancel();
    _referralsSubscription = null;
    _referrals = const [];
    _referralCode = '';
    _errorMessage = null;
    if (user == null) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      await _ensureCode();
      _referralsSubscription = _firestore
          .collection('referrals')
          .where('referrerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              _referrals = snapshot.docs.map(ReferralModel.fromDocument).toList();
              notifyListeners();
            },
            onError: (Object error) {
              _errorMessage = 'Nie udało się pobrać poleceń.';
              debugPrint('Referral stream failed: $error');
              notifyListeners();
            },
          );
    } on Object catch (error) {
      _errorMessage = 'Nie udało się przygotować programu poleceń.';
      debugPrint('Referral initialization failed: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<HttpsCallableResult<dynamic>> _call(
    String name,
    Map<String, dynamic> data,
  ) =>
      _functions.httpsCallable(name).call(data);

  Future<String> _getDeviceId() async {
    final preferences = await _getPreferences();
    final saved = preferences.getString(_deviceIdKey);
    if (saved != null && saved.isNotEmpty) return saved;

    final plugin = DeviceInfoPlugin();
    String? nativeId;
    try {
      if (kIsWeb) {
        final info = await plugin.webBrowserInfo;
        nativeId = '${info.browserName}:${info.userAgent}:${info.platform}';
      } else {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            nativeId = (await plugin.androidInfo).id;
          case TargetPlatform.iOS:
            nativeId = (await plugin.iosInfo).identifierForVendor;
          case TargetPlatform.windows:
            nativeId = (await plugin.windowsInfo).deviceId;
          case TargetPlatform.macOS:
            nativeId = (await plugin.macOsInfo).systemGUID;
          case TargetPlatform.linux:
            nativeId = (await plugin.linuxInfo).machineId;
          case TargetPlatform.fuchsia:
            nativeId = null;
        }
      }
    } on Object catch (error) {
      debugPrint('Could not read native device id: $error');
    }

    final raw = nativeId == null || nativeId.isEmpty
        ? '${DateTime.now().microsecondsSinceEpoch}:${Random.secure().nextInt(1 << 32)}'
        : nativeId;
    final deviceId = base64Url.encode(utf8.encode(raw)).replaceAll('=', '');
    await preferences.setString(_deviceIdKey, deviceId);
    return deviceId;
  }

  Future<SharedPreferences> _getPreferences() async =>
      _preferences ??= await SharedPreferences.getInstance();

  String _normalizeCode(String value) => value.trim().toUpperCase();

  String _messageForCode(String code) {
    switch (code) {
      case 'already-used-device':
        return 'Ten kod został już wykorzystany na tym urządzeniu.';
      case 'self-referral':
        return 'Nie możesz użyć własnego kodu polecającego.';
      case 'invalid-referral-code':
        return 'Nie znaleziono takiego kodu polecającego.';
      case 'already-referred':
        return 'To konto ma już przypisany kod polecający.';
      case 'email-not-verified':
        return 'Potwierdź adres e-mail, aby zaliczyć polecenie.';
      case 'failed-precondition':
        return 'Nie można teraz wykonać tej operacji.';
      default:
        return 'Nie udało się wykonać operacji programu poleceń.';
    }
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    unawaited(_referralsSubscription?.cancel());
    super.dispose();
  }
}
