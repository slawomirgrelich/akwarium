import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/aquarium_firestore_model.dart';
import 'firestore_sync_status.dart';

class FirestoreServiceException implements Exception {
  const FirestoreServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _aquariums(String userId) {
    _requirePathId(userId, 'userId');
    return _firestore.collection('users').doc(userId).collection('aquariums');
  }

  CollectionReference<Map<String, dynamic>> _waterParameters(
    String userId,
    String aquariumId,
  ) {
    _requirePathId(aquariumId, 'aquariumId');
    return _aquariums(userId).doc(aquariumId).collection('water_parameters');
  }

  CollectionReference<Map<String, dynamic>> _waterTests(String userId) =>
      _firestore.collection('users').doc(userId).collection('water_tests');

  CollectionReference<Map<String, dynamic>> _livestock(
    String userId,
    String aquariumId,
  ) {
    _requirePathId(aquariumId, 'aquariumId');
    return _aquariums(userId).doc(aquariumId).collection('livestock');
  }

  String _requireUserId() {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      throw const FirestoreServiceException(
        'Zaloguj się, aby korzystać z zapisanych danych.',
      );
    }
    return userId;
  }

  Stream<List<AquariumModel>> getAquariums() {
    try {
      final userId = _requireUserId();
      return _aquariums(userId)
          .snapshots()
          .map((snapshot) {
            final aquariums = snapshot.docs
                .map(AquariumModel.fromFirestore)
                .toList();
            aquariums.sort(
              (first, second) => second.createdAt.compareTo(first.createdAt),
            );
            return aquariums;
          })
          .handleError((Object error) {
            throw FirestoreServiceException(_messageFor(error));
          });
    } catch (error) {
      return Stream<List<AquariumModel>>.error(
        error is FirestoreServiceException
            ? error
            : FirestoreServiceException(_messageFor(error)),
      );
    }
  }

  Future<void> addAquarium(AquariumModel aquarium) async {
    final userId = _requireUserId();
    _ensureUserOwnership(aquarium.userId, userId);

    try {
      final reference = aquarium.id.isEmpty
          ? _aquariums(userId).doc()
          : _aquariums(userId).doc(aquarium.id);
      await reference.set(
        aquarium.copyWith(id: reference.id, userId: userId).toMap(),
      );
      await FirestoreSyncStatus.recordSuccessfulSync();
    } on FirebaseException catch (error) {
      throw FirestoreServiceException(
        'FirebaseException (${error.code}): ${error.message ?? error.toString()}',
      );
    } catch (error) {
      throw FirestoreServiceException(_messageFor(error));
    }
  }

  Future<void> updateAquarium(AquariumModel aquarium) async {
    final userId = _requireUserId();
    _ensureUserOwnership(aquarium.userId, userId);
    if (aquarium.id.isEmpty) {
      throw const FirestoreServiceException(
        'Nie można zaktualizować akwarium bez identyfikatora.',
      );
    }

    try {
      await _aquariums(userId)
          .doc(aquarium.id)
          .set(
            aquarium.copyWith(userId: userId).toMap(),
            SetOptions(merge: true),
          );
      await FirestoreSyncStatus.recordSuccessfulSync();
    } catch (error) {
      throw FirestoreServiceException(_messageFor(error));
    }
  }

  Future<void> deleteAquarium(String aquariumId) async {
    final userId = _requireUserId();
    if (aquariumId.trim().isEmpty) {
      throw const FirestoreServiceException(
        'Nieprawidłowy identyfikator akwarium.',
      );
    }

    try {
      final parameters = await _waterParameters(userId, aquariumId).get();
      final writes = <Future<void>>[];
      for (var index = 0; index < parameters.docs.length; index += 450) {
        final batch = _firestore.batch();
        final end = (index + 450).clamp(0, parameters.docs.length);
        for (final document in parameters.docs.sublist(index, end)) {
          batch.delete(document.reference);
        }
        batch.delete(_aquariums(userId).doc(aquariumId));
        writes.add(batch.commit());
      }
      if (parameters.docs.isEmpty) {
        await _aquariums(userId).doc(aquariumId).delete();
      } else {
        await Future.wait(writes);
      }
      await FirestoreSyncStatus.recordSuccessfulSync();
    } catch (error) {
      throw FirestoreServiceException(_messageFor(error));
    }
  }

  Stream<List<WaterParametersModel>> getWaterParameters(String aquariumId) {
    try {
      _requirePathId(aquariumId, 'aquariumId');
      final userId = _requireUserId();
      return _waterParameters(userId, aquariumId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(
                  (document) => WaterParametersModel.fromFirestore(
                    document,
                    aquariumIdFallback: aquariumId,
                  ),
                )
                .toList(growable: false),
          )
          .handleError((Object error) {
            throw FirestoreServiceException(_messageFor(error));
          });
    } catch (error) {
      return Stream<List<WaterParametersModel>>.error(
        error is FirestoreServiceException
            ? error
            : FirestoreServiceException(_messageFor(error)),
      );
    }
  }

  Future<void> addWaterParameters(WaterParametersModel params) async {
    final userId = _requireUserId();
    if (params.aquariumId.trim().isEmpty) {
      throw const FirestoreServiceException(
        'Pomiar nie ma przypisanego akwarium.',
      );
    }

    try {
      final reference = params.id.isEmpty
          ? _waterParameters(userId, params.aquariumId).doc()
          : _waterParameters(userId, params.aquariumId).doc(params.id);
      final saved = params.copyWith(id: reference.id);
      final batch = _firestore.batch();
      batch.set(reference, saved.toMap());
      batch.set(_waterTests(userId).doc(saved.id), {
        ...saved.toMap(),
        'date': Timestamp.fromDate(saved.timestamp),
      }, SetOptions(merge: true));
      await batch.commit();
      await FirestoreSyncStatus.recordSuccessfulSync();
    } catch (error) {
      throw FirestoreServiceException(_messageFor(error));
    }
  }

  Future<void> deleteWaterParameter(String aquariumId, String paramId) async {
    final userId = _requireUserId();
    if (aquariumId.trim().isEmpty || paramId.trim().isEmpty) {
      throw const FirestoreServiceException(
        'Nieprawidłowy identyfikator pomiaru.',
      );
    }

    try {
      final legacyTest = await _waterTests(userId).doc(paramId).get();
      final batch = _firestore.batch();
      batch.delete(_waterParameters(userId, aquariumId).doc(paramId));
      if (legacyTest.data()?['aquariumId'] == aquariumId) {
        batch.delete(legacyTest.reference);
      }
      await batch.commit();
      await FirestoreSyncStatus.recordSuccessfulSync();
    } catch (error) {
      throw FirestoreServiceException(_messageFor(error));
    }
  }

  Future<void> addLivestockItem(
    String aquariumId, {
    required String namePl,
    required String nameLatin,
    required String category,
    required int count,
    required String phRange,
    required String tempRange,
    required int minTankVolume,
    DateTime? addedAt,
    String notes = '',
    String? photoUrl,
    String quantityUnit = 'pieces',
  }) async {
    final userId = _requireUserId();
    if (aquariumId.trim().isEmpty) {
      throw const FirestoreServiceException(
        'Nie wybrano akwarium do dodania obsady.',
      );
    }

    try {
      final normalizedCategory = category.toLowerCase();
      final isFlora =
          normalizedCategory.contains('plant') ||
          normalizedCategory.contains('flora') ||
          normalizedCategory.contains('roślin') ||
          normalizedCategory.contains('roslin');
      await _livestock(userId, aquariumId).add({
        'namePl': namePl,
        'nameLatin': nameLatin,
        'category': isFlora ? 'flora' : 'fauna',
        'categoryLabel': category,
        'count': count,
        'quantityUnit': quantityUnit,
        'phRange': phRange,
        'tempRange': tempRange,
        'minTankVolume': minTankVolume,
        'addedAt': addedAt == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(addedAt),
        'notes': notes,
        'photoUrl': ?photoUrl,
      });
      await FirestoreSyncStatus.recordSuccessfulSync();
    } on FirebaseException catch (error) {
      throw FirestoreServiceException(
        'FirebaseException (${error.code}): ${error.message ?? error.toString()}',
      );
    } catch (error) {
      throw FirestoreServiceException(error.toString());
    }
  }

  Stream<List<Map<String, dynamic>>> getLivestock(String aquariumId) {
    try {
      _requirePathId(aquariumId, 'aquariumId');
      final userId = _requireUserId();
      return _livestock(userId, aquariumId)
          .orderBy('addedAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((document) => {'id': document.id, ...document.data()})
                .toList(growable: false),
          )
          .handleError((Object error) {
            throw FirestoreServiceException(_messageFor(error));
          });
    } catch (error) {
      return Stream<List<Map<String, dynamic>>>.error(
        error is FirestoreServiceException
            ? error
            : FirestoreServiceException(_messageFor(error)),
      );
    }
  }

  Future<void> deleteLivestockItem(String aquariumId, String itemId) async {
    final userId = _requireUserId();
    if (aquariumId.trim().isEmpty || itemId.trim().isEmpty) {
      throw const FirestoreServiceException('Nieprawidłowe dane obsady.');
    }
    try {
      await _livestock(userId, aquariumId).doc(itemId).delete();
      await FirestoreSyncStatus.recordSuccessfulSync();
    } on FirebaseException catch (error) {
      throw FirestoreServiceException(
        'FirebaseException (${error.code}): ${error.message ?? error.toString()}',
      );
    } catch (error) {
      throw FirestoreServiceException(error.toString());
    }
  }

  Future<void> updateLivestockCount(
    String aquariumId,
    String itemId,
    int count,
  ) async {
    final userId = _requireUserId();
    if (aquariumId.trim().isEmpty || itemId.trim().isEmpty || count < 1) {
      throw const FirestoreServiceException('Nieprawidłowa liczba sztuk.');
    }
    try {
      await _livestock(userId, aquariumId).doc(itemId).update({'count': count});
      await FirestoreSyncStatus.recordSuccessfulSync();
    } on FirebaseException catch (error) {
      throw FirestoreServiceException(
        'FirebaseException (${error.code}): ${error.message ?? error.toString()}',
      );
    } catch (error) {
      throw FirestoreServiceException(error.toString());
    }
  }

  void _ensureUserOwnership(String modelUserId, String currentUserId) {
    if (modelUserId.isNotEmpty && modelUserId != currentUserId) {
      throw const FirestoreServiceException(
        'Nie można zapisać danych należących do innego użytkownika.',
      );
    }
  }

  void _requirePathId(String value, String name) {
    if (value.trim().isEmpty) {
      throw FirestoreServiceException(
        'Nie można wykonać operacji bez poprawnego identyfikatora $name.',
      );
    }
  }

  String _messageFor(Object error) {
    if (error is FirestoreServiceException) return error.message;
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Brak uprawnień do tych danych.';
        case 'not-found':
          return 'Nie znaleziono wskazanego dokumentu.';
        case 'unavailable':
          return 'Baza danych jest chwilowo niedostępna.';
        case 'failed-precondition':
          return 'Operacja wymaga dodatkowej konfiguracji Firebase.';
        case 'network-request-failed':
          return 'Brak połączenia z internetem.';
        default:
          return 'Nie udało się wykonać operacji na bazie danych.';
      }
    }
    return 'Wystąpił nieoczekiwany błąd bazy danych.';
  }
}
