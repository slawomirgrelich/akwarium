import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/recurrence_date.dart';
import 'firestore_sync_status.dart';

enum JournalEntryType {
  waterChange,
  filter,
  trimming,
  medication,
  cleaning,
  waterTest,
}

extension JournalEntryTypeLabel on JournalEntryType {
  String get label {
    switch (this) {
      case JournalEntryType.waterChange:
        return 'Podmiana wody';
      case JournalEntryType.filter:
        return 'Filtr';
      case JournalEntryType.trimming:
        return 'Przycinanie';
      case JournalEntryType.medication:
        return 'Leki';
      case JournalEntryType.cleaning:
        return 'Czyszczenie';
      case JournalEntryType.waterTest:
        return 'Test wody';
    }
  }
}

class JournalEntryModel {
  const JournalEntryModel({
    required this.id,
    required this.aquariumId,
    required this.timestamp,
    required this.entryType,
    required this.title,
    required this.notes,
    this.percentageWaterChanged,
  });

  final String id;
  final String aquariumId;
  final DateTime timestamp;
  final JournalEntryType entryType;
  final String title;
  final String notes;
  final double? percentageWaterChanged;

  Map<String, dynamic> toMap() => {
    'id': id,
    'aquariumId': aquariumId,
    'timestamp': Timestamp.fromDate(timestamp),
    'entryType': entryType.name,
    'title': title,
    'notes': notes,
    'percentageWaterChanged': percentageWaterChanged,
  };

  factory JournalEntryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return JournalEntryModel(
      id: _string(data['id'], snapshot.id),
      aquariumId: _string(data['aquariumId']),
      timestamp: _date(data['timestamp']) ?? DateTime.now(),
      entryType: _entryType(data['entryType']),
      title: _string(data['title'], 'Wpis dziennika'),
      notes: _string(data['notes']),
      percentageWaterChanged: _doubleOrNull(data['percentageWaterChanged']),
    );
  }
}

class ReminderModel {
  const ReminderModel({
    required this.id,
    required this.aquariumId,
    required this.title,
    required this.intervalDays,
    required this.nextDueDate,
    required this.isRecurring,
    required this.isCompleted,
    required this.isProFeature,
  });

  final String id;
  final String aquariumId;
  final String title;
  final int intervalDays;
  final DateTime nextDueDate;
  final bool isRecurring;
  final bool isCompleted;
  final bool isProFeature;

  ReminderModel copyWith({
    String? id,
    String? aquariumId,
    String? title,
    int? intervalDays,
    DateTime? nextDueDate,
    bool? isRecurring,
    bool? isCompleted,
    bool? isProFeature,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      aquariumId: aquariumId ?? this.aquariumId,
      title: title ?? this.title,
      intervalDays: intervalDays ?? this.intervalDays,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isRecurring: isRecurring ?? this.isRecurring,
      isCompleted: isCompleted ?? this.isCompleted,
      isProFeature: isProFeature ?? this.isProFeature,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'aquariumId': aquariumId,
    'title': title,
    'intervalDays': intervalDays,
    'nextDueDate': Timestamp.fromDate(nextDueDate),
    'isRecurring': isRecurring,
    'isCompleted': isCompleted,
    'isProFeature': isProFeature,
  };

  factory ReminderModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return ReminderModel(
      id: _string(data['id'], snapshot.id),
      aquariumId: _string(data['aquariumId']),
      title: _string(data['title'], 'Przypomnienie'),
      intervalDays: (data['intervalDays'] as num?)?.toInt() ?? 1,
      nextDueDate: _date(data['nextDueDate']) ?? DateTime.now(),
      isRecurring: data['isRecurring'] as bool? ?? false,
      isCompleted: data['isCompleted'] as bool? ?? false,
      isProFeature: data['isProFeature'] as bool? ?? false,
    );
  }
}

class MaintenanceTaskModel {
  const MaintenanceTaskModel({
    required this.id,
    required this.aquariumId,
    required this.taskType,
    required this.title,
    required this.repeatFrequencyDays,
    required this.lastPerformedDate,
    required this.nextDueDate,
  });

  final String id;
  final String aquariumId;
  final String taskType;
  final String title;
  final int repeatFrequencyDays;
  final DateTime lastPerformedDate;
  final DateTime nextDueDate;

  Map<String, dynamic> toMap() => {
    'id': id,
    'aquariumId': aquariumId,
    'taskType': taskType,
    'title': title,
    'repeatFrequencyDays': repeatFrequencyDays,
    'lastPerformedDate': Timestamp.fromDate(lastPerformedDate),
    'nextDueDate': Timestamp.fromDate(nextDueDate),
  };

  factory MaintenanceTaskModel.fromMap(
    Map<String, dynamic> data, {
    String idFallback = '',
  }) {
    final lastPerformed = _date(data['lastPerformedDate']) ?? DateTime.now();
    return MaintenanceTaskModel(
      id: _string(data['id'], idFallback),
      aquariumId: _string(data['aquariumId']),
      taskType: _string(data['taskType'], 'custom'),
      title: _string(data['title'], 'Zadanie konserwacyjne'),
      repeatFrequencyDays: (data['repeatFrequencyDays'] as num?)?.toInt() ?? 7,
      lastPerformedDate: lastPerformed,
      nextDueDate: _date(data['nextDueDate']) ?? lastPerformed,
    );
  }

  factory MaintenanceTaskModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return MaintenanceTaskModel.fromMap(
      snapshot.data() ?? const <String, dynamic>{},
      idFallback: snapshot.id,
    );
  }

  MaintenanceTaskModel completed(DateTime performedAt) {
    if (repeatFrequencyDays < 1) {
      throw ArgumentError.value(
        repeatFrequencyDays,
        'repeatFrequencyDays',
        'Must be positive.',
      );
    }
    return MaintenanceTaskModel(
      id: id,
      aquariumId: aquariumId,
      taskType: taskType,
      title: title,
      repeatFrequencyDays: repeatFrequencyDays,
      lastPerformedDate: performedAt,
      nextDueDate: nextRecurrenceDateAfter(
        performedAt,
        nextDueDate,
        repeatFrequencyDays,
      ),
    );
  }
}

class AquariumJournalServiceException implements Exception {
  const AquariumJournalServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AquariumJournalService {
  AquariumJournalService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _collection(
    String userId,
    String aquariumId,
    String collection,
  ) {
    _requirePathId(userId, 'userId');
    _requirePathId(aquariumId, 'aquariumId');
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('aquariums')
        .doc(aquariumId)
        .collection(collection);
  }

  String _userId() {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      throw const AquariumJournalServiceException(
        'Zaloguj się, aby korzystać z dziennika i przypomnień.',
      );
    }
    return userId;
  }

  Stream<List<JournalEntryModel>> getJournalEntries(String aquariumId) {
    return _stream(
      _collection(_userId(), aquariumId, 'journal')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map(JournalEntryModel.fromFirestore).toList(),
          ),
    );
  }

  Stream<List<ReminderModel>> getReminders(String aquariumId) {
    return _stream(
      _collection(_userId(), aquariumId, 'reminders')
          .orderBy('nextDueDate')
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map(ReminderModel.fromFirestore).toList(),
          ),
    );
  }

  Stream<List<MaintenanceTaskModel>> getMaintenanceTasks(String aquariumId) {
    return _stream(
      _collection(_userId(), aquariumId, 'maintenance_tasks')
          .orderBy('nextDueDate')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(MaintenanceTaskModel.fromFirestore)
                .toList(growable: false),
          ),
    );
  }

  Future<void> addMaintenanceTask(MaintenanceTaskModel task) async {
    await _write(
      _collection(_userId(), task.aquariumId, 'maintenance_tasks'),
      task.id,
      task.toMap(),
    );
  }

  Future<MaintenanceTaskModel> saveMaintenanceTask(
    MaintenanceTaskModel task,
  ) async {
    try {
      final collection = _collection(
        _userId(),
        task.aquariumId,
        'maintenance_tasks',
      );
      final reference = task.id.isEmpty
          ? collection.doc()
          : collection.doc(task.id);
      final saved = MaintenanceTaskModel(
        id: reference.id,
        aquariumId: task.aquariumId,
        taskType: task.taskType,
        title: task.title,
        repeatFrequencyDays: task.repeatFrequencyDays,
        lastPerformedDate: task.lastPerformedDate,
        nextDueDate: task.nextDueDate,
      );
      await reference.set(saved.toMap());
      await FirestoreSyncStatus.recordSuccessfulSync();
      return saved;
    } catch (error) {
      throw AquariumJournalServiceException(_message(error));
    }
  }

  Future<MaintenanceTaskModel> completeMaintenanceTask(
    MaintenanceTaskModel task, {
    DateTime? completedAt,
  }) async {
    final performedAt = completedAt ?? DateTime.now();
    final updated = task.completed(performedAt);
    await _write(
      _collection(_userId(), task.aquariumId, 'maintenance_tasks'),
      task.id,
      updated.toMap(),
    );
    return updated;
  }

  Future<void> deleteMaintenanceTask(MaintenanceTaskModel task) async {
    try {
      _requirePathId(task.id, 'maintenanceTaskId');
      await _collection(
        _userId(),
        task.aquariumId,
        'maintenance_tasks',
      ).doc(task.id).delete();
      await FirestoreSyncStatus.recordSuccessfulSync();
    } catch (error) {
      throw AquariumJournalServiceException(_message(error));
    }
  }

  Future<void> addJournalEntry(JournalEntryModel entry) async {
    await _write(
      _collection(_userId(), entry.aquariumId, 'journal'),
      entry.id,
      entry.toMap(),
    );
  }

  Future<void> addReminder(ReminderModel reminder) async {
    await _write(
      _collection(_userId(), reminder.aquariumId, 'reminders'),
      reminder.id,
      reminder.toMap(),
    );
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _write(
      _collection(_userId(), reminder.aquariumId, 'reminders'),
      reminder.id,
      reminder.toMap(),
    );
  }

  Future<ReminderModel> markReminderCompleted(
    ReminderModel reminder, {
    DateTime? completedAt,
  }) async {
    final performedAt = completedAt ?? DateTime.now();
    final nextDate = reminder.isRecurring
        ? nextRecurrenceDateAfter(
            performedAt,
            reminder.nextDueDate,
            reminder.intervalDays,
          )
        : reminder.nextDueDate;
    final updated = reminder.copyWith(
      nextDueDate: nextDate,
      isCompleted: reminder.isRecurring ? false : !reminder.isCompleted,
    );
    await updateReminder(updated);
    return updated;
  }

  Future<void> deleteReminder(ReminderModel reminder) async {
    try {
      _requirePathId(reminder.id, 'reminderId');
      await _collection(
        _userId(),
        reminder.aquariumId,
        'reminders',
      ).doc(reminder.id).delete();
      await FirestoreSyncStatus.recordSuccessfulSync();
    } catch (error) {
      throw AquariumJournalServiceException(_message(error));
    }
  }

  Future<void> _write(
    CollectionReference<Map<String, dynamic>> collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final reference = id.isEmpty ? collection.doc() : collection.doc(id);
      await reference.set({...data, 'id': reference.id});
      await FirestoreSyncStatus.recordSuccessfulSync();
    } catch (error) {
      throw AquariumJournalServiceException(_message(error));
    }
  }

  Stream<List<T>> _stream<T>(Stream<List<T>> stream) {
    return stream.handleError((Object error) {
      throw AquariumJournalServiceException(_message(error));
    });
  }

  void _requirePathId(String value, String name) {
    if (value.trim().isEmpty) {
      throw AquariumJournalServiceException(
        'Nie można wykonać operacji bez poprawnego identyfikatora $name.',
      );
    }
  }

  String _message(Object error) {
    if (error is AquariumJournalServiceException) return error.message;
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Brak uprawnień do danych dziennika.';
        case 'unavailable':
          return 'Baza danych jest chwilowo niedostępna.';
        case 'failed-precondition':
          return 'Operacja wymaga dodatkowej konfiguracji Firebase.';
      }
    }
    return 'Nie udało się zapisać danych dziennika.';
  }
}

String _string(Object? value, [String fallback = '']) {
  return value is String && value.trim().isNotEmpty ? value : fallback;
}

double? _doubleOrNull(Object? value) =>
    value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');

DateTime? _date(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

JournalEntryType _entryType(Object? value) {
  return JournalEntryType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => JournalEntryType.cleaning,
  );
}
