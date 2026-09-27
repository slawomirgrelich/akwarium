import 'package:cloud_firestore/cloud_firestore.dart';

enum SpeciesCategory { fish, plant, invertebrate }
enum SpeciesDifficulty { easy, medium, hard }
enum SwimmingZone { bottom, middle, top, all }

class SpeciesRange {
  const SpeciesRange(this.min, this.max);

  final double min;
  final double max;

  bool contains(double value) => value >= min && value <= max;
  bool overlaps(SpeciesRange other) => min <= other.max && other.min <= max;
}

class Species {
  const Species({
    required this.id,
    required this.namePl,
    required this.nameLatin,
    required this.category,
    required this.minTankVolumeLiters,
    required this.tempRange,
    required this.phRange,
    required this.ghRange,
    required this.difficulty,
    required this.swimmingZone,
    required this.description,
    String? careNotes,
    required this.imageUrl,
  }) : careNotes = careNotes ?? description;

  final String id;
  final String namePl;
  final String nameLatin;
  final SpeciesCategory category;
  final int minTankVolumeLiters;
  final SpeciesRange tempRange;
  final SpeciesRange phRange;
  final SpeciesRange ghRange;
  final SpeciesDifficulty difficulty;
  final SwimmingZone swimmingZone;
  final String description;
  final String careNotes;
  final String imageUrl;
}

class TankStockItem {
  const TankStockItem({
    required this.id,
    required this.tankId,
    required this.speciesId,
    required this.count,
    required this.addedDate,
  });

  final String id;
  final String tankId;
  final String speciesId;
  final int count;
  final DateTime addedDate;

  TankStockItem copyWith({String? id, String? tankId, String? speciesId, int? count}) =>
      TankStockItem(
        id: id ?? this.id,
        tankId: tankId ?? this.tankId,
        speciesId: speciesId ?? this.speciesId,
        count: count ?? this.count,
        addedDate: addedDate,
      );

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'tankId': tankId,
        'speciesId': speciesId,
        'count': count,
        'addedDate': Timestamp.fromDate(addedDate),
      };

  factory TankStockItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return TankStockItem(
      id: _string(data['id'], snapshot.id),
      tankId: _string(data['tankId']),
      speciesId: _string(data['speciesId']),
      count: (data['count'] as num?)?.toInt() ?? 1,
      addedDate: _date(data['addedDate']) ?? DateTime.now(),
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