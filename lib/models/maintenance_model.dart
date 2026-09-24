/// Rodzaj czynności wykonanej przy akwarium.
enum MaintenanceType { waterChange, cleaning, fertilizing }

/// Historia podmian i innych czynności pielęgnacyjnych.
class MaintenanceModel {
  const MaintenanceModel({
    required this.id,
    required this.aquariumId,
    required this.type,
    required this.performedAt,
    this.volumeLiters,
    this.volumePercent,
    this.note,
  });

  final String id;
  final String aquariumId;
  final MaintenanceType type;
  final DateTime performedAt;
  final double? volumeLiters;
  final double? volumePercent;
  final String? note;

  Map<String, dynamic> toMap() => {
    'id': id,
    'aquariumId': aquariumId,
    'type': type.name,
    'performedAt': performedAt.toIso8601String(),
    'volumeLiters': volumeLiters,
    'volumePercent': volumePercent,
    'note': note,
  };

  factory MaintenanceModel.fromMap(Map<String, dynamic> map) {
    return MaintenanceModel(
      id: map['id'] as String,
      aquariumId: map['aquariumId'] as String,
      type: MaintenanceType.values.byName(map['type'] as String),
      performedAt: DateTime.parse(map['performedAt'] as String),
      volumeLiters: (map['volumeLiters'] as num?)?.toDouble(),
      volumePercent: (map['volumePercent'] as num?)?.toDouble(),
      note: map['note'] as String?,
    );
  }
}
