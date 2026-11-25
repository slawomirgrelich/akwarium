import 'package:cloud_firestore/cloud_firestore.dart';

enum CommunityPostType { showcase, question }

enum CommunityReaction { heart, plant, fish }

enum CommunityPostFilter { all, showcase, question }

Iterable<CommunityPost> filterCommunityPosts(
  Iterable<CommunityPost> posts,
  Set<String> blockedUserIds,
  CommunityPostFilter filter,
) => posts.where((post) {
  if (blockedUserIds.contains(post.authorId)) return false;
  return switch (filter) {
    CommunityPostFilter.all => true,
    CommunityPostFilter.showcase => post.type == CommunityPostType.showcase,
    CommunityPostFilter.question => post.type == CommunityPostType.question,
  };
});

class CommunityTankSnapshot {
  const CommunityTankSnapshot({
    required this.litersNet,
    required this.waterType,
    required this.ageDays,
    required this.speciesCount,
  });

  final double litersNet;
  final String waterType;
  final int ageDays;
  final int speciesCount;

  Map<String, dynamic> toMap() => {
    'litersNet': litersNet,
    'waterType': waterType,
    'ageDays': ageDays,
    'speciesCount': speciesCount,
  };

  factory CommunityTankSnapshot.fromMap(Object? value) {
    final map = value is Map
        ? Map<String, dynamic>.from(value)
        : const <String, dynamic>{};
    return CommunityTankSnapshot(
      litersNet: (map['litersNet'] as num?)?.toDouble() ?? 0,
      waterType: map['waterType'] as String? ?? '',
      ageDays: (map['ageDays'] as num?)?.toInt() ?? 0,
      speciesCount: (map['speciesCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.type,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.tankSnapshot,
    required this.aiFirstAnswer,
    required this.reactions,
    required this.userReactions,
    required this.answersCount,
    required this.createdAt,
  });

  final String id;
  final CommunityPostType type;
  final String authorId;
  final String authorName;
  final String title;
  final String description;
  final String? imageUrl;
  final CommunityTankSnapshot? tankSnapshot;
  final String? aiFirstAnswer;
  final Map<CommunityReaction, int> reactions;
  final Map<String, CommunityReaction> userReactions;
  final int answersCount;
  final DateTime createdAt;

  CommunityReaction? reactionFor(String userId) => userReactions[userId];

  factory CommunityPost.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final reactions = (data['reactions'] as Map?) ?? const <String, dynamic>{};
    final reactedBy = (data['reactedBy'] as Map?) ?? const <String, dynamic>{};
    final parsedReactions = <String, CommunityReaction>{};
    for (final entry in reactedBy.entries) {
      final reaction = _reaction(entry.value);
      if (reaction != null) parsedReactions[entry.key.toString()] = reaction;
    }
    return CommunityPost(
      id: snapshot.id,
      type: data['type'] == 'question'
          ? CommunityPostType.question
          : CommunityPostType.showcase,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      tankSnapshot: data['tankSnapshot'] == null
          ? null
          : CommunityTankSnapshot.fromMap(data['tankSnapshot']),
      aiFirstAnswer: data['aiFirstAnswer'] as String?,
      reactions: {
        for (final reaction in CommunityReaction.values)
          reaction: (reactions[reaction.name] as num?)?.toInt() ?? 0,
      },
      userReactions: parsedReactions,
      answersCount: (data['answersCount'] as num?)?.toInt() ?? 0,
      createdAt: _date(data['createdAt']) ?? DateTime.now(),
    );
  }
}

class CommunityAnswer {
  const CommunityAnswer({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.isAi,
    required this.createdAt,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final bool isAi;
  final DateTime createdAt;

  factory CommunityAnswer.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return CommunityAnswer(
      id: snapshot.id,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      isAi: data['isAi'] == true,
      createdAt: _date(data['createdAt']) ?? DateTime.now(),
    );
  }
}

CommunityReaction? _reaction(Object? value) {
  for (final reaction in CommunityReaction.values) {
    if (reaction.name == value) return reaction;
  }
  return null;
}

DateTime? _date(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
