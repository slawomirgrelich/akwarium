import 'dart:convert';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Typ prowadzonego akwarium.
enum AquariumType { planted, marine, community }

/// Pomiar parametrów wody gotowy do zapisu w bazie danych.
class WaterTest {
  const WaterTest({
    required this.id,
    required this.date,
    required this.ph,
    required this.no3,
    required this.po4,
    required this.fe,
    required this.kh,
    required this.gh,
    required this.temp,
  });

  final String id;
  final DateTime date;
  final double ph;
  final double no3;
  final double po4;
  final double fe;
  final double kh;
  final double gh;
  final double temp;

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'ph': ph,
    'no3': no3,
    'po4': po4,
    'fe': fe,
    'kh': kh,
    'gh': gh,
    'temp': temp,
  };

  factory WaterTest.fromMap(Map<String, dynamic> map) {
    return WaterTest(
      id: map['id'] as String,
      date: _readDate(map['date']),
      ph: (map['ph'] as num).toDouble(),
      no3: (map['no3'] as num).toDouble(),
      po4: (map['po4'] as num).toDouble(),
      fe: (map['fe'] as num).toDouble(),
      kh: (map['kh'] as num).toDouble(),
      gh: (map['gh'] as num).toDouble(),
      temp: (map['temp'] as num).toDouble(),
    );
  }
}

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
  });

  final String id;
  final DateTime date;
  final double volumeLiters;
  final String notes;

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'volumeLiters': volumeLiters,
    'notes': notes,
  };

  factory WaterChange.fromMap(Map<String, dynamic> map) {
    return WaterChange(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      volumeLiters: (map['volumeLiters'] as num).toDouble(),
      notes: map['notes'] as String? ?? '',
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
    );
  }
}

enum TaskRecurrence { once, daily, everyXDays, weekly, monthly }

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'recurrence': recurrence.name,
    'intervalDays': intervalDays,
    'nextDueDate': nextDueDate.toIso8601String(),
    'lastCompletedDate': lastCompletedDate?.toIso8601String(),
    'isCompletedToday': isCompletedToday,
    'categoryColorHex': categoryColorHex,
    'reminderMinutes': reminderMinutes,
  };

  factory AquariumTask.fromJson(Map<String, dynamic> json) => AquariumTask(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    recurrence: TaskRecurrence.values.byName(json['recurrence'] as String),
    intervalDays: json['intervalDays'] as int? ?? 1,
    nextDueDate: DateTime.parse(json['nextDueDate'] as String),
    lastCompletedDate: json['lastCompletedDate'] == null
        ? null
        : DateTime.parse(json['lastCompletedDate'] as String),
    isCompletedToday: json['isCompletedToday'] as bool? ?? false,
    categoryColorHex: json['categoryColorHex'] as String? ?? '#00E5FF',
    reminderMinutes: json['reminderMinutes'] as int?,
  );

  AquariumTask completed(DateTime completedAt) {
    final nextDate = switch (recurrence) {
      TaskRecurrence.once => nextDueDate,
      TaskRecurrence.daily => completedAt.add(const Duration(days: 1)),
      TaskRecurrence.everyXDays => completedAt.add(Duration(days: intervalDays)),
      TaskRecurrence.weekly => completedAt.add(const Duration(days: 7)),
      TaskRecurrence.monthly => DateTime(
        completedAt.year,
        completedAt.month + 1,
        completedAt.day,
        completedAt.hour,
        completedAt.minute,
      ),
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
  );
}

/// Stan danych akwarium udostępniany widokom przez pakiet provider.
class AquariumProvider extends ChangeNotifier {
  static const _waterTestsKey = 'aquarium.water_tests';
  static const _waterChangesKey = 'aquarium.water_changes';
  static const _journalEntriesKey = 'aquarium.journal_entries';
  static const _tasksKey = 'aquarium.tasks';

  AquariumProvider({
    List<WaterTest>? waterTests,
    List<WaterChange>? waterChanges,
    List<JournalEntry>? journalEntries,
     List<AquariumTask>? tasks,
  }) : _waterTests = List<WaterTest>.of(waterTests ?? const []),
       _waterChanges = List<WaterChange>.of(waterChanges ?? const []),
       _journalEntries = List<JournalEntry>.of(journalEntries ?? const []),
       _tasks = List<AquariumTask>.of(tasks ?? const []);

  final List<WaterTest> _waterTests;
  final List<WaterChange> _waterChanges;
  final List<JournalEntry> _journalEntries;
  final List<AquariumTask> _tasks;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _waterTestsSubscription;

  List<WaterTest> get waterTests => List.unmodifiable(_waterTests);
  List<WaterChange> get waterChanges => List.unmodifiable(_waterChanges);
  List<JournalEntry> get journalEntries => List.unmodifiable(_journalEntries);
  List<AquariumTask> get tasks => List.unmodifiable(_tasks);

  /// Wczytuje dane lokalne, loguje użytkownika anonimowo i uruchamia synchronizację.
  Future<void> initialize() async {
    await loadData();

    try {
      final auth = FirebaseAuth.instance;
      await auth.setPersistence(Persistence.LOCAL);
      final user = auth.currentUser ?? (await auth.signInAnonymously()).user;
      if (user != null) {
        _listenToWaterTests(user.uid);
      }
    } catch (_) {
      // Do czasu konfiguracji Firebase aplikacja korzysta z danych lokalnych.
    }
  }

  /// Wczytuje zapisany stan lokalny podczas uruchamiania aplikacji.
  Future<void> loadData() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedTests = preferences.getString(_waterTestsKey);
      final savedChanges = preferences.getString(_waterChangesKey);
      final savedEntries = preferences.getString(_journalEntriesKey);
      final savedTasks = preferences.getString(_tasksKey);

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
        date: test.date,
        title: 'Test parametrów wody',
        description:
            'pH ${test.ph} · NO3 ${test.no3} mg/l · PO4 ${test.po4} mg/l',
        type: 'waterTest',
      ),
    );
    notifyListeners();
    _persist();
    _saveWaterTestToFirestore(test);
  }

  void addJournalEntry(JournalEntry entry) {
    _journalEntries.insert(0, entry);
    notifyListeners();
    _persist();
  }

  void addTask(AquariumTask task) {
    _tasks.add(task);
    notifyListeners();
    _persist();
  }

  void completeTask(String taskId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) return;
    _tasks[index] = _tasks[index].completed(DateTime.now());
    notifyListeners();
    _persist();
  }

  void reopenTask(String taskId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) return;
    _tasks[index] = _tasks[index].reopened();
    notifyListeners();
    _persist();
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
        date: test.date,
        title: 'Test parametrów wody',
        description:
            'pH ${test.ph} · NO3 ${test.no3} mg/l · PO4 ${test.po4} mg/l',
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
          _tasksKey,
          jsonEncode(_tasks.map((task) => task.toJson()).toList()),
        ),
      ]);
    } catch (_) {
      // Błąd pluginu nie może przerwać zapisu do Firestore ani działania UI.
    }
  }

  void _listenToWaterTests(String uid) {
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
          onError: (_) {
            // Przy braku połączenia aplikacja nadal korzysta z cache lokalnego.
          },
        );
  }

  void _replaceWaterTests(List<WaterTest> tests) {
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
      date: test.date,
      title: 'Test parametrów wody',
      description:
          'pH ${test.ph} · NO3 ${test.no3} mg/l · PO4 ${test.po4} mg/l',
      type: 'waterTest',
    );
  }

  Future<void> _saveWaterTestToFirestore(WaterTest test) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      final data = Map<String, dynamic>.from(test.toMap())
        ..['date'] = test.date;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('water_tests')
          .doc(test.id)
          .set(data);
    } catch (_) {
      // Lokalny zapis pozostaje źródłem danych offline.
    }
  }

  @override
  void dispose() {
    _waterTestsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _clearStoredDataIfAvailable() async {
    _waterTests.clear();
    _waterChanges.clear();
    _journalEntries.clear();
    _tasks.clear();
    try {
      final preferences = await SharedPreferences.getInstance();
      await Future.wait([
        preferences.remove(_waterTestsKey),
        preferences.remove(_waterChangesKey),
        preferences.remove(_journalEntriesKey),
        preferences.remove(_tasksKey),
      ]);
    } catch (_) {
      // Nie ma czego czyścić, jeśli plugin nie jest zarejestrowany.
    }
    notifyListeners();
  }
}

/// Dane zbiornika gotowe do zapisu w Firebase lub Supabase.
class AquariumModel {
  const AquariumModel({
    required this.id,
    required this.name,
    required this.netVolumeLiters,
    required this.type,
    required this.establishedAt,
    this.isActive = true,
  });

  final String id;
  final String name;
  final double netVolumeLiters;
  final AquariumType type;
  final DateTime establishedAt;
  final bool isActive;

  String get typeLabel {
    switch (type) {
      case AquariumType.planted:
        return 'Roślinne';
      case AquariumType.marine:
        return 'Morskie';
      case AquariumType.community:
        return 'Ogólne';
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'netVolumeLiters': netVolumeLiters,
    'type': type.name,
    'establishedAt': establishedAt.toIso8601String(),
    'isActive': isActive,
  };

  factory AquariumModel.fromMap(Map<String, dynamic> map) {
    return AquariumModel(
      id: map['id'] as String,
      name: map['name'] as String,
      netVolumeLiters: (map['netVolumeLiters'] as num).toDouble(),
      type: AquariumType.values.byName(map['type'] as String),
      establishedAt: DateTime.parse(map['establishedAt'] as String),
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}
