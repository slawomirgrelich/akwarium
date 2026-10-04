import 'package:cloud_firestore/cloud_firestore.dart';

class AquariumModel {
  AquariumModel({
    required this.id,
    this.userId = '',
    required this.name,
    double? capacityLiters,
    double? netVolumeLiters,
    DateTime? setupDate,
    DateTime? establishedAt,
    required this.type,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    DateTime? createdAt,
    this.equipment,
  }) : capacityLiters = capacityLiters ?? netVolumeLiters ?? 0,
       setupDate = setupDate ?? establishedAt ?? DateTime(1970),
       createdAt = createdAt ?? DateTime(1970);

  final String id;
  final String userId;
  final String name;
  final double capacityLiters;
  final DateTime setupDate;
  final String type;
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;
  final DateTime createdAt;
  final AquariumEquipment? equipment;

  double get netVolumeLiters => capacityLiters;
  DateTime get establishedAt => setupDate;

  AquariumModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? capacityLiters,
    DateTime? setupDate,
    String? type,
    double? lengthCm,
    double? widthCm,
    double? heightCm,
    DateTime? createdAt,
    AquariumEquipment? equipment,
  }) {
    return AquariumModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      capacityLiters: capacityLiters ?? this.capacityLiters,
      setupDate: setupDate ?? this.setupDate,
      type: type ?? this.type,
      lengthCm: lengthCm ?? this.lengthCm,
      widthCm: widthCm ?? this.widthCm,
      heightCm: heightCm ?? this.heightCm,
      createdAt: createdAt ?? this.createdAt,
      equipment: equipment ?? this.equipment,
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
      if (lengthCm != null) 'lengthCm': lengthCm,
      if (widthCm != null) 'widthCm': widthCm,
      if (heightCm != null) 'heightCm': heightCm,
      'createdAt': Timestamp.fromDate(createdAt),
      if (equipment != null) 'equipment': equipment!.toMap(),
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
      lengthCm: _nullableDoubleFromValue(values['lengthCm']),
      widthCm: _nullableDoubleFromValue(values['widthCm']),
      heightCm: _nullableDoubleFromValue(values['heightCm']),
      createdAt: createdAt,
      equipment: values['equipment'] is Map
          ? AquariumEquipment.fromMap(
              Map<String, dynamic>.from(values['equipment'] as Map),
            )
          : null,
    );
  }

  factory AquariumModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return AquariumModel.fromMap(snapshot.data(), idFallback: snapshot.id);
  }
}

class AquariumEquipment {
  const AquariumEquipment({
    this.lightingModel,
    this.lightingPowerWatts,
    this.lightingHoursPerDay,
    this.co2System,
    this.co2BubblesPerSecond,
    this.feedingNotes,
  });

  final String? lightingModel;
  final double? lightingPowerWatts;
  final double? lightingHoursPerDay;
  final String? co2System;
  final double? co2BubblesPerSecond;
  final String? feedingNotes;

  Map<String, dynamic> toMap() => {
    if (lightingModel?.trim().isNotEmpty ?? false)
      'lightingModel': lightingModel!.trim(),
    if (lightingPowerWatts != null) 'lightingPowerWatts': lightingPowerWatts,
    if (lightingHoursPerDay != null) 'lightingHoursPerDay': lightingHoursPerDay,
    if (co2System?.trim().isNotEmpty ?? false) 'co2System': co2System!.trim(),
    if (co2BubblesPerSecond != null) 'co2BubblesPerSecond': co2BubblesPerSecond,
    if (feedingNotes?.trim().isNotEmpty ?? false)
      'feedingNotes': feedingNotes!.trim(),
  };

  factory AquariumEquipment.fromMap(
    Map<String, dynamic> map,
  ) => AquariumEquipment(
    lightingModel: _stringFromValue(map['lightingModel']),
    lightingPowerWatts: _nullableDoubleFromValue(map['lightingPowerWatts']),
    lightingHoursPerDay: _nullableDoubleFromValue(map['lightingHoursPerDay']),
    co2System: _stringFromValue(map['co2System']),
    co2BubblesPerSecond: _nullableDoubleFromValue(map['co2BubblesPerSecond']),
    feedingNotes: _stringFromValue(map['feedingNotes']),
  );
}

class WaterParametersModel {
  const WaterParametersModel({
    required this.id,
    required this.aquariumId,
    required this.timestamp,
    this.ph,
    this.kh,
    this.gh,
    this.no3,
    this.no2,
    this.po4,
    this.fe,
    this.k,
    this.mg,
    this.temp,
    this.co2,
    this.nh3Nh4,
    this.tds,
    required this.notes,
  });

  final String id;
  final String aquariumId;
  final DateTime timestamp;
  final double? ph;
  final double? kh;
  final double? gh;
  final double? no3;
  final double? no2;
  final double? po4;
  final double? fe;
  final double? k;
  final double? mg;
  final double? temp;
  final double? co2;
  final double? nh3Nh4;
  final double? tds;
  final String notes;

  WaterParametersModel copyWith({
    String? id,
    String? aquariumId,
    DateTime? timestamp,
    double? ph,
    double? kh,
    double? gh,
    double? no3,
    double? no2,
    double? po4,
    double? fe,
    double? k,
    double? mg,
    double? temp,
    double? co2,
    double? nh3Nh4,
    double? tds,
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
      no2: no2 ?? this.no2,
      po4: po4 ?? this.po4,
      fe: fe ?? this.fe,
      k: k ?? this.k,
      mg: mg ?? this.mg,
      temp: temp ?? this.temp,
      co2: co2 ?? this.co2,
      nh3Nh4: nh3Nh4 ?? this.nh3Nh4,
      tds: tds ?? this.tds,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'aquariumId': aquariumId,
      'timestamp': Timestamp.fromDate(timestamp),
      if (ph != null) 'ph': ph,
      if (kh != null) 'kh': kh,
      if (gh != null) 'gh': gh,
      if (no3 != null) 'no3': no3,
      if (no2 != null) 'no2': no2,
      if (po4 != null) 'po4': po4,
      if (fe != null) 'fe': fe,
      if (k != null) 'k': k,
      if (mg != null) 'mg': mg,
      if (temp != null) 'temp': temp,
      if (co2 != null) 'co2': co2,
      if (nh3Nh4 != null) 'nh3Nh4': nh3Nh4,
      if (tds != null) 'tds': tds,
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
      ph: _nullableDoubleFromValue(values['ph']),
      kh: _nullableDoubleFromValue(values['kh']),
      gh: _nullableDoubleFromValue(values['gh']),
      no3: _nullableDoubleFromValue(values['no3']),
      no2: _nullableDoubleFromValue(values['no2']),
      po4: _nullableDoubleFromValue(values['po4']),
      fe: _nullableDoubleFromValue(values['fe']),
      k: _nullableDoubleFromValue(values['k']),
      mg: _nullableDoubleFromValue(values['mg']),
      temp: _nullableDoubleFromValue(values['temp']),
      co2: _nullableDoubleFromValue(values['co2']),
      nh3Nh4: _nullableDoubleFromValue(values['nh3Nh4']),
      tds: _nullableDoubleFromValue(values['tds']),
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

double? _nullableDoubleFromValue(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

DateTime? _dateFromValue(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
