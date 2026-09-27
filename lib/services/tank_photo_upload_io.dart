import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

Future<void> uploadTankPhotoBytes({
  required Reference reference,
  required Uint8List bytes,
  required String? filePath,
  required SettableMetadata metadata,
}) async {
  if (filePath != null && filePath.isNotEmpty) {
    await reference.putFile(File(filePath), metadata);
  } else {
    await reference.putData(bytes, metadata);
  }
}
