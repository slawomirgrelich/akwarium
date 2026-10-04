import 'package:cloud_firestore/cloud_firestore.dart';

class Tank {
  const Tank({
    required this.id,
    required this.name,
    required this.capacityLiters,
    required this.dimensions,
    required this.createdAt,
    this.imageUrl,
    this.coverPhotoUrl,
    this.coverImagePath,
  });

  final String id;
  final String name;
  final double capacityLiters;
  final String dimensions;
  final DateTime createdAt;
  final String? imageUrl;
  final String? coverPhotoUrl;
  final String? coverImagePath;

  String? get effectiveCoverPhotoUrl => coverPhotoUrl ?? imageUrl;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'name': name,
        'capacityLiters': capacityLiters,
        'dimensions': dimensions,
        'createdAt': Timestamp.fromDate(createdAt),
        'imageUrl': imageUrl,
        'coverPhotoUrl': coverPhotoUrl,
        'coverImagePath': coverImagePath,
      };

  factory Tank.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return Tank(
      id: _string(data['id'], snapshot.id),
      name: _string(data['name'], 'Bez nazwy'),
      capacityLiters: _double(data['capacityLiters']),
      dimensions: _string(data['dimensions']),
      createdAt: _date(data['createdAt']) ?? DateTime.now(),
      imageUrl: _nullableString(data['imageUrl']),
        coverPhotoUrl: _nullableString(data['coverPhotoUrl']) ??
          _nullableString(data['imageUrl']),
        coverImagePath: _nullableString(data['coverImagePath']),
    );
  }
}

class WaterParameter {
  const WaterParameter({
    required this.id,
    required this.timestamp,
    required this.pH,
    required this.kh,
    required this.gh,
    required this.no3,
    required this.po4,
    required this.fe,
    required this.k,
    required this.mg,
    required this.temp,
    required this.note,
    this.co2,
  });

  final String id;
  final DateTime timestamp;
  final double pH;
  final double kh;
  final double gh;
  final double no3;
  final double po4;
  final double fe;
  final double k;
  final double mg;
  final double temp;
  final String note;
  final double? co2;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'timestamp': Timestamp.fromDate(timestamp),
        'pH': pH,
        'kh': kh,
        'gh': gh,
        'no3': no3,
        'po4': po4,
        'fe': fe,
        'k': k,
        'mg': mg,
        'temp': temp,
        'note': note,
        if (co2 != null) 'co2': co2,
      };

  factory WaterParameter.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return WaterParameter(
      id: _string(data['id'], snapshot.id),
      timestamp: _date(data['timestamp']) ?? DateTime.now(),
      pH: _double(data['pH']),
      kh: _double(data['kh']),
      gh: _double(data['gh']),
      no3: _double(data['no3']),
      po4: _double(data['po4']),
      fe: _double(data['fe']),
      k: _double(data['k']),
      mg: _double(data['mg']),
      temp: _double(data['temp']),
      note: _string(data['note']),
      co2: _nullableDouble(data['co2']),
    );
  }
}

class JournalLog {
  const JournalLog({
    required this.id,
    required this.timestamp,
    required this.activityType,
    required this.title,
    this.waterReplacedLiters,
    required this.note,
  });

  final String id;
  final DateTime timestamp;
  final String activityType;
  final String title;
  final double? waterReplacedLiters;
  final String note;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'timestamp': Timestamp.fromDate(timestamp),
        'activityType': activityType,
        'title': title,
        'waterReplacedLiters': waterReplacedLiters,
        'note': note,
      };

  factory JournalLog.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return JournalLog(
      id: _string(data['id'], snapshot.id),
      timestamp: _date(data['timestamp']) ?? DateTime.now(),
      activityType: _string(data['activityType'], 'other'),
      title: _string(data['title'], 'Wpis dziennika'),
      waterReplacedLiters: _nullableDouble(data['waterReplacedLiters']),
      note: _string(data['note']),
    );
  }
}

String _string(Object? value, [String fallback = '']) =>
    value is String && value.trim().isNotEmpty ? value : fallback;

String? _nullableString(Object? value) =>
    value is String && value.trim().isNotEmpty ? value : null;

double _double(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

double? _nullableDouble(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value');

DateTime? _date(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}