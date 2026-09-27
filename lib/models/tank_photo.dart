import 'package:cloud_firestore/cloud_firestore.dart';

class TankPhoto {
  const TankPhoto({
    required this.id,
    required this.tankId,
    required this.photoUrl,
    required this.storagePath,
    required this.caption,
    required this.createdAt,
    this.isCoverPhoto = false,
  });

  final String id;
  final String tankId;
  final String photoUrl;
  final String storagePath;
  final String caption;
  final DateTime createdAt;
  final bool isCoverPhoto;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'tankId': tankId,
        'photoUrl': photoUrl,
        'storagePath': storagePath,
        'caption': caption,
        'createdAt': Timestamp.fromDate(createdAt),
        'isCoverPhoto': isCoverPhoto,
      };

  factory TankPhoto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return TankPhoto(
      id: _string(data['id'], snapshot.id),
      tankId: _string(data['tankId']),
      photoUrl: _string(data['photoUrl']),
      storagePath: _string(data['storagePath']),
      caption: _string(data['caption']),
      createdAt: _date(data['createdAt']) ?? DateTime.now(),
      isCoverPhoto: data['isCoverPhoto'] as bool? ?? false,
    );
  }
}

String _string(Object? value, [String fallback = '']) =>
    value is String ? value : fallback;

DateTime? _date(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}