import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:akwarium/l10n/app_localizations.dart';
import 'package:akwarium/models/community_models.dart';
import 'package:akwarium/screens/community_screen.dart';
import 'package:akwarium/services/community_service.dart';

void main() {
  test('community filtering hides blocked users and respects post type', () {
    final showcase = _post('showcase', 'user-a', CommunityPostType.showcase);
    final question = _post('question', 'user-b', CommunityPostType.question);

    expect(
      filterCommunityPosts(
        [showcase, question],
        {'user-b'},
        CommunityPostFilter.all,
      ),
      [showcase],
    );
    expect(
      filterCommunityPosts(
        [showcase, question],
        const {},
        CommunityPostFilter.question,
      ),
      [question],
    );
  });

  test('community reaction mapping keeps one reaction per account', () {
    final post = _post(
      'post',
      'author',
      CommunityPostType.showcase,
    ).copyReactions({'author': CommunityReaction.plant});

    expect(post.reactionFor('author'), CommunityReaction.plant);
    expect(post.reactionFor('other'), isNull);
  });

  test('community image compression limits dimensions and file size', () {
    final image = img.Image(width: 2400, height: 1600);
    img.fill(image, color: img.ColorRgb8(24, 120, 110));
    final source = Uint8List.fromList(img.encodePng(image));

    final compressed = CommunityService.compressCommunityImage(source);
    final decoded = img.decodeImage(compressed)!;

    expect(decoded.width, lessThanOrEqualTo(1080));
    expect(decoded.height, lessThanOrEqualTo(1080));
    expect(compressed.length, lessThanOrEqualTo(250 * 1024));
  });

  testWidgets('showcase publish form prefills aquarium snapshot', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: CommunityPublishDialog(
            initialSnapshot: CommunityTankSnapshot(
              litersNet: 230,
              waterType: 'Słodkowodne',
              ageDays: 57,
              speciesCount: 5,
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('230 l'), findsOneWidget);
    expect(find.byType(SegmentedButton<CommunityPostType>), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

CommunityPost _post(String id, String authorId, CommunityPostType type) =>
    CommunityPost(
      id: id,
      type: type,
      authorId: authorId,
      authorName: authorId,
      title: id,
      description: 'Opis',
      imageUrl: type == CommunityPostType.showcase
          ? 'https://example/image'
          : null,
      tankSnapshot: type == CommunityPostType.showcase
          ? const CommunityTankSnapshot(
              litersNet: 100,
              waterType: 'freshwater',
              ageDays: 30,
              speciesCount: 3,
            )
          : null,
      aiFirstAnswer: null,
      reactions: const {
        CommunityReaction.heart: 0,
        CommunityReaction.plant: 0,
        CommunityReaction.fish: 0,
      },
      userReactions: const {},
      answersCount: 0,
      createdAt: DateTime(2026, 1, 1),
    );

extension on CommunityPost {
  CommunityPost copyReactions(Map<String, CommunityReaction> reactions) =>
      CommunityPost(
        id: id,
        type: type,
        authorId: authorId,
        authorName: authorName,
        title: title,
        description: description,
        imageUrl: imageUrl,
        tankSnapshot: tankSnapshot,
        aiFirstAnswer: aiFirstAnswer,
        reactions: this.reactions,
        userReactions: reactions,
        answersCount: answersCount,
        createdAt: createdAt,
      );
}
