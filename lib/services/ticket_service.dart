import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/ticket_models.dart';

class TicketServiceException implements Exception {
  const TicketServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TicketService extends ChangeNotifier {
  TicketService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _authSubscription = _auth.authStateChanges().listen(_syncUser);
    unawaited(_syncUser(_auth.currentUser));
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _ticketsSubscription;

  List<TicketModel> _tickets = const [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<TicketModel> get tickets => List.unmodifiable(_tickets);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<void> refresh() async {
    final user = _auth.currentUser;
    if (user == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: user.uid)
          .orderBy('updatedAt', descending: true)
          .get();
      _tickets = snapshot.docs.map(TicketModel.fromDocument).toList();
    } on Object catch (error) {
      _errorMessage = _messageFor(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitTicket({
    required TicketCategory category,
    required String subject,
    required String description,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const TicketServiceException(
        'Zaloguj się, aby wysłać zgłoszenie.',
      );
    }
    final trimmedSubject = subject.trim();
    final trimmedDescription = description.trim();
    if (trimmedSubject.isEmpty) {
      throw const TicketServiceException('Wpisz tytuł zgłoszenia.');
    }
    if (trimmedDescription.length < 15) {
      throw const TicketServiceException(
        'Opis zgłoszenia musi mieć co najmniej 15 znaków.',
      );
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final deviceInfo = await _collectDeviceInfo();
      final reference = _firestore.collection('tickets').doc();
      await reference.set({
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
      });
    } on Object catch (error) {
      final exception = TicketServiceException(_messageFor(error));
      _errorMessage = exception.message;
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
    _errorMessage = null;
    notifyListeners();
    if (user == null) return;

    _isLoading = true;
    notifyListeners();
    _ticketsSubscription = _firestore
        .collection('tickets')
        .where('userId', isEqualTo: user.uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _tickets = snapshot.docs.map(TicketModel.fromDocument).toList();
            _isLoading = false;
            notifyListeners();
          },
          onError: (Object error) {
            _isLoading = false;
            _errorMessage = _messageFor(error);
            notifyListeners();
          },
        );
  }

  String _messageFor(Object error) {
    if (error is TicketServiceException) return error.message;
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Brak uprawnień do zgłoszeń. Zaloguj się ponownie.';
        case 'unavailable':
        case 'network-request-failed':
          return 'Brak połączenia z internetem. Sprawdź sieć i spróbuj ponownie.';
        case 'failed-precondition':
          return 'Nie można pobrać zgłoszeń. Baza danych wymaga indeksu Firestore.';
        default:
          return 'Nie udało się połączyć z centrum pomocy.';
      }
    }
    return 'Nie udało się wykonać operacji. Spróbuj ponownie.';
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    unawaited(_ticketsSubscription?.cancel());
    super.dispose();
  }
}
