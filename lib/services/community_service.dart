import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

import '../models/community_models.dart';

class CommunityServiceException implements Exception {
  const CommunityServiceException(this.message);
  final String message;
  @override
  String toString() => message;
}

class CommunityService {
  CommunityService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  User get _user {
    final user = _auth.currentUser;
    if (user == null) {
      throw const CommunityServiceException('Zaloguj się, aby używać galerii.');
    }
    return user;
  }

  Stream<List<CommunityPost>> watchPosts() {
    _user;
    return _firestore
        .collection('community_posts')
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((document) => CommunityPost.fromFirestore(document))
              .toList(growable: false),
        );
  }

  Stream<List<CommunityAnswer>> watchAnswers(String postId) => _firestore
      .collection('community_posts')
      .doc(postId)
      .collection('answers')
      .orderBy('createdAt')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(CommunityAnswer.fromFirestore)
            .toList(growable: false),
      );

  Stream<Set<String>> watchBlockedUserIds() {
    final uid = _user.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map(
          (snapshot) =>
              (snapshot.data()?['blockedUserIds'] as List? ?? const [])
                  .whereType<String>()
                  .toSet(),
        );
  }

  Future<String?> createPost({
    required CommunityPostType type,
    required String title,
    required String description,
    required Uint8List? imageBytes,
    required CommunityTankSnapshot? tankSnapshot,
  }) async {
    final user = _user;
    final cleanTitle = title.trim();
    final cleanDescription = description.trim();
    if (cleanTitle.isEmpty || cleanTitle.length > 80) {
      throw const CommunityServiceException(
        'Tytuł musi mieć od 1 do 80 znaków.',
      );
    }
    if (cleanDescription.isEmpty || cleanDescription.length > 400) {
      throw const CommunityServiceException(
        'Opis musi mieć od 1 do 400 znaków.',
      );
    }
    String? imageUrl;
    if (imageBytes != null) {
      final compressed = compressCommunityImage(imageBytes);
      final fileId =
          '${DateTime.now().microsecondsSinceEpoch}-${type.name}.jpg';
      final reference = _storage.ref('community/${user.uid}/$fileId');
      await reference.putData(
        compressed,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      imageUrl = await reference.getDownloadURL();
    }
    if (type == CommunityPostType.showcase && imageUrl == null) {
      throw const CommunityServiceException('Pokaz akwarium wymaga zdjęcia.');
    }
    final reference = _firestore.collection('community_posts').doc();
    await reference.set({
      'type': type.name,
      'authorId': user.uid,
      'authorName': displayNameFor(user),
      'title': cleanTitle,
      'description': cleanDescription,
      'imageUrl': imageUrl,
      'tankSnapshot': tankSnapshot?.toMap(),
      'aiFirstAnswer': type == CommunityPostType.question
          ? _safeFirstAnswer(cleanDescription)
          : null,
      'reactions': {'heart': 0, 'plant': 0, 'fish': 0},
      'reactedBy': <String, String>{},
      'answersCount': 0,
      'lastAnswerId': '',
      'status': 'published',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return reference.id;
  }

  Future<void> addAnswer(String postId, String text) async {
    final user = _user;
    final clean = text.trim();
    if (clean.isEmpty || clean.length > 300) {
      throw const CommunityServiceException(
        'Odpowiedź musi mieć od 1 do 300 znaków.',
      );
    }
    final post = _firestore.collection('community_posts').doc(postId);
    final answer = post.collection('answers').doc();
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(post);
      if (!snapshot.exists) {
        throw const CommunityServiceException('Post nie istnieje.');
      }
      transaction.set(answer, {
        'authorId': user.uid,
        'authorName': displayNameFor(user),
        'text': clean,
        'isAi': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.update(post, {
        'answersCount':
            ((snapshot.data()?['answersCount'] as num?)?.toInt() ?? 0) + 1,
        'lastAnswerId': answer.id,
      });
    });
  }

  Future<void> react(String postId, CommunityReaction reaction) async {
    final uid = _user.uid;
    final reference = _firestore.collection('community_posts').doc(postId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (!snapshot.exists) return;
      final data = snapshot.data() ?? const <String, dynamic>{};
      final reactions = Map<String, dynamic>.from(
        data['reactions'] as Map? ?? const <String, dynamic>{},
      );
      final reactedBy = Map<String, dynamic>.from(
        data['reactedBy'] as Map? ?? const <String, dynamic>{},
      );
      final previousName = reactedBy[uid] as String?;
      if (previousName != null && previousName.isNotEmpty) {
        reactions[previousName] =
            ((reactions[previousName] as num?)?.toInt() ?? 1) - 1;
      }
      if (previousName == reaction.name) {
        reactedBy.remove(uid);
      } else {
        reactions[reaction.name] =
            ((reactions[reaction.name] as num?)?.toInt() ?? 0) + 1;
        reactedBy[uid] = reaction.name;
      }
      for (final key in CommunityReaction.values.map((item) => item.name)) {
        reactions[key] = ((reactions[key] as num?)?.toInt() ?? 0).clamp(
          0,
          1 << 30,
        );
      }
      transaction.update(reference, {
        'reactions': reactions,
        'reactedBy': reactedBy,
      });
    });
  }

  Future<void> report({
    required String targetType,
    required String targetId,
    required String postId,
    required String reason,
  }) async {
    final user = _user;
    await _firestore.collection('reports').add({
      'targetType': targetType,
      'targetId': targetId,
      'postId': postId,
      'reportedBy': user.uid,
      'reason': reason.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> blockUser(String blockedUserId) async {
    final uid = _user.uid;
    if (blockedUserId == uid) return;
    await _firestore.collection('users').doc(uid).set({
      'blockedUserIds': FieldValue.arrayUnion([blockedUserId]),
    }, SetOptions(merge: true));
  }

  static String displayNameFor(User user) {
    final display = user.displayName?.trim() ?? '';
    if (display.isNotEmpty) {
      return display.length > 40 ? display.substring(0, 40) : display;
    }
    return 'Akwarysta';
  }

  static Uint8List compressCommunityImage(Uint8List input) {
    final decoded = img.decodeImage(input);
    if (decoded == null) {
      throw const CommunityServiceException('Nie udało się odczytać zdjęcia.');
    }
    var resized = decoded;
    if (decoded.width > 1080 || decoded.height > 1080) {
      resized = img.copyResize(
        decoded,
        width: decoded.width >= decoded.height ? 1080 : null,
        height: decoded.height > decoded.width ? 1080 : null,
      );
    }
    var quality = 85;
    late Uint8List result;
    do {
      result = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
      quality -= 7;
    } while (result.length > 250 * 1024 && quality >= 45);
    if (result.length > 2 * 1024 * 1024) {
      throw const CommunityServiceException('Zdjęcie jest za duże.');
    }
    return result;
  }

  String _safeFirstAnswer(String description) {
    final lower = description.toLowerCase();
    if (lower.contains('no2') || lower.contains('azotyn')) {
      return 'Sprawdź ponownie NO2 i amoniak, ogranicz dokarmianie i przygotuj częściową podmianę uzdatnionej wody. Nie stosuj kilku zmian naraz.';
    }
    if (lower.contains('glon') || lower.contains('alga')) {
      return 'Zacznij od stabilnego światła, regularnych podmian i kontroli NO3/PO4. Nie zmieniaj wszystkich parametrów naraz.';
    }
    return 'Dodaj ostatnie wartości pH, NO2/NO3, temperaturę i objętość akwarium. Zmiany wprowadzaj stopniowo i obserwuj reakcję obsady.';
  }
}
