import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/app_localizations.dart';
import '../models/community_models.dart';
import '../services/community_service.dart';
import '../utils/app_snackbar.dart';

enum _CommunityFilter { all, showcases, questions }

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key, this.initialSnapshot});

  final CommunityTankSnapshot? initialSnapshot;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  CommunityService? _service;
  _CommunityFilter _filter = _CommunityFilter.all;

  CommunityService get service => _service ??= CommunityService();

  @override
  void initState() {
    super.initState();
    if (widget.initialSnapshot != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openPublish());
    }
  }

  Future<void> _openPublish() async {
    final published = await showDialog<bool>(
      context: context,
      builder: (_) =>
          CommunityPublishDialog(initialSnapshot: widget.initialSnapshot),
    );
    if (published == true && mounted) {
      context.showAppSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.communityPublished),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.communityTitle),
        actions: [
          IconButton(
            tooltip: l10n.communityPublish,
            onPressed: _openPublish,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: StreamBuilder<Set<String>>(
            stream: service.watchBlockedUserIds(),
            initialData: const <String>{},
            builder: (context, blockedSnapshot) {
              final blocked = blockedSnapshot.data ?? const <String>{};
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: SegmentedButton<_CommunityFilter>(
                      showSelectedIcon: false,
                      selected: {_filter},
                      onSelectionChanged: (selection) =>
                          setState(() => _filter = selection.first),
                      segments: [
                        ButtonSegment(
                          value: _CommunityFilter.all,
                          label: Text(l10n.communityAll),
                        ),
                        ButtonSegment(
                          value: _CommunityFilter.showcases,
                          label: Text(l10n.communityAquariums),
                        ),
                        ButtonSegment(
                          value: _CommunityFilter.questions,
                          label: Text(l10n.communityTips),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<CommunityPost>>(
                      stream: service.watchPosts(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text(l10n.communityLoadError));
                        }
                        final filter = switch (_filter) {
                          _CommunityFilter.all => CommunityPostFilter.all,
                          _CommunityFilter.showcases =>
                            CommunityPostFilter.showcase,
                          _CommunityFilter.questions =>
                            CommunityPostFilter.question,
                        };
                        final posts = filterCommunityPosts(
                          snapshot.data ?? const <CommunityPost>[],
                          blocked,
                          filter,
                        ).toList(growable: false);
                        if (posts.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(28),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.forum_outlined, size: 52),
                                  const SizedBox(height: 12),
                                  Text(
                                    l10n.communityEmpty,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 14),
                                  FilledButton.icon(
                                    onPressed: _openPublish,
                                    icon: const Icon(Icons.add),
                                    label: Text(l10n.communityPublish),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                          itemCount: posts.length,
                          itemBuilder: (context, index) => _CommunityPostCard(
                            post: posts[index],
                            blockedUserIds: blocked,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({required this.post, required this.blockedUserIds});

  final CommunityPost post;
  final Set<String> blockedUserIds;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final service = CommunityService();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final selected = post.reactionFor(currentUserId);
    final snapshot = post.tankSnapshot;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    post.authorName.isEmpty
                        ? '?'
                        : post.authorName.substring(0, 1).toUpperCase(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        post.type == CommunityPostType.showcase
                            ? l10n.communityAquarium
                            : l10n.communityQuestion,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (action) async {
                    if (action == 'report') {
                      await _reportPost(context, service);
                    } else if (action == 'block' &&
                        post.authorId != currentUserId) {
                      await service.blockUser(post.authorId);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'report',
                      child: Text(l10n.communityReportContent),
                    ),
                    if (post.authorId != currentUserId)
                      PopupMenuItem(
                        value: 'block',
                        child: Text(l10n.communityHideUser),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(post.description),
            if (post.imageUrl case final imageUrl?) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (_, _, _) => Container(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (snapshot != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer
                      .withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${snapshot.litersNet.toStringAsFixed(0)} l · '
                  '${snapshot.waterType} · ${snapshot.ageDays} ${l10n.daysUnit} '
                  '· ${snapshot.speciesCount} ${l10n.speciesCount.toLowerCase()}',
                ),
              ),
            ],
            if (post.type == CommunityPostType.showcase) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CommunityReaction.values.map((reaction) {
                  final active = selected == reaction;
                  return ActionChip(
                    avatar: Icon(
                      switch (reaction) {
                        CommunityReaction.heart => Icons.favorite_outline,
                        CommunityReaction.plant => Icons.eco_outlined,
                        CommunityReaction.fish => Icons.set_meal_outlined,
                      },
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    label: Text('${post.reactions[reaction] ?? 0}'),
                    side: active
                        ? BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onPressed: () => service.react(post.id, reaction),
                  );
                }).toList(),
              ),
            ],
            if (post.type == CommunityPostType.question) ...[
              if (post.aiFirstAnswer?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 12),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(l10n.communityAiHint),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(post.aiFirstAnswer!),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              _CommunityAnswers(post: post, blockedUserIds: blockedUserIds),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _reportPost(
    BuildContext context,
    CommunityService service,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.communityReportReason),
        children: [
          for (final item in [
            l10n.communityReportSpam,
            l10n.communityReportHarmful,
            l10n.communityReportOther,
          ])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, item),
              child: Text(item),
            ),
        ],
      ),
    );
    if (reason == null) return;
    await service.report(
      targetType: 'post',
      targetId: post.id,
      postId: post.id,
      reason: reason,
    );
    if (context.mounted) {
      context.showAppSnackBar(
        SnackBar(content: Text(l10n.communityReportSent)),
      );
    }
  }
}

class _CommunityAnswers extends StatefulWidget {
  const _CommunityAnswers({required this.post, required this.blockedUserIds});
  final CommunityPost post;
  final Set<String> blockedUserIds;
  @override
  State<_CommunityAnswers> createState() => _CommunityAnswersState();
}

class _CommunityAnswersState extends State<_CommunityAnswers> {
  final _controller = TextEditingController();
  CommunityService? _service;
  bool _sending = false;

  CommunityService get service => _service ??= CommunityService();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<CommunityAnswer>>(
      stream: service.watchAnswers(widget.post.id),
      builder: (context, snapshot) {
        final answers = (snapshot.data ?? const <CommunityAnswer>[])
            .where((answer) => !widget.blockedUserIds.contains(answer.authorId))
            .toList(growable: false);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.communityAnswersCount(answers.length),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            ...answers.map(
              (answer) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(answer.text),
                subtitle: Text(answer.authorName),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) async {
                    if (action == 'report') {
                      final reason = await _answerReportReason(context);
                      if (reason != null) {
                        await service.report(
                          targetType: 'answer',
                          targetId: answer.id,
                          postId: widget.post.id,
                          reason: reason,
                        );
                      }
                    } else if (action == 'block') {
                      await service.blockUser(answer.authorId);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'report',
                      child: Text(l10n.communityReportContent),
                    ),
                    if (answer.authorId !=
                        FirebaseAuth.instance.currentUser?.uid)
                      PopupMenuItem(
                        value: 'block',
                        child: Text(l10n.communityHideUser),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLength: 300,
                    decoration: InputDecoration(
                      labelText: l10n.communityWriteAnswer,
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sending
                      ? null
                      : () async {
                          setState(() => _sending = true);
                          try {
                            await service.addAnswer(
                              widget.post.id,
                              _controller.text,
                            );
                            _controller.clear();
                          } on Object catch (error) {
                            if (context.mounted) {
                              context.showAppSnackBar(
                                SnackBar(content: Text(error.toString())),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _sending = false);
                          }
                        },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<String?> _answerReportReason(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.communityReportReason),
        children: [
          for (final reason in [
            l10n.communityReportSpam,
            l10n.communityReportHarmful,
            l10n.communityReportOther,
          ])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, reason),
              child: Text(reason),
            ),
        ],
      ),
    );
  }
}

class CommunityPublishDialog extends StatefulWidget {
  const CommunityPublishDialog({this.initialSnapshot, super.key});

  final CommunityTankSnapshot? initialSnapshot;

  @override
  State<CommunityPublishDialog> createState() => _CommunityPublishDialogState();
}

class _CommunityPublishDialogState extends State<CommunityPublishDialog> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _picker = ImagePicker();
  CommunityService? _service;
  CommunityPostType _type = CommunityPostType.showcase;
  Uint8List? _imageBytes;
  bool _saving = false;
  String? _error;

  CommunityService get service => _service ??= CommunityService();

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.communityPublish),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<CommunityPostType>(
            selected: {_type},
            onSelectionChanged: (selection) =>
                setState(() => _type = selection.first),
            segments: [
              ButtonSegment(
                value: CommunityPostType.showcase,
                label: Text(l10n.communityAquarium),
              ),
              ButtonSegment(
                value: CommunityPostType.question,
                label: Text(l10n.communityQuestion),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            maxLength: 80,
            decoration: InputDecoration(labelText: l10n.title),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _description,
            maxLength: 400,
            maxLines: 5,
            decoration: InputDecoration(labelText: l10n.descriptionLabel),
          ),
          const SizedBox(height: 10),
          if (_imageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(_imageBytes!, height: 150, fit: BoxFit.cover),
            ),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(
              _imageBytes == null
                  ? l10n.communityAddPhoto
                  : l10n.communityChangePhoto,
            ),
          ),
          if (widget.initialSnapshot != null) ...[
            const SizedBox(height: 10),
            Text(
              '${widget.initialSnapshot!.litersNet.toStringAsFixed(0)} l · '
              '${widget.initialSnapshot!.waterType}',
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _publish,
          child: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.communityPublish),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _imageBytes = bytes);
  }

  Future<void> _publish() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await service.createPost(
        type: _type,
        title: _title.text,
        description: _description.text,
        imageBytes: _imageBytes,
        tankSnapshot: widget.initialSnapshot,
      );
      if (mounted) Navigator.pop(context, true);
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
