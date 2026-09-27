import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

Future<void> uploadTankPhotoBytes({
  required Reference reference,
  required Uint8List bytes,
  required String? filePath,
  required SettableMetadata metadata,
}) async {
  await reference.putData(bytes, metadata);
}
