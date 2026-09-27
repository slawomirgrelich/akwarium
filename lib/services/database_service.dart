import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/tank_firestore_models.dart';

class DatabaseService {
  DatabaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

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

  Stream<List<Tank>> getTanksStream(String userId) => _tanks(userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(Tank.fromFirestore).toList());

  Future<void> addTank(String userId, Tank tank) async {
    final reference = tank.id.isEmpty ? _tanks(userId).doc() : _tanks(userId).doc(tank.id);
    await reference.set(tank.copyWithId(reference.id).toFirestore());
  }

  Future<void> updateTank(String userId, Tank tank) async {
    if (tank.id.isEmpty) throw ArgumentError('Tank id cannot be empty.');
    await _tanks(userId).doc(tank.id).set(tank.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteTank(String userId, String tankId) async {
    await _tanks(userId).doc(tankId).delete();
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
  }

  Stream<List<JournalLog>> getJournalLogsStream(String userId, String tankId) =>
      _journalLogs(userId, tankId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map(JournalLog.fromFirestore).toList());
}

extension on Tank {
  Tank copyWithId(String id) => Tank(
        id: id,
        name: name,
        capacityLiters: capacityLiters,
        dimensions: dimensions,
        createdAt: createdAt,
        imageUrl: imageUrl,
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