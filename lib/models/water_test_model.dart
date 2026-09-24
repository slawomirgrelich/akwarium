/// Pojedynczy pomiar parametrów wody z dokładnym znacznikiem czasu.
class WaterTestModel {
  const WaterTestModel({
    required this.id,
    required this.aquariumId,
    required this.recordedAt,
    this.ph,
    this.no3,
    this.po4,
    this.fe,
    this.gh,
    this.kh,
    this.temperatureCelsius,
  });

  final String id;
  final String aquariumId;
  final DateTime recordedAt;
  final double? ph;
  final double? no3;
  final double? po4;
  final double? fe;
  final double? gh;
  final double? kh;
  final double? temperatureCelsius;

  Map<String, dynamic> toMap() => {
    'id': id,
    'aquariumId': aquariumId,
    'recordedAt': recordedAt.toIso8601String(),
    'ph': ph,
    'no3': no3,
    'po4': po4,
    'fe': fe,
    'gh': gh,
    'kh': kh,
    'temperatureCelsius': temperatureCelsius,
  };

  factory WaterTestModel.fromMap(Map<String, dynamic> map) {
    double? number(String key) => (map[key] as num?)?.toDouble();

    return WaterTestModel(
      id: map['id'] as String,
      aquariumId: map['aquariumId'] as String,
      recordedAt: DateTime.parse(map['recordedAt'] as String),
      ph: number('ph'),
      no3: number('no3'),
      po4: number('po4'),
      fe: number('fe'),
      gh: number('gh'),
      kh: number('kh'),
      temperatureCelsius: number('temperatureCelsius'),
    );
  }
}
