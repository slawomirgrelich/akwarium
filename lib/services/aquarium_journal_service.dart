import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum JournalEntryType { waterChange, filter, trimming, medication, cleaning }

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

  Future<void> markReminderCompleted(ReminderModel reminder) async {
    final nextDate = reminder.isRecurring
        ? reminder.nextDueDate.add(Duration(days: reminder.intervalDays))
        : reminder.nextDueDate;
    await updateReminder(
      reminder.copyWith(
        nextDueDate: nextDate,
        isCompleted: reminder.isRecurring ? false : !reminder.isCompleted,
      ),
    );
  }

  Future<void> deleteReminder(ReminderModel reminder) async {
    try {
      await _collection(
        _userId(),
        reminder.aquariumId,
        'reminders',
      ).doc(reminder.id).delete();
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
    } catch (error) {
      throw AquariumJournalServiceException(_message(error));
    }
  }

  Stream<List<T>> _stream<T>(Stream<List<T>> stream) {
    return stream.handleError((Object error) {
      throw AquariumJournalServiceException(_message(error));
    });
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
