import 'package:cloud_firestore/cloud_firestore.dart';

enum ReminderTaskType { waterChange, filterClean, waterTest, fertilizer, custom }

class AquariumReminder {
  const AquariumReminder({
    required this.id,
    required this.tankId,
    required this.title,
    required this.taskType,
    required this.dueDate,
    this.repeatIntervalDays,
    this.isCompleted = false,
    this.lastCompletedAt,
    this.isEnabled = true,
  });

  final String id;
  final String tankId;
  final String title;
  final ReminderTaskType taskType;
  final DateTime dueDate;
  final int? repeatIntervalDays;
  final bool isCompleted;
  final DateTime? lastCompletedAt;
  final bool isEnabled;

  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());

  AquariumReminder copyWith({
    String? id,
    String? tankId,
    String? title,
    ReminderTaskType? taskType,
    DateTime? dueDate,
    int? repeatIntervalDays,
    bool? isCompleted,
    DateTime? lastCompletedAt,
    bool? isEnabled,
  }) {
    return AquariumReminder(
      id: id ?? this.id,
      tankId: tankId ?? this.tankId,
      title: title ?? this.title,
      taskType: taskType ?? this.taskType,
      dueDate: dueDate ?? this.dueDate,
      repeatIntervalDays: repeatIntervalDays ?? this.repeatIntervalDays,
      isCompleted: isCompleted ?? this.isCompleted,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'tankId': tankId,
        'title': title,
        'taskType': taskType.name,
        'dueDate': Timestamp.fromDate(dueDate),
        'repeatIntervalDays': repeatIntervalDays,
        'isCompleted': isCompleted,
        'lastCompletedAt': lastCompletedAt == null
            ? null
            : Timestamp.fromDate(lastCompletedAt!),
        'isEnabled': isEnabled,
      };

  factory AquariumReminder.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return AquariumReminder(
      id: _string(data['id'], snapshot.id),
      tankId: _string(data['tankId']),
      title: _string(data['title'], 'Przypomnienie'),
      taskType: ReminderTaskType.values.firstWhere(
        (type) => type.name == data['taskType'],
        orElse: () => ReminderTaskType.custom,
      ),
      dueDate: _date(data['dueDate']) ?? DateTime.now(),
      repeatIntervalDays: (data['repeatIntervalDays'] as num?)?.toInt(),
      isCompleted: data['isCompleted'] as bool? ?? false,
      lastCompletedAt: _date(data['lastCompletedAt']),
      isEnabled: data['isEnabled'] as bool? ?? true,
    );
  }
}

String _string(Object? value, [String fallback = '']) =>
    value is String && value.trim().isNotEmpty ? value : fallback;

DateTime? _date(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}