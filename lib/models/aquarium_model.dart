import 'dart:convert';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  int get ageInDays => DateTime.now().difference(setupDate).inDays;

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
        setupDate: DateTime.parse(json['setupDate'] as String),
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
    aquariumId: json['aquariumId'] as String? ?? 'aquarium-001',
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
    required this.ph,
    required this.no3,
    required this.po4,
    required this.fe,
    required this.kh,
    required this.gh,
    required this.temp,
    this.aquariumId = 'aquarium-001',
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
  final String aquariumId;

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
    'aquariumId': aquariumId,
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
      aquariumId: map['aquariumId'] as String? ?? 'aquarium-001',
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
    this.aquariumId = 'aquarium-001',
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
      aquariumId: map['aquariumId'] as String? ?? 'aquarium-001',
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
    this.aquariumId = 'aquarium-001',
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
      aquariumId: map['aquariumId'] as String? ?? 'aquarium-001',
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
    this.aquariumId = 'aquarium-001',
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
    'aquariumId': aquariumId,
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
    aquariumId: json['aquariumId'] as String? ?? 'aquarium-001',
  );

  AquariumTask completed(DateTime completedAt) {
    final nextDate = switch (recurrence) {
      TaskRecurrence.once => nextDueDate,
      TaskRecurrence.daily => completedAt.add(const Duration(days: 1)),
      TaskRecurrence.everyXDays => completedAt.add(
        Duration(days: intervalDays),
      ),
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

/// Stan danych akwarium udostępniany widokom przez pakiet provider.
class AquariumProvider extends ChangeNotifier {
  static const _waterTestsKey = 'aquarium.water_tests';
  static const _waterChangesKey = 'aquarium.water_changes';
  static const _journalEntriesKey = 'aquarium.journal_entries';
  static const _tasksKey = 'aquarium.tasks';
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
       _activeAquariumId = activeAquariumId ?? 'aquarium-001' {
    if (_aquariums.isEmpty) {
      _aquariums.add(
        AquariumProfile(
          id: 'aquarium-001',
          name: 'Akwarium Roślinne',
          volumeNetLiters: 112,
          volumeGrossLiters: 125,
          setupDate: DateTime(2024, 3, 12),
          type: TankType.planted,
          isActive: true,
        ),
      );
    }
  }

  final List<WaterTest> _waterTests;
  final List<WaterChange> _waterChanges;
  final List<JournalEntry> _journalEntries;
  final List<AquariumTask> _tasks;
  final List<AquariumProfile> _aquariums;
  final List<Inhabitant> _inhabitants;
  String _activeAquariumId;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _waterTestsSubscription;

  String get activeAquariumId => _activeAquariumId;
  List<AquariumProfile> get aquariums => List.unmodifiable(_aquariums);
  AquariumProfile get activeAquarium => _aquariums.firstWhere(
    (aquarium) => aquarium.id == _activeAquariumId,
    orElse: () => _aquariums.first,
  );
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
      await auth.setPersistence(Persistence.LOCAL);
      final user = auth.currentUser;
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
        description:
            'pH ${test.ph} · NO3 ${test.no3} mg/l · PO4 ${test.po4} mg/l',
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

  void addAquarium(AquariumProfile profile) {
    _aquariums.add(profile);
    if (_aquariums.length == 1) _activeAquariumId = profile.id;
    notifyListeners();
    _persist();
  }

  void updateAquarium(AquariumProfile profile) {
    final index = _aquariums.indexWhere((item) => item.id == profile.id);
    if (index == -1) return;
    _aquariums[index] = profile;
    notifyListeners();
    _persist();
  }

  void deleteAquarium(String aquariumId) {
    if (_aquariums.length <= 1) return;
    _aquariums.removeWhere((item) => item.id == aquariumId);
    _inhabitants.removeWhere((item) => item.aquariumId == aquariumId);
    _waterTests.removeWhere((item) => item.aquariumId == aquariumId);
    _waterChanges.removeWhere((item) => item.aquariumId == aquariumId);
    _journalEntries.removeWhere((item) => item.aquariumId == aquariumId);
    _tasks.removeWhere((item) => item.aquariumId == aquariumId);
    if (_activeAquariumId == aquariumId)
      _activeAquariumId = _aquariums.first.id;
    notifyListeners();
    _persist();
  }

  void addInhabitant(Inhabitant inhabitant) {
    _inhabitants.add(inhabitant);
    notifyListeners();
    _persist();
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
        aquariumId: test.aquariumId,
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
          _tasksKey,
          jsonEncode(_tasks.map((task) => task.toJson()).toList()),
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
      aquariumId: test.aquariumId,
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
    _aquariums.clear();
    _inhabitants.clear();
    try {
      final preferences = await SharedPreferences.getInstance();
      await Future.wait([
        preferences.remove(_waterTestsKey),
        preferences.remove(_waterChangesKey),
        preferences.remove(_journalEntriesKey),
        preferences.remove(_tasksKey),
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
