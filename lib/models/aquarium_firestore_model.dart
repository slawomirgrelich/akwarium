import 'package:cloud_firestore/cloud_firestore.dart';

class AquariumModel {
  const AquariumModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.capacityLiters,
    required this.setupDate,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String name;
  final double capacityLiters;
  final DateTime setupDate;
  final String type;
  final DateTime createdAt;

  AquariumModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? capacityLiters,
    DateTime? setupDate,
    String? type,
    DateTime? createdAt,
  }) {
    return AquariumModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      capacityLiters: capacityLiters ?? this.capacityLiters,
      setupDate: setupDate ?? this.setupDate,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'capacityLiters': capacityLiters,
      'setupDate': Timestamp.fromDate(setupDate),
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AquariumModel.fromMap(
    Map<String, dynamic>? map, {
    String idFallback = '',
  }) {
    final values = map ?? const <String, dynamic>{};
    final createdAt = _dateFromValue(values['createdAt']) ?? DateTime.now();

    return AquariumModel(
      id: _stringFromValue(values['id'], fallback: idFallback),
      userId: _stringFromValue(values['userId']),
      name: _stringFromValue(values['name'], fallback: 'Bez nazwy'),
      capacityLiters: _doubleFromValue(values['capacityLiters']),
      setupDate: _dateFromValue(values['setupDate']) ?? createdAt,
      type: _stringFromValue(values['type'], fallback: 'Słodkowodne'),
      createdAt: createdAt,
    );
  }

  factory AquariumModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return AquariumModel.fromMap(snapshot.data(), idFallback: snapshot.id);
  }
}

class WaterParametersModel {
  const WaterParametersModel({
    required this.id,
    required this.aquariumId,
    required this.timestamp,
    required this.ph,
    required this.kh,
    required this.gh,
    required this.no3,
    required this.po4,
    required this.fe,
    required this.temp,
    required this.notes,
  });

  final String id;
  final String aquariumId;
  final DateTime timestamp;
  final double ph;
  final double kh;
  final double gh;
  final double no3;
  final double po4;
  final double fe;
  final double temp;
  final String notes;

  WaterParametersModel copyWith({
    String? id,
    String? aquariumId,
    DateTime? timestamp,
    double? ph,
    double? kh,
    double? gh,
    double? no3,
    double? po4,
    double? fe,
    double? temp,
    String? notes,
  }) {
    return WaterParametersModel(
      id: id ?? this.id,
      aquariumId: aquariumId ?? this.aquariumId,
      timestamp: timestamp ?? this.timestamp,
      ph: ph ?? this.ph,
      kh: kh ?? this.kh,
      gh: gh ?? this.gh,
      no3: no3 ?? this.no3,
      po4: po4 ?? this.po4,
      fe: fe ?? this.fe,
      temp: temp ?? this.temp,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'aquariumId': aquariumId,
      'timestamp': Timestamp.fromDate(timestamp),
      'ph': ph,
      'kh': kh,
      'gh': gh,
      'no3': no3,
      'po4': po4,
      'fe': fe,
      'temp': temp,
      'notes': notes,
    };
  }

  factory WaterParametersModel.fromMap(
    Map<String, dynamic>? map, {
    String idFallback = '',
    String aquariumIdFallback = '',
  }) {
    final values = map ?? const <String, dynamic>{};

    return WaterParametersModel(
      id: _stringFromValue(values['id'], fallback: idFallback),
      aquariumId: _stringFromValue(
        values['aquariumId'],
        fallback: aquariumIdFallback,
      ),
      timestamp: _dateFromValue(values['timestamp']) ?? DateTime.now(),
      ph: _doubleFromValue(values['ph']),
      kh: _doubleFromValue(values['kh']),
      gh: _doubleFromValue(values['gh']),
      no3: _doubleFromValue(values['no3']),
      po4: _doubleFromValue(values['po4']),
      fe: _doubleFromValue(values['fe']),
      temp: _doubleFromValue(values['temp']),
      notes: _stringFromValue(values['notes']),
    );
  }

  factory WaterParametersModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, {
    String aquariumIdFallback = '',
  }) {
    return WaterParametersModel.fromMap(
      snapshot.data(),
      idFallback: snapshot.id,
      aquariumIdFallback: aquariumIdFallback,
    );
  }
}

String _stringFromValue(Object? value, {String fallback = ''}) {
  return value is String && value.trim().isNotEmpty ? value : fallback;
}

double _doubleFromValue(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _dateFromValue(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
