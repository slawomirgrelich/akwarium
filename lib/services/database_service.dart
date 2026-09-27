import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/tank_firestore_models.dart';
import '../models/aquarium_reminder.dart';
import '../models/species_models.dart';
import '../models/tank_photo.dart';
import 'firestore_sync_status.dart';

class DatabaseService {
  DatabaseService({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _tanks(String userId) =>
      _firestore.collection('users').doc(userId).collection('tanks');

  CollectionReference<Map<String, dynamic>> _waterParameters(
    String userId,
    String tankId,
  ) =>
      _tanks(userId).doc(tankId).collection('water_parameters');

  CollectionReference<Map<String, dynamic>> _journalLogs(
    String userId,
    String tankId,
  ) =>
      _tanks(userId).doc(tankId).collection('journal_logs');

  CollectionReference<Map<String, dynamic>> _reminders(
    String userId,
    String tankId,
  ) =>
      _tanks(userId).doc(tankId).collection('reminders');

  CollectionReference<Map<String, dynamic>> _stocking(
    String userId,
    String tankId,
  ) =>
      _tanks(userId).doc(tankId).collection('stocking');

  CollectionReference<Map<String, dynamic>> _photos(
    String userId,
    String tankId,
  ) =>
      _tanks(userId).doc(tankId).collection('photos');

  Stream<List<Tank>> getTanksStream(String userId) => _tanks(userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(Tank.fromFirestore).toList());

  Future<void> addTank(String userId, Tank tank) async {
    final reference = tank.id.isEmpty ? _tanks(userId).doc() : _tanks(userId).doc(tank.id);
    await reference.set(tank.copyWithId(reference.id).toFirestore());
    await FirestoreSyncStatus.recordSuccessfulSync();
  }

  Future<void> updateTank(String userId, Tank tank) async {
    if (tank.id.isEmpty) throw ArgumentError('Tank id cannot be empty.');
    await _tanks(userId).doc(tank.id).set(tank.toFirestore(), SetOptions(merge: true));
    await FirestoreSyncStatus.recordSuccessfulSync();
  }

  Future<void> deleteTank(String userId, String tankId) async {
    await _tanks(userId).doc(tankId).delete();
    await FirestoreSyncStatus.recordSuccessfulSync();
  }

  Future<void> addWaterParameter(
    String userId,
    String tankId,
    WaterParameter param,
  ) async {
    final reference = param.id.isEmpty
        ? _waterParameters(userId, tankId).doc()
        : _waterParameters(userId, tankId).doc(param.id);
    await reference.set(param.copyWithId(reference.id).toFirestore());
    await FirestoreSyncStatus.recordSuccessfulSync();
  }

  Stream<List<WaterParameter>> getWaterParametersStream(
    String userId,
    String tankId,
  ) =>
      _waterParameters(userId, tankId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map(WaterParameter.fromFirestore).toList());

  Future<void> addJournalLog(
    String userId,
    String tankId,
    JournalLog log,
  ) async {
    final reference = log.id.isEmpty
        ? _journalLogs(userId, tankId).doc()
        : _journalLogs(userId, tankId).doc(log.id);
    await reference.set(log.copyWithId(reference.id).toFirestore());
    await FirestoreSyncStatus.recordSuccessfulSync();
  }

  Stream<List<JournalLog>> getJournalLogsStream(String userId, String tankId) =>
      _journalLogs(userId, tankId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map(JournalLog.fromFirestore).toList());

  Stream<List<AquariumReminder>> getRemindersStream(
    String userId,
    String tankId,
  ) =>
      _reminders(userId, tankId)
          .orderBy('dueDate')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map(AquariumReminder.fromFirestore).toList());

  Future<void> addReminder(
    String userId,
    String tankId,
    AquariumReminder reminder,
  ) async {
    final reference = reminder.id.isEmpty
        ? _reminders(userId, tankId).doc()
        : _reminders(userId, tankId).doc(reminder.id);
    await reference.set(
      reminder.copyWith(id: reference.id, tankId: tankId).toFirestore(),
    );
    await FirestoreSyncStatus.recordSuccessfulSync();
  }

  Future<void> updateReminder(
    String userId,
    String tankId,
    AquariumReminder reminder,
  ) async {
    if (reminder.id.isEmpty) throw ArgumentError('Reminder id cannot be empty.');
    await _reminders(userId, tankId).doc(reminder.id).set(
          reminder.copyWith(tankId: tankId).toFirestore(),
          SetOptions(merge: true),
        );
    await FirestoreSyncStatus.recordSuccessfulSync();
  }

  Future<void> deleteReminder(
    String userId,
    String tankId,
    String reminderId,
  ) async {
    await _reminders(userId, tankId).doc(reminderId).delete();
    await FirestoreSyncStatus.recordSuccessfulSync();
  }

  Future<void> completeReminder(
    String userId,
    String tankId,
    AquariumReminder reminder,
  ) async {
    final completedAt = DateTime.now();
    final nextDueDate = reminder.repeatIntervalDays == null
        ? reminder.dueDate
        : completedAt.add(Duration(days: reminder.repeatIntervalDays!));
    final updated = reminder.copyWith(
      tankId: tankId,
      dueDate: nextDueDate,
      isCompleted: reminder.repeatIntervalDays == null,
      lastCompletedAt: completedAt,
    );
    final batch = _firestore.batch();
    batch.set(_reminders(userId, tankId).doc(reminder.id), updated.toFirestore());
    final journalReference = _journalLogs(userId, tankId).doc();
    batch.set(journalReference, JournalLog(
      id: journalReference.id,
      timestamp: completedAt,
      activityType: reminder.taskType.name,
      title: reminder.title,
      note: 'Przypomnienie wykonane',
    ).toFirestore());
    await batch.commit();
    await FirestoreSyncStatus.recordSuccessfulSync();
  }

  Stream<List<TankStockItem>> getTankStockingStream(
    String userId,
    String tankId,
  ) =>
      _stocking(userId, tankId)
          .orderBy('addedDate')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map(TankStockItem.fromFirestore).toList());

  Future<void> addStockItem(
    String userId,
    String tankId,
    TankStockItem item,
  ) async {
    final reference = item.id.isEmpty
        ? _stocking(userId, tankId).doc()
        : _stocking(userId, tankId).doc(item.id);
    await reference.set(item.copyWith(id: reference.id, tankId: tankId).toFirestore());
    await FirestoreSyncStatus.recordSuccessfulSync();
  }

  Future<void> updateStockItem(
    String userId,
    String tankId,
    TankStockItem item,
  ) async {
    if (item.id.isEmpty) throw ArgumentError('Stock item id cannot be empty.');
    await _stocking(userId, tankId).doc(item.id).set(
          item.copyWith(tankId: tankId).toFirestore(),
          SetOptions(merge: true),
        );
    await FirestoreSyncStatus.recordSuccessfulSync();
  }

  Future<void> deleteStockItem(
    String userId,
    String tankId,
    String itemId,
  ) async {
    await _stocking(userId, tankId).doc(itemId).delete();
    await FirestoreSyncStatus.recordSuccessfulSync();
  }

  Future<TankPhoto> uploadTankPhoto(
    String userId,
    String tankId,
    Uint8List imageBytes,
    String caption,
  ) async {
    final document = _photos(userId, tankId).doc();
    final storagePath = 'users/$userId/tanks/$tankId/photos/${document.id}.jpg';
    final storageReference = _storage.ref(storagePath);
    await storageReference.putData(
      imageBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final photo = TankPhoto(
      id: document.id,
      tankId: tankId,
      photoUrl: await storageReference.getDownloadURL(),
      storagePath: storagePath,
      caption: caption,
      createdAt: DateTime.now(),
    );
    await document.set(photo.toFirestore());
    await FirestoreSyncStatus.recordSuccessfulSync();
    return photo;
  }

  Stream<List<TankPhoto>> getTankPhotosStream(String userId, String tankId) =>
      _photos(userId, tankId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map(TankPhoto.fromFirestore).toList());

  Future<void> deleteTankPhoto(
    String userId,
    String tankId,
    TankPhoto photo,
  ) async {
    await _photos(userId, tankId).doc(photo.id).delete();
    await FirestoreSyncStatus.recordSuccessfulSync();
    if (photo.storagePath.isNotEmpty) {
      await _storage.ref(photo.storagePath).delete();
    }
  }

  Future<void> setCoverPhoto(
    String userId,
    String tankId,
    TankPhoto photo,
  ) async {
    final snapshot = await _photos(userId, tankId).get();
    final batch = _firestore.batch();
    for (final document in snapshot.docs) {
      batch.update(document.reference, {'isCoverPhoto': document.id == photo.id});
    }
    batch.update(_tanks(userId).doc(tankId), {
      'imageUrl': photo.photoUrl,
      'coverPhotoUrl': photo.photoUrl,
      'coverImagePath': photo.storagePath,
    });
    await batch.commit();
    await FirestoreSyncStatus.recordSuccessfulSync();
  }
}

extension on Tank {
  Tank copyWithId(String id) => Tank(
        id: id,
        name: name,
        capacityLiters: capacityLiters,
        dimensions: dimensions,
        createdAt: createdAt,
        imageUrl: imageUrl,
        coverPhotoUrl: coverPhotoUrl,
        coverImagePath: coverImagePath,
      );
}

extension on WaterParameter {
  WaterParameter copyWithId(String id) => WaterParameter(
        id: id,
        timestamp: timestamp,
        pH: pH,
        kh: kh,
        gh: gh,
        no3: no3,
        po4: po4,
        fe: fe,
        k: k,
        mg: mg,
        temp: temp,
        note: note,
      );
}

extension on JournalLog {
  JournalLog copyWithId(String id) => JournalLog(
        id: id,
        timestamp: timestamp,
        activityType: activityType,
        title: title,
        waterReplacedLiters: waterReplacedLiters,
        note: note,
      );
}