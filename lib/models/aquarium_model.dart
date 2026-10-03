import 'dart:convert';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/recurrence_date.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'aquarium_firestore_model.dart' as firestore_models;
import '../local_reminder_service.dart';
import '../services/firestore_sync_status.dart';

export 'aquarium_firestore_model.dart';

/// Typ prowadzonego akwarium.
enum AquariumType { planted, marine, community }

enum TankType { freshwater, marine, planted, biotope, shrimp }

enum CreatureCategory { fish, shrimp, snail, crab, plant, other }

enum PlantPosition { foreground, midground, background, epiphyte, floating }

extension TankTypeLabel on TankType {
  String get label {
    switch (this) {
      case TankType.freshwater:
        return 'Słodkowodne';
      case TankType.marine:
        return 'Morskie';
      case TankType.planted:
        return 'Roślinne / holenderskie';
      case TankType.biotope:
        return 'Biotopowe';
      case TankType.shrimp:
        return 'Krewetkarium';
    }
  }
}

TankType _tankTypeFromLabel(String label) {
  final normalized = label.toLowerCase();
  if (normalized.contains('morsk') ||
      normalized.contains('marine') ||
      normalized.contains('salt')) {
    return TankType.marine;
  }
  if (normalized.contains('krewet') || normalized.contains('shrimp')) {
    return TankType.shrimp;
  }
  if (normalized.contains('roślin') ||
      normalized.contains('roslin') ||
      normalized.contains('plant')) {
    return TankType.planted;
  }
  if (normalized.contains('biotop') || normalized.contains('biotope')) {
    return TankType.biotope;
  }
  return TankType.freshwater;
}

extension CreatureCategoryLabel on CreatureCategory {
  String get label {
    switch (this) {
      case CreatureCategory.fish:
        return 'Ryby';
      case CreatureCategory.shrimp:
        return 'Krewetki';
      case CreatureCategory.snail:
        return 'Ślimaki';
      case CreatureCategory.crab:
        return 'Kraby';
      case CreatureCategory.plant:
        return 'Rośliny';
      case CreatureCategory.other:
        return 'Inne';
    }
  }
}

extension PlantPositionLabel on PlantPosition {
  String get label {
    switch (this) {
      case PlantPosition.foreground:
        return 'I plan';
      case PlantPosition.midground:
        return 'II plan';
      case PlantPosition.background:
        return 'III plan';
      case PlantPosition.epiphyte:
        return 'Epifit';
      case PlantPosition.floating:
        return 'Pływająca';
    }
  }
}

class AquariumProfile {
  const AquariumProfile({
    required this.id,
    required this.name,
    required this.volumeNetLiters,
    required this.setupDate,
    required this.type,
    this.volumeGrossLiters,
    this.substrate,
    this.lighting,
    this.filtration,
    this.imagePath,
    this.isActive = false,
  });

  final String id;
  final String name;
  final double volumeNetLiters;
  final DateTime setupDate;
  final TankType type;
  final double? volumeGrossLiters;
  final String? substrate;
  final String? lighting;
  final String? filtration;
  final String? imagePath;
  final bool isActive;

  int get ageInDays {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final setupDay = DateTime.utc(
      setupDate.year,
      setupDate.month,
      setupDate.day,
    );
    final elapsedDays = today.difference(setupDay).inDays;
    return elapsedDays < 0 ? 0 : elapsedDays;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'volumeNetLiters': volumeNetLiters,
    'volumeGrossLiters': volumeGrossLiters,
    'setupDate': setupDate.toIso8601String(),
    'type': type.name,
    'substrate': substrate,
    'lighting': lighting,
    'filtration': filtration,
    'imagePath': imagePath,
    'isActive': isActive,
  };

  factory AquariumProfile.fromJson(Map<String, dynamic> json) =>
      AquariumProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        volumeNetLiters: (json['volumeNetLiters'] as num).toDouble(),
        volumeGrossLiters: (json['volumeGrossLiters'] as num?)?.toDouble(),
        setupDate:
            DateTime.tryParse(json['setupDate'] as String? ?? '') ??
            DateTime.now(),
        type: TankType.values.byName(json['type'] as String? ?? 'freshwater'),
        substrate: json['substrate'] as String?,
        lighting: json['lighting'] as String?,
        filtration: json['filtration'] as String?,
        imagePath: json['imagePath'] as String?,
        isActive: json['isActive'] as bool? ?? false,
      );
}

class Inhabitant {
  const Inhabitant({
    required this.id,
    required this.aquariumId,
    required this.name,
    required this.latinName,
    required this.category,
    required this.count,
    required this.addedDate,
    this.plantPosition,
    this.status = 'Zdrowe',
    this.difficulty,
    this.notes,
    this.imagePath,
  });

  final String id;
  final String aquariumId;
  final String name;
  final String latinName;
  final CreatureCategory category;
  final int count;
  final DateTime addedDate;
  final PlantPosition? plantPosition;
  final String status;
  final String? difficulty;
  final String? notes;
  final String? imagePath;

  Map<String, dynamic> toJson() => {
    'id': id,
    'aquariumId': aquariumId,
    'name': name,
    'latinName': latinName,
    'category': category.name,
    'count': count,
    'addedDate': addedDate.toIso8601String(),
    'plantPosition': plantPosition?.name,
    'status': status,
    'difficulty': difficulty,
    'notes': notes,
    'imagePath': imagePath,
  };

  factory Inhabitant.fromJson(Map<String, dynamic> json) => Inhabitant(
    id: json['id'] as String,
    aquariumId: json['aquariumId'] as String? ?? '',
    name: json['name'] as String,
    latinName: json['latinName'] as String? ?? '',
    category: CreatureCategory.values.byName(
      json['category'] as String? ?? 'other',
    ),
    count: json['count'] as int? ?? 1,
    addedDate: DateTime.parse(json['addedDate'] as String),
    plantPosition: json['plantPosition'] == null
        ? null
        : PlantPosition.values.byName(json['plantPosition'] as String),
    status: json['status'] as String? ?? 'Zdrowe',
    difficulty: json['difficulty'] as String?,
    notes: json['notes'] as String?,
    imagePath: json['imagePath'] as String?,
  );
}

/// Pomiar parametrów wody gotowy do zapisu w bazie danych.
class WaterTest {
  const WaterTest({
    required this.id,
    required this.date,
    this.ph,
    this.no3,
    this.po4,
    this.fe,
    this.kh,
    this.gh,
    this.temp,
    this.aquariumId = '',
  });

  final String id;
  final DateTime date;
  final double? ph;
  final double? no3;
  final double? po4;
  final double? fe;
  final double? kh;
  final double? gh;
  final double? temp;
  final String aquariumId;

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    if (ph != null) 'ph': ph,
    if (no3 != null) 'no3': no3,
    if (po4 != null) 'po4': po4,
    if (fe != null) 'fe': fe,
    if (kh != null) 'kh': kh,
    if (gh != null) 'gh': gh,
    if (temp != null) 'temp': temp,
    'aquariumId': aquariumId,
  };

  factory WaterTest.fromMap(Map<String, dynamic> map) {
    return WaterTest(
      id: map['id'] as String,
      date: _readDate(map['date']),
      ph: (map['ph'] as num?)?.toDouble(),
      no3: (map['no3'] as num?)?.toDouble(),
      po4: (map['po4'] as num?)?.toDouble(),
      fe: (map['fe'] as num?)?.toDouble(),
      kh: (map['kh'] as num?)?.toDouble(),
      gh: (map['gh'] as num?)?.toDouble(),
      temp: (map['temp'] as num?)?.toDouble(),
      aquariumId: map['aquariumId'] as String? ?? '',
    );
  }
}

String waterTestSummary(WaterTest test) => [
  if (test.ph != null) 'pH ${test.ph}',
  if (test.no3 != null) 'NO3 ${test.no3} mg/l',
  if (test.po4 != null) 'PO4 ${test.po4} mg/l',
  if (test.fe != null) 'Fe ${test.fe} mg/l',
  if (test.kh != null) 'KH ${test.kh} dKH',
  if (test.gh != null) 'GH ${test.gh} dGH',
  if (test.temp != null) 'Temp ${test.temp}°C',
].join(' · ');

DateTime _readDate(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.parse(value as String);
}

/// Zapis wykonanej podmiany wody.
class WaterChange {
  const WaterChange({
    required this.id,
    required this.date,
    required this.volumeLiters,
    this.notes = '',
    this.aquariumId = '',
  });

  final String id;
  final DateTime date;
  final double volumeLiters;
  final String notes;
  final String aquariumId;

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'volumeLiters': volumeLiters,
    'notes': notes,
    'aquariumId': aquariumId,
  };

  factory WaterChange.fromMap(Map<String, dynamic> map) {
    return WaterChange(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      volumeLiters: (map['volumeLiters'] as num).toDouble(),
      notes: map['notes'] as String? ?? '',
      aquariumId: map['aquariumId'] as String? ?? '',
    );
  }
}

enum JournalCategory {
  observation,
  fishHealth,
  plantGrowth,
  algae,
  equipment,
  other,
}

extension JournalCategoryLabel on JournalCategory {
  String get label {
    switch (this) {
      case JournalCategory.observation:
        return 'Obserwacja';
      case JournalCategory.fishHealth:
        return 'Zdrowie ryb';
      case JournalCategory.plantGrowth:
        return 'Wzrost roślin';
      case JournalCategory.algae:
        return 'Glony';
      case JournalCategory.equipment:
        return 'Sprzęt / inwestycje';
      case JournalCategory.other:
        return 'Inne';
    }
  }
}

/// Wpis dziennika akwarium. Starsze wpisy testów i podmian zachowują zgodność.
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.type,
    this.imagePaths = const [],
    this.category = JournalCategory.other,
    this.tags = const [],
    this.attachedWaterParameters,
    this.aquariumId = '',
  });

  final String id;
  final DateTime date;
  final String title;
  final String description;
  final String type;
  final List<String> imagePaths;
  final JournalCategory category;
  final List<String> tags;
  final Map<String, double>? attachedWaterParameters;
  final String aquariumId;

  String get notes => description;
  DateTime get timestamp => date;

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'title': title,
    'description': description,
    'type': type,
    'imagePaths': imagePaths,
    'category': category.name,
    'tags': tags,
    'attachedWaterParameters': attachedWaterParameters,
    'aquariumId': aquariumId,
  };

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      title: map['title'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      imagePaths: List<String>.from(map['imagePaths'] as List? ?? const []),
      category: JournalCategory.values.byName(
        map['category'] as String? ?? 'other',
      ),
      tags: List<String>.from(map['tags'] as List? ?? const []),
      attachedWaterParameters: (map['attachedWaterParameters'] as Map?)?.map(
        (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
      ),
      aquariumId: map['aquariumId'] as String? ?? '',
    );
  }
}

enum TaskRecurrence { once, daily, everyXDays, weekly, monthly }

int aquariumTaskNotificationId(String taskId) {
  final suffix = taskId.length <= 8
      ? taskId
      : taskId.substring(taskId.length - 8);
  return int.tryParse(suffix) ?? (taskId.hashCode & 0x7fffffff);
}

class AquariumTask {
  const AquariumTask({
    required this.id,
    required this.title,
    required this.description,
    required this.recurrence,
    required this.intervalDays,
    required this.nextDueDate,
    this.lastCompletedDate,
    this.isCompletedToday = false,
    this.categoryColorHex = '#00E5FF',
    this.reminderMinutes,
    this.aquariumId = '',
  });

  final String id;
  final String title;
  final String description;
  final TaskRecurrence recurrence;
  final int intervalDays;
  final DateTime nextDueDate;
  final DateTime? lastCompletedDate;
  final bool isCompletedToday;
  final String categoryColorHex;
  final int? reminderMinutes;
  final String aquariumId;

  bool get isCompletedForCurrentDay {
    final completedAt = lastCompletedDate;
    if (!isCompletedToday || completedAt == null) return false;
    if (recurrence == TaskRecurrence.once) return true;
    final now = DateTime.now();
    return completedAt.year == now.year &&
        completedAt.month == now.month &&
        completedAt.day == now.day;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'recurrence': recurrence.name,
    'intervalDays': intervalDays,
    'nextDueDate': nextDueDate.toIso8601String(),
    'lastCompletedDate': lastCompletedDate?.toIso8601String(),
    'isCompletedToday': isCompletedForCurrentDay,
    'categoryColorHex': categoryColorHex,
    'reminderMinutes': reminderMinutes,
    'aquariumId': aquariumId,
  };

  Map<String, dynamic> toFirestore() => {
    ...toJson(),
    'nextDueDate': Timestamp.fromDate(nextDueDate),
    'lastCompletedDate': lastCompletedDate == null
        ? null
        : Timestamp.fromDate(lastCompletedDate!),
  };

  factory AquariumTask.fromJson(Map<String, dynamic> json) => AquariumTask(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    recurrence: TaskRecurrence.values.byName(json['recurrence'] as String),
    intervalDays: json['intervalDays'] as int? ?? 1,
    nextDueDate: _readDate(json['nextDueDate']),
    lastCompletedDate: json['lastCompletedDate'] == null
        ? null
        : _readDate(json['lastCompletedDate']),
    isCompletedToday: json['isCompletedToday'] as bool? ?? false,
    categoryColorHex: json['categoryColorHex'] as String? ?? '#00E5FF',
    reminderMinutes: json['reminderMinutes'] as int?,
    aquariumId: json['aquariumId'] as String? ?? '',
  );

  factory AquariumTask.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) => AquariumTask.fromJson({...?snapshot.data(), 'id': snapshot.id});

  AquariumTask completed(DateTime completedAt) {
    final nextDate = switch (recurrence) {
      TaskRecurrence.once => nextDueDate,
      TaskRecurrence.daily => nextRecurrenceDateAfter(
        completedAt,
        nextDueDate,
        1,
      ),
      TaskRecurrence.everyXDays => nextRecurrenceDateAfter(
        completedAt,
        nextDueDate,
        intervalDays,
      ),
      TaskRecurrence.weekly => nextRecurrenceDateAfter(
        completedAt,
        nextDueDate,
        7,
      ),
      TaskRecurrence.monthly => _nextMonthlyDate(completedAt, nextDueDate),
    };
    return AquariumTask(
      id: id,
      title: title,
      description: description,
      recurrence: recurrence,
      intervalDays: intervalDays,
      nextDueDate: nextDate,
      lastCompletedDate: completedAt,
      isCompletedToday: true,
      categoryColorHex: categoryColorHex,
      reminderMinutes: reminderMinutes,
      aquariumId: aquariumId,
    );
  }

  AquariumTask reopened() => AquariumTask(
    id: id,
    title: title,
    description: description,
    recurrence: recurrence,
    intervalDays: intervalDays,
    nextDueDate: lastCompletedDate ?? nextDueDate,
    lastCompletedDate: null,
    categoryColorHex: categoryColorHex,
    reminderMinutes: reminderMinutes,
    aquariumId: aquariumId,
  );
}

DateTime _nextMonthlyDate(DateTime completedAt, DateTime scheduledDate) {
  final firstDayOfNextMonth = DateTime(completedAt.year, completedAt.month + 1);
  final lastDayOfNextMonth = DateTime(
    firstDayOfNextMonth.year,
    firstDayOfNextMonth.month + 1,
    0,
  ).day;
  return DateTime(
    firstDayOfNextMonth.year,
    firstDayOfNextMonth.month,
    completedAt.day < lastDayOfNextMonth ? completedAt.day : lastDayOfNextMonth,
    scheduledDate.hour,
    scheduledDate.minute,
    scheduledDate.second,
    scheduledDate.millisecond,
    scheduledDate.microsecond,
  );
}

/// Stan danych akwarium udostępniany widokom przez pakiet provider.
class AquariumProvider extends ChangeNotifier {
  static const _waterTestsKey = 'aquarium.water_tests';
  static const _waterChangesKey = 'aquarium.water_changes';
  static const _journalEntriesKey = 'aquarium.journal_entries';
  static const _tasksKey = 'aquarium.tasks';
  static const _pendingTasksOwnerKey = 'aquarium.tasks.pending_uid';
  static const _aquariumsKey = 'aquarium.profiles';
  static const _inhabitantsKey = 'aquarium.inhabitants';
  static const _activeAquariumKey = 'aquarium.active_id';

  AquariumProvider({
    List<WaterTest>? waterTests,
    List<WaterChange>? waterChanges,
    List<JournalEntry>? journalEntries,
    List<AquariumTask>? tasks,
    List<AquariumProfile>? aquariums,
    List<Inhabitant>? inhabitants,
    String? activeAquariumId,
  }) : _waterTests = List<WaterTest>.of(waterTests ?? const []),
       _waterChanges = List<WaterChange>.of(waterChanges ?? const []),
       _journalEntries = List<JournalEntry>.of(journalEntries ?? const []),
       _tasks = List<AquariumTask>.of(tasks ?? const []),
       _aquariums = List<AquariumProfile>.of(aquariums ?? const []),
       _inhabitants = List<Inhabitant>.of(inhabitants ?? const []),
       _activeAquariumId =
           activeAquariumId ??
           (aquariums != null && aquariums.isNotEmpty
               ? aquariums.first.id
               : '');

  final List<WaterTest> _waterTests;
  final List<WaterChange> _waterChanges;
  final List<JournalEntry> _journalEntries;
  final List<AquariumTask> _tasks;
  final List<AquariumProfile> _aquariums;
  final List<Inhabitant> _inhabitants;
  String _activeAquariumId;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _waterTestsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _tasksSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _aquariumsSubscription;
  StreamSubscription<User?>? _authStateSubscription;
  String? _currentTasksUserId;
  int _authGeneration = 0;
  bool _hasResolvedAuthState = false;
  bool _waterTestsSyncFailed = false;

  String get activeAquariumId => _activeAquariumId;
  String get selectedAquariumId => _activeAquariumId;
  bool get waterTestsSyncFailed => _waterTestsSyncFailed;
  List<AquariumProfile> get aquariums => List.unmodifiable(_aquariums);
  AquariumProfile? get selectedAquarium {
    for (final aquarium in _aquariums) {
      if (aquarium.id == _activeAquariumId) return aquarium;
    }
    return _aquariums.firstOrNull;
  }

  AquariumProfile get activeAquarium =>
      selectedAquarium ?? (throw StateError('Brak aktywnego akwarium.'));
  List<WaterTest> get waterTests => List.unmodifiable(
    _waterTests.where((test) => test.aquariumId == _activeAquariumId),
  );
  List<WaterChange> get waterChanges => List.unmodifiable(
    _waterChanges.where((change) => change.aquariumId == _activeAquariumId),
  );
  List<JournalEntry> get journalEntries => List.unmodifiable(
    _journalEntries.where((entry) => entry.aquariumId == _activeAquariumId),
  );
  List<AquariumTask> get tasks => List.unmodifiable(
    _tasks.where((task) => task.aquariumId == _activeAquariumId),
  );
  List<Inhabitant> get inhabitants => List.unmodifiable(
    _inhabitants.where((item) => item.aquariumId == _activeAquariumId),
  );

  /// Wczytuje dane lokalne i uruchamia synchronizację dla zalogowanego użytkownika.
  Future<void> initialize() async {
    await loadData();

    try {
      final auth = FirebaseAuth.instance;
      if (kIsWeb) {
        try {
          await auth.setPersistence(Persistence.LOCAL);
        } on Object catch (error, stackTrace) {
          debugPrint(
            'Firebase web auth persistence setup failed: $error\n$stackTrace',
          );
        }
      }
      await _authStateSubscription?.cancel();
      _authStateSubscription = auth.authStateChanges().listen(
        (user) => unawaited(_handleAuthState(user)),
        onError: (Object error) {
          debugPrint('Firebase auth state stream failed: $error');
        },
      );
    } on Object catch (error, stackTrace) {
      debugPrint(
        'Firebase auth synchronization could not start: $error\n$stackTrace',
      );
    }
  }

  Future<void> _handleAuthState(User? user) async {
    final generation = ++_authGeneration;
    final previousUserId = _currentTasksUserId;
    final isFirstAuthState = !_hasResolvedAuthState;
    _hasResolvedAuthState = true;
    await _aquariumsSubscription?.cancel();
    await _waterTestsSubscription?.cancel();
    await _tasksSubscription?.cancel();

    if (!isFirstAuthState && previousUserId != user?.uid) {
      _clearTasks();
    }
    _currentTasksUserId = user?.uid;

    if (user == null) {
      syncCloudAquariums(const []);
      _replaceWaterTests(const []);
      if (!isFirstAuthState) {
        _replaceCloudTasks(const []);
      }
      return;
    }

    var preserveLegacyTasks = false;
    try {
      await _migrateLegacyTasks(user.uid);
    } catch (error, stackTrace) {
      preserveLegacyTasks = true;
      debugPrint('Legacy aquarium task migration failed: $error\n$stackTrace');
    }
    if (generation != _authGeneration) return;

    _listenToAquariums(user.uid);
    _listenToWaterTests(user.uid);
    _listenToTasks(user.uid, preserveLegacyTasks: preserveLegacyTasks);
  }

  Future<void> _migrateLegacyTasks(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final migrationKey = '$_tasksKey.migrated.$userId';
    final pendingOwner = preferences.getString(_pendingTasksOwnerKey);
    if (pendingOwner != null && pendingOwner != userId) {
      _clearTasks();
      return;
    }

    if (preferences.getBool(migrationKey) == true) {
      await preferences.remove(_tasksKey);
      if (pendingOwner == userId) {
        await preferences.remove(_pendingTasksOwnerKey);
      }
      _clearTasks();
      return;
    }

    if (_tasks.isEmpty) {
      final savedTasks = preferences.getString(_tasksKey);
      if (savedTasks != null) {
        _tasks.addAll(_decodeList(savedTasks, AquariumTask.fromJson));
      }
    }

    final legacyTasks = _tasks.where((task) => task.id.isNotEmpty).toList();
    if (legacyTasks.isNotEmpty) {
      await preferences.setString(_pendingTasksOwnerKey, userId);
      final collection = _aquariumTasks(userId);
      for (var start = 0; start < legacyTasks.length; start += 450) {
        final batch = FirebaseFirestore.instance.batch();
        for (final task in legacyTasks.skip(start).take(450)) {
          batch.set(collection.doc(task.id), task.toFirestore());
        }
        await batch.commit();
      }
      await FirestoreSyncStatus.recordSuccessfulSync();
    }

    await preferences.setBool(migrationKey, true);
    await preferences.remove(_tasksKey);
    if (preferences.getString(_pendingTasksOwnerKey) == userId) {
      await preferences.remove(_pendingTasksOwnerKey);
    }
    _clearTasks();
  }

  /// Wczytuje zapisany stan lokalny podczas uruchamiania aplikacji.
  Future<void> loadData() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedTests = preferences.getString(_waterTestsKey);
      final savedChanges = preferences.getString(_waterChangesKey);
      final savedEntries = preferences.getString(_journalEntriesKey);
      final savedTasks = preferences.getString(_tasksKey);
      final savedAquariums = preferences.getString(_aquariumsKey);
      final savedInhabitants = preferences.getString(_inhabitantsKey);
      final savedActiveId = preferences.getString(_activeAquariumKey);

      if (savedTests != null) {
        _waterTests
          ..clear()
          ..addAll(_decodeList(savedTests, WaterTest.fromMap));
      }
      if (savedChanges != null) {
        _waterChanges
          ..clear()
          ..addAll(_decodeList(savedChanges, WaterChange.fromMap));
      }
      if (savedEntries != null) {
        _journalEntries
          ..clear()
          ..addAll(_decodeList(savedEntries, JournalEntry.fromMap));
      }
      if (savedTasks != null) {
        _tasks
          ..clear()
          ..addAll(_decodeList(savedTasks, AquariumTask.fromJson));
      }
      if (savedAquariums != null) {
        _aquariums
          ..clear()
          ..addAll(_decodeList(savedAquariums, AquariumProfile.fromJson));
      }
      if (savedInhabitants != null) {
        _inhabitants
          ..clear()
          ..addAll(_decodeList(savedInhabitants, Inhabitant.fromJson));
      }
      if (savedActiveId != null &&
          _aquariums.any((item) => item.id == savedActiveId)) {
        _activeAquariumId = savedActiveId;
      }

      notifyListeners();
    } on FormatException {
      // Uszkodzony zapis nie blokuje startu aplikacji.
      await _clearStoredDataIfAvailable();
    } on TypeError {
      // Niekompatybilny zapis zostanie pominięty przy kolejnym starcie.
      await _clearStoredDataIfAvailable();
    } catch (_) {
      // Brak pluginu nie blokuje aplikacji; Firebase pozostaje źródłem danych.
    }
  }

  void addWaterTest(WaterTest test) {
    _waterTests.insert(0, test);
    _journalEntries.insert(
      0,
      JournalEntry(
        id: test.id,
        aquariumId: test.aquariumId,
        date: test.date,
        title: 'Test parametrów wody',
        description: waterTestSummary(test),
        type: 'waterTest',
      ),
    );
    notifyListeners();
    _persist();
    _saveWaterTestToFirestore(test);
  }

  void selectAquarium(String aquariumId) {
    if (!_aquariums.any((aquarium) => aquarium.id == aquariumId)) return;
    _activeAquariumId = aquariumId;
    notifyListeners();
    _persist();
  }

  void setSelectedAquarium(String aquariumId) => selectAquarium(aquariumId);

  void syncCloudAquariums(
    List<firestore_models.AquariumModel> cloudAquariums, {
    bool isFromCache = false,
  }) {
    if (cloudAquariums.isEmpty && isFromCache && _aquariums.isNotEmpty) return;
    final mapped = cloudAquariums
        .map(
          (aquarium) => AquariumProfile(
            id: aquarium.id,
            name: aquarium.name,
            volumeNetLiters: aquarium.capacityLiters,
            setupDate: aquarium.setupDate,
            type: _tankTypeFromLabel(aquarium.type),
            isActive: aquarium.id == _activeAquariumId,
          ),
        )
        .toList(growable: false);
    mapped.sort((first, second) => second.setupDate.compareTo(first.setupDate));
    final nextActiveAquariumId =
        mapped.any((aquarium) => aquarium.id == _activeAquariumId)
        ? _activeAquariumId
        : mapped.firstOrNull?.id ?? '';
    final hasChanged =
        mapped.length != _aquariums.length ||
        nextActiveAquariumId != _activeAquariumId ||
        mapped.asMap().entries.any((entry) {
          final current = entry.value;
          final previous = _aquariums[entry.key];
          return current.id != previous.id ||
              current.name != previous.name ||
              current.volumeNetLiters != previous.volumeNetLiters ||
              current.setupDate != previous.setupDate ||
              current.type != previous.type;
        });
    if (!hasChanged) return;

    _aquariums
      ..clear()
      ..addAll(mapped);
    _activeAquariumId = nextActiveAquariumId;
    notifyListeners();
    _persist();
  }

  Future<void> addAquarium(AquariumProfile profile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Zaloguj się, aby zapisać akwarium.');
    await _writeAquariumToFirestore(user.uid, profile);
    _upsertAquarium(profile);
  }

  Future<void> updateAquarium(AquariumProfile profile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Zaloguj się, aby zapisać akwarium.');
    await _writeAquariumToFirestore(user.uid, profile, merge: true);
    _upsertAquarium(profile);
  }

  void _upsertAquarium(AquariumProfile profile) {
    final index = _aquariums.indexWhere((item) => item.id == profile.id);
    if (index == -1) {
      _aquariums.add(profile);
    } else {
      _aquariums[index] = profile;
    }
    if (_activeAquariumId.isEmpty || _aquariums.length == 1) {
      _activeAquariumId = profile.id;
    }
    notifyListeners();
    _persist();
  }

  Future<void> deleteAquarium(String aquariumId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Zaloguj się, aby usunąć akwarium.');
    if (aquariumId.trim().isEmpty) {
      throw ArgumentError('Aquarium id cannot be empty.');
    }
    await _deleteTasksForAquarium(user.uid, aquariumId);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('aquariums')
        .doc(aquariumId)
        .delete();
    await FirestoreSyncStatus.recordSuccessfulSync();
    _aquariums.removeWhere((item) => item.id == aquariumId);
    _inhabitants.removeWhere((item) => item.aquariumId == aquariumId);
    _waterTests.removeWhere((item) => item.aquariumId == aquariumId);
    _waterChanges.removeWhere((item) => item.aquariumId == aquariumId);
    _journalEntries.removeWhere((item) => item.aquariumId == aquariumId);
    final removedTasks = _tasks
        .where((item) => item.aquariumId == aquariumId)
        .toList();
    _tasks.removeWhere((item) => item.aquariumId == aquariumId);
    for (final task in removedTasks) {
      unawaited(
        LocalReminderService.instance.cancel(
          aquariumTaskNotificationId(task.id),
        ),
      );
    }
    if (_activeAquariumId == aquariumId) {
      _activeAquariumId = _aquariums.firstOrNull?.id ?? '';
    }
    notifyListeners();
    _persist();
  }

  void addInhabitant(Inhabitant inhabitant) {
    _inhabitants.add(inhabitant);
    notifyListeners();
    _persist();
  }

  void _listenToAquariums(String userId) {
    if (userId.trim().isEmpty) return;
    _aquariumsSubscription?.cancel();
    _aquariumsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('aquariums')
        .snapshots()
        .listen(
          (snapshot) => syncCloudAquariums(
            snapshot.docs
                .map(firestore_models.AquariumModel.fromFirestore)
                .toList(growable: false),
            isFromCache: snapshot.metadata.isFromCache,
          ),
          onError: (Object error) =>
              debugPrint('Firestore aquarium stream failed: $error'),
        );
  }

  Future<void> _writeAquariumToFirestore(
    String userId,
    AquariumProfile profile, {
    bool merge = false,
  }) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError('User id cannot be empty.');
    }
    if (profile.id.trim().isEmpty) {
      throw ArgumentError('Aquarium id cannot be empty.');
    }
    final reference = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('aquariums')
        .doc(profile.id);
    final existing = merge ? await reference.get() : null;
    final existingCreatedAt = existing?.data()?['createdAt'];
    final createdAt = existingCreatedAt is Timestamp
        ? existingCreatedAt.toDate()
        : DateTime.now();
    final aquarium = firestore_models.AquariumModel(
      id: profile.id,
      userId: userId,
      name: profile.name,
      capacityLiters: profile.volumeNetLiters,
      setupDate: profile.setupDate,
      type: profile.type.name,
      createdAt: createdAt,
    );
    await reference.set(aquarium.toMap(), SetOptions(merge: merge));
    await FirestoreSyncStatus.recordSuccessfulSync();
  }

  void updateInhabitant(Inhabitant inhabitant) {
    final index = _inhabitants.indexWhere((item) => item.id == inhabitant.id);
    if (index == -1) return;
    _inhabitants[index] = inhabitant;
    notifyListeners();
    _persist();
  }

  void deleteInhabitant(String inhabitantId) {
    _inhabitants.removeWhere((item) => item.id == inhabitantId);
    notifyListeners();
    _persist();
  }

  void addJournalEntry(JournalEntry entry) {
    _journalEntries.insert(0, entry);
    notifyListeners();
    _persist();
  }

  Future<void> addTask(AquariumTask task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Zaloguj się, aby zapisać zadanie.');
    }
    await _writeTaskToFirestore(user.uid, task);
    _tasks.removeWhere((saved) => saved.id == task.id);
    _tasks.add(task);
    notifyListeners();
    _scheduleTaskReminder(task);
  }

  Future<AquariumTask?> completeTask(
    String taskId, {
    DateTime? completedAt,
  }) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) return null;
    final completed = _tasks[index].completed(completedAt ?? DateTime.now());
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Zaloguj się, aby zaktualizować zadanie.');
    }
    await _writeTaskToFirestore(user.uid, completed);
    _tasks[index] = completed;
    notifyListeners();
    _scheduleTaskReminder(completed);
    return completed;
  }

  Future<void> reopenTask(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) return;
    final reopened = _tasks[index].reopened();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Zaloguj się, aby zaktualizować zadanie.');
    }
    await _writeTaskToFirestore(user.uid, reopened);
    _tasks[index] = reopened;
    notifyListeners();
    _scheduleTaskReminder(reopened);
  }

  void updateWaterTest(WaterTest test) {
    final index = _waterTests.indexWhere((item) => item.id == test.id);
    if (index == -1) {
      return;
    }

    _waterTests[index] = test;
    final journalIndex = _journalEntries.indexWhere(
      (entry) => entry.id == test.id,
    );
    if (journalIndex != -1) {
      _journalEntries[journalIndex] = JournalEntry(
        id: test.id,
        aquariumId: test.aquariumId,
        date: test.date,
        title: 'Test parametrów wody',
        description: waterTestSummary(test),
        type: 'waterTest',
      );
    }
    notifyListeners();
    _persist();
  }

  void addWaterChange(WaterChange change) {
    _waterChanges.insert(0, change);
    _journalEntries.insert(
      0,
      JournalEntry(
        id: change.id,
        aquariumId: change.aquariumId,
        date: change.date,
        title: 'Podmiana wody',
        description: [
          '${change.volumeLiters.toStringAsFixed(0)} litrów',
          if (change.notes.trim().isNotEmpty) change.notes.trim(),
        ].join(' · '),
        type: 'waterChange',
      ),
    );
    notifyListeners();
    _persist();
  }

  void updateWaterChange(WaterChange change) {
    final index = _waterChanges.indexWhere((item) => item.id == change.id);
    if (index == -1) {
      return;
    }

    _waterChanges[index] = change;
    final journalIndex = _journalEntries.indexWhere(
      (entry) => entry.id == change.id,
    );
    if (journalIndex != -1) {
      _journalEntries[journalIndex] = JournalEntry(
        id: change.id,
        aquariumId: change.aquariumId,
        date: change.date,
        title: 'Podmiana wody',
        description: [
          '${change.volumeLiters.toStringAsFixed(0)} litrów',
          if (change.notes.trim().isNotEmpty) change.notes.trim(),
        ].join(' · '),
        type: 'waterChange',
      );
    }
    notifyListeners();
    _persist();
  }

  List<T> _decodeList<T>(
    String source,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    final decoded = jsonDecode(source);
    if (decoded is! List) {
      throw const FormatException('Oczekiwano listy danych');
    }

    return decoded
        .map((item) => fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> _persist() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await Future.wait([
        preferences.setString(
          _waterTestsKey,
          jsonEncode(_waterTests.map((test) => test.toMap()).toList()),
        ),
        preferences.setString(
          _waterChangesKey,
          jsonEncode(_waterChanges.map((change) => change.toMap()).toList()),
        ),
        preferences.setString(
          _journalEntriesKey,
          jsonEncode(_journalEntries.map((entry) => entry.toMap()).toList()),
        ),
        preferences.setString(
          _aquariumsKey,
          jsonEncode(_aquariums.map((aquarium) => aquarium.toJson()).toList()),
        ),
        preferences.setString(
          _inhabitantsKey,
          jsonEncode(_inhabitants.map((item) => item.toJson()).toList()),
        ),
        preferences.setString(_activeAquariumKey, _activeAquariumId),
      ]);
    } catch (_) {
      // Błąd pluginu nie może przerwać zapisu do Firestore ani działania UI.
    }
  }

  CollectionReference<Map<String, dynamic>> _aquariumTasks(String userId) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('aquarium_tasks');

  Future<void> _deleteTasksForAquarium(String userId, String aquariumId) async {
    final snapshot = await _aquariumTasks(userId)
        .where('aquariumId', isEqualTo: aquariumId)
        .get();
    for (var start = 0; start < snapshot.docs.length; start += 450) {
      final batch = FirebaseFirestore.instance.batch();
      for (final document in snapshot.docs.skip(start).take(450)) {
        batch.delete(document.reference);
      }
      await batch.commit();
    }
  }

  void _listenToTasks(String userId, {required bool preserveLegacyTasks}) {
    _tasksSubscription = _aquariumTasks(userId).snapshots().listen(
      (snapshot) => _replaceCloudTasks(
        snapshot.docs.map(AquariumTask.fromFirestore).toList(),
        preserveLegacyTasks: preserveLegacyTasks,
      ),
      onError: (Object error, StackTrace stackTrace) => debugPrint(
        'Firestore aquarium task stream failed: $error\n$stackTrace',
      ),
    );
  }

  void _replaceCloudTasks(
    List<AquariumTask> cloudTasks, {
    bool preserveLegacyTasks = false,
  }) {
    final merged =
        <String, AquariumTask>{
          if (preserveLegacyTasks)
            for (final task in _tasks) task.id: task,
          for (final task in cloudTasks) task.id: task,
        }.values.toList()..sort(
          (first, second) => first.nextDueDate.compareTo(second.nextDueDate),
        );
    final newIds = merged.map((task) => task.id).toSet();
    for (final previous in _tasks) {
      if (!newIds.contains(previous.id)) {
        unawaited(
          LocalReminderService.instance.cancel(
            aquariumTaskNotificationId(previous.id),
          ),
        );
      }
    }
    _tasks
      ..clear()
      ..addAll(merged);
    for (final task in _tasks) {
      _scheduleTaskReminder(task);
    }
    notifyListeners();
  }

  void _clearTasks() {
    for (final task in _tasks) {
      unawaited(
        LocalReminderService.instance.cancel(
          aquariumTaskNotificationId(task.id),
        ),
      );
    }
    _tasks.clear();
  }

  Future<void> _writeTaskToFirestore(String userId, AquariumTask task) async {
    if (userId.trim().isEmpty || task.id.trim().isEmpty) {
      throw ArgumentError('User id and task id cannot be empty.');
    }
    await _aquariumTasks(userId).doc(task.id).set(task.toFirestore());
    await FirestoreSyncStatus.recordSuccessfulSync();
  }

  void _scheduleTaskReminder(AquariumTask task) {
    if (task.recurrence == TaskRecurrence.once &&
        task.isCompletedForCurrentDay) {
      unawaited(
        LocalReminderService.instance.cancel(
          aquariumTaskNotificationId(task.id),
        ),
      );
      return;
    }
    final now = DateTime.now();
    unawaited(
      LocalReminderService.instance.schedule(
        ScheduledReminder(
          id: aquariumTaskNotificationId(task.id),
          title: task.title,
          body: task.description,
          date: task.nextDueDate.isAfter(now)
              ? task.nextDueDate
              : now.add(const Duration(minutes: 1)),
        ),
      ),
    );
  }

  void _listenToWaterTests(String uid) {
    if (uid.trim().isEmpty) return;
    _waterTestsSubscription?.cancel();
    _waterTestsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('water_tests')
        .orderBy('date', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final tests = snapshot.docs
                .map(
                  (document) => WaterTest.fromMap({
                    ...document.data(),
                    'id': document.id,
                  }),
                )
                .toList();
            _replaceWaterTests(tests);
          },
          onError: (Object error) {
            _recordWaterTestsSyncError(error);
          },
        );
  }

  void _replaceWaterTests(List<WaterTest> tests) {
    _waterTestsSyncFailed = false;
    _waterTests
      ..clear()
      ..addAll(tests);

    final nonTestEntries = _journalEntries
        .where((entry) => entry.type != 'waterTest')
        .toList();
    final testEntries = tests.map(_journalEntryForTest).toList();
    _journalEntries
      ..clear()
      ..addAll(
        [...testEntries, ...nonTestEntries]
          ..sort((a, b) => b.date.compareTo(a.date)),
      );
    notifyListeners();
    _persist();
  }

  JournalEntry _journalEntryForTest(WaterTest test) {
    return JournalEntry(
      id: test.id,
      aquariumId: test.aquariumId,
      date: test.date,
      title: 'Test parametrów wody',
      description: waterTestSummary(test),
      type: 'waterTest',
    );
  }

  Future<void> _saveWaterTestToFirestore(WaterTest test) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
      if (user.uid.trim().isEmpty || test.id.trim().isEmpty) return;

      final firestore = FirebaseFirestore.instance;
      final userReference = firestore.collection('users').doc(user.uid);
      final batch = firestore.batch();
      final timestamp = Timestamp.fromDate(test.date);
      final testData = Map<String, dynamic>.from(test.toMap())
        ..['date'] = timestamp;
      batch.set(userReference.collection('water_tests').doc(test.id), testData);
      if (test.aquariumId.trim().isNotEmpty) {
        batch.set(
          userReference
              .collection('aquariums')
              .doc(test.aquariumId)
              .collection('water_parameters')
              .doc(test.id),
          {
            'id': test.id,
            'aquariumId': test.aquariumId,
            'timestamp': timestamp,
            if (test.ph != null) 'ph': test.ph,
            if (test.kh != null) 'kh': test.kh,
            if (test.gh != null) 'gh': test.gh,
            if (test.no3 != null) 'no3': test.no3,
            if (test.po4 != null) 'po4': test.po4,
            if (test.fe != null) 'fe': test.fe,
            if (test.temp != null) 'temp': test.temp,
            'notes': '',
          },
          SetOptions(merge: true),
        );
      }
      await batch.commit();
      final hadSyncError = _waterTestsSyncFailed;
      _waterTestsSyncFailed = false;
      if (hadSyncError) notifyListeners();
      await FirestoreSyncStatus.recordSuccessfulSync();
    } on Object catch (error) {
      _recordWaterTestsSyncError(error);
    }
  }

  void _recordWaterTestsSyncError(Object error) {
    debugPrint('Water-test Firestore sync failed: $error');
    if (_waterTestsSyncFailed) return;
    _waterTestsSyncFailed = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _waterTestsSubscription?.cancel();
    _tasksSubscription?.cancel();
    _aquariumsSubscription?.cancel();
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _clearStoredDataIfAvailable() async {
    _waterTests.clear();
    _waterChanges.clear();
    _journalEntries.clear();
    _clearTasks();
    _aquariums.clear();
    _inhabitants.clear();
    try {
      final preferences = await SharedPreferences.getInstance();
      await Future.wait([
        preferences.remove(_waterTestsKey),
        preferences.remove(_waterChangesKey),
        preferences.remove(_journalEntriesKey),
        preferences.remove(_tasksKey),
        preferences.remove(_pendingTasksOwnerKey),
        preferences.remove(_aquariumsKey),
        preferences.remove(_inhabitantsKey),
        preferences.remove(_activeAquariumKey),
      ]);
    } catch (_) {
      // Nie ma czego czyścić, jeśli plugin nie jest zarejestrowany.
    }
    notifyListeners();
  }
}
