import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/ticket_models.dart';

enum TicketServiceErrorCode {
  authRequired,
  subjectRequired,
  descriptionTooShort,
  permission,
  offline,
  missingIndex,
  generic,
}

class TicketServiceException implements Exception {
  const TicketServiceException(this.code);

  final TicketServiceErrorCode code;

  @override
  String toString() => code.name;
}

class TicketService extends ChangeNotifier {
  TicketService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance {
    _authSubscription = _auth.authStateChanges().listen(_syncUser);
    unawaited(_syncUser(_auth.currentUser));
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _ticketsSubscription;

  List<TicketModel> _tickets = const [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  TicketServiceErrorCode? _errorCode;

  List<TicketModel> get tickets => List.unmodifiable(_tickets);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  TicketServiceErrorCode? get errorCode => _errorCode;

  Future<void> refresh() async {
    final user = _auth.currentUser;
    if (user == null) return;
    _isLoading = true;
    _errorCode = null;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();
      _tickets = snapshot.docs.map(TicketModel.fromDocument).toList();
    } on Object catch (error) {
      try {
        final snapshot = await _firestore
            .collection('tickets')
            .where('userId', isEqualTo: user.uid)
            .get();
        _tickets = snapshot.docs.map(TicketModel.fromDocument).toList()
          ..sort((first, second) => second.createdAt.compareTo(first.createdAt));
        _errorCode = null;
      } on Object catch (_) {
        _tickets = const [];
        _errorCode = _errorCodeFor(error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitTicket({
    required TicketCategory category,
    required String subject,
    required String description,
    Uint8List? imageBytes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const TicketServiceException(TicketServiceErrorCode.authRequired);
    }
    final trimmedSubject = subject.trim();
    final trimmedDescription = description.trim();
    if (trimmedSubject.isEmpty) {
      throw const TicketServiceException(TicketServiceErrorCode.subjectRequired);
    }
    if (trimmedDescription.length < 15) {
      throw const TicketServiceException(TicketServiceErrorCode.descriptionTooShort);
    }

    _isSubmitting = true;
    _errorCode = null;
    notifyListeners();
    try {
      final deviceInfo = await _collectDeviceInfo();
      String? imageUrl;
      if (imageBytes != null && imageBytes.isNotEmpty) {
        final imageReference = _storage
            .ref()
            .child('tickets')
            .child(user.uid)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        await imageReference.putData(
          imageBytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        imageUrl = await imageReference.getDownloadURL();
      }
      final reference = _firestore.collection('tickets').doc();
      final ticketData = <String, dynamic>{
        'ticketId': reference.id,
        'userId': user.uid,
        'userEmail': user.email ?? '',
        'category': category.firestoreValue,
        'subject': trimmedSubject,
        'description': trimmedDescription,
        'status': TicketStatus.open.firestoreValue,
        'deviceInfo': deviceInfo,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (imageUrl != null) ticketData['imageUrl'] = imageUrl;
      await reference.set(ticketData);
      try {
        _tickets = await _loadTicketsWithFallback(user.uid);
      } on Object catch (error) {
        debugPrint('Ticket sent but list refresh failed: $error');
      }
    } on Object catch (error) {
      final exception = TicketServiceException(_errorCodeFor(error));
      _errorCode = exception.code;
      throw exception;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<Map<String, String>> _collectDeviceInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final devicePlugin = DeviceInfoPlugin();
    var os = 'Nieznany system';
    var model = 'Nieznane urządzenie';

    try {
      if (kIsWeb) {
        final info = await devicePlugin.webBrowserInfo;
        os = 'Web ${info.platform ?? ''}'.trim();
        model = info.browserName.name;
      } else {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            final info = await devicePlugin.androidInfo;
            os = 'Android ${info.version.release}';
            model = '${info.manufacturer} ${info.model}'.trim();
          case TargetPlatform.iOS:
            final info = await devicePlugin.iosInfo;
            os = 'iOS ${info.systemVersion}';
            model = info.utsname.machine;
          case TargetPlatform.windows:
            final info = await devicePlugin.windowsInfo;
            os = 'Windows ${info.majorVersion}.${info.minorVersion}';
            model = info.computerName;
          case TargetPlatform.macOS:
            final info = await devicePlugin.macOsInfo;
            os = 'macOS ${info.osRelease}';
            model = info.model;
          case TargetPlatform.linux:
            final info = await devicePlugin.linuxInfo;
            os = 'Linux ${info.version ?? ''}'.trim();
            model = info.prettyName;
          case TargetPlatform.fuchsia:
            os = 'Fuchsia';
        }
      }
    } on Object catch (error) {
      debugPrint('Could not collect support device info: $error');
    }

    return {
      'os': os,
      'model': model,
      'appVersion': 'v${packageInfo.version}+${packageInfo.buildNumber}',
    };
  }

  Future<void> _syncUser(User? user) async {
    await _ticketsSubscription?.cancel();
    _ticketsSubscription = null;
    _tickets = const [];
    _errorCode = null;
    notifyListeners();
    if (user == null) return;

    _isLoading = true;
    notifyListeners();
    _ticketsSubscription = _firestore
        .collection('tickets')
        .where('userId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _tickets = snapshot.docs.map(TicketModel.fromDocument).toList();
            _isLoading = false;
            notifyListeners();
          },
          onError: (Object error) {
            _isLoading = false;
            unawaited(_loadFallbackAfterStreamError(user.uid, error));
            notifyListeners();
          },
        );
  }

  Future<List<TicketModel>> _loadTicketsWithFallback(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(TicketModel.fromDocument).toList();
    } on Object catch (firstError) {
      try {
        final snapshot = await _firestore
            .collection('tickets')
            .where('userId', isEqualTo: userId)
            .get();
        final tickets = snapshot.docs.map(TicketModel.fromDocument).toList();
        tickets.sort((first, second) => second.createdAt.compareTo(first.createdAt));
        return tickets;
      } on Object catch (_) {
        throw firstError;
      }
    }
  }

  Future<void> _loadFallbackAfterStreamError(String userId, Object error) async {
    try {
      final snapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: userId)
          .get();
      _tickets = snapshot.docs.map(TicketModel.fromDocument).toList()
        ..sort((first, second) => second.createdAt.compareTo(first.createdAt));
      _errorCode = null;
    } on Object catch (_) {
      _tickets = const [];
      _errorCode = _errorCodeFor(error);
    }
    notifyListeners();
  }

  TicketServiceErrorCode _errorCodeFor(Object error) {
    if (error is TicketServiceException) return error.code;
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return TicketServiceErrorCode.permission;
        case 'unavailable':
        case 'network-request-failed':
          return TicketServiceErrorCode.offline;
        case 'failed-precondition':
          return TicketServiceErrorCode.missingIndex;
      }
    }
    return TicketServiceErrorCode.generic;
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    unawaited(_ticketsSubscription?.cancel());
    super.dispose();
  }
}
