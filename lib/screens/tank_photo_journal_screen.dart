import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/tank_photo.dart';
import '../l10n/app_localizations.dart';
import '../services/database_service.dart';
import '../services/pro_access_service.dart';
import '../widgets/pro_paywall_dialog.dart';

class TankPhotoJournalScreen extends StatefulWidget {
  const TankPhotoJournalScreen({required this.tankId, super.key});

  final String tankId;

  @override
  State<TankPhotoJournalScreen> createState() => _TankPhotoJournalScreenState();
}

class _TankPhotoJournalScreenState extends State<TankPhotoJournalScreen> {
  final _database = DatabaseService();
  final _picker = ImagePicker();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Zaloguj się, aby zobaczyć zdjęcia.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.photoJournalTitle),
        actions: [
          IconButton(
            tooltip: 'Porównaj zdjęcia',
            onPressed: () => _openCompare(userId),
            icon: const Icon(Icons.compare_outlined),
          ),
        ],
      ),
      body: StreamBuilder<List<TankPhoto>>(
        stream: _database.getTankPhotosStream(userId, widget.tankId),
        builder: (context, snapshot) {
          final photos = snapshot.data ?? const <TankPhoto>[];
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError)
            return const Center(child: Text('Nie udało się wczytać zdjęć.'));
          if (photos.isEmpty) {
            return Center(
              child: Text(l10n.addFirstPhotoOfAquarium),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: FilledButton.icon(
                  onPressed: () => _openCompare(userId, photos),
                  icon: const Icon(Icons.compare_arrows_outlined),
                  label: const Text('Porównaj pierwsze i najnowsze zdjęcie'),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.86,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) => _PhotoTile(
                    photo: photos[index],
                    onTap: () => _showDetails(userId, photos[index]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPhoto(userId),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(l10n.addPhoto),
      ),
    );
  }

  Future<void> _addPhoto(String? userId) async {
    if (userId == null) return;
    try {
      final isProUser = context.read<ProAccessService>().isProUser;
      if (!isProUser) {
        final photos = await _database
            .getTankPhotosStream(userId, widget.tankId)
            .first;
        if (photos.length >= ProAccessService.freeTankPhotoLimit) {
          if (mounted) {
            await ProPaywallDialog.show(
              context,
              headline: 'Nielimitowany dziennik zdjęć',
            );
          }
          return;
        }
      }
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      final caption = await _captionDialog();
      if (caption == null || !mounted) return;
      final bytes = await file.readAsBytes();
      await _database.uploadTankPhoto(
        userId,
        widget.tankId,
        bytes,
        caption,
        localFilePath: kIsWeb ? null : file.path,
      );
      if (!mounted) return;
      _showPhotoMessage('Zdjęcie zostało zapisane.');
    } on Object catch (error) {
      if (mounted) _showPhotoMessage(_photoErrorMessage(error), isError: true);
    }
  }

  void _showPhotoMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
          content: Text(message),
        ),
      );
  }

  String _photoErrorMessage(Object error) {
    if (error is FirebaseException) {
      return 'FirebaseException (${error.code}): ${error.message ?? error.toString()}';
    }
    return error.toString();
  }

  Future<String?> _captionDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opis zdjęcia'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Opcjonalny opis'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _showDetails(String userId, TankPhoto photo) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InteractiveViewer(
                child: Image.network(photo.photoUrl, fit: BoxFit.contain),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (photo.caption.isNotEmpty) Text(photo.caption),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(photo.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            await _database.setCoverPhoto(
                              userId,
                              widget.tankId,
                              photo,
                            );
                            if (dialogContext.mounted)
                              Navigator.pop(dialogContext);
                          },
                          icon: const Icon(
                            Icons.photo_size_select_actual_outlined,
                          ),
                          label: Text(
                            photo.isCoverPhoto
                                ? 'Zdjęcie główne'
                                : 'Ustaw jako okładkę akwarium',
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () async {
                            await _database.deleteTankPhoto(
                              userId,
                              widget.tankId,
                              photo,
                            );
                            if (dialogContext.mounted)
                              Navigator.pop(dialogContext);
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Usuń'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCompare(
    String userId, [
    List<TankPhoto>? selectedPhotos,
  ]) async {
    final photos =
        selectedPhotos ??
        await _database.getTankPhotosStream(userId, widget.tankId).first;
    if (!mounted || photos.length < 2) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Potrzebujesz co najmniej dwóch zdjęć.'),
          ),
        );
      return;
    }
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => _CompareScreen(photos: photos)),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo, required this.onTap});
  final TankPhoto photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: Image.network(photo.photoUrl, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                if (photo.isCoverPhoto)
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    photo.caption.isEmpty
                        ? _formatDate(photo.createdAt)
                        : photo.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _CompareScreen extends StatefulWidget {
  const _CompareScreen({required this.photos});
  final List<TankPhoto> photos;
  @override
  State<_CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<_CompareScreen> {
  late TankPhoto _before = widget.photos[widget.photos.length - 1];
  late TankPhoto _after = widget.photos.first;
  double _split = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Porównaj postęp')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _photoChoice(
                  'Wtedy',
                  _before,
                  (photo) => setState(() => _before = photo),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _photoChoice(
                  'Teraz',
                  _after,
                  (photo) => setState(() => _after = photo),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(_after.photoUrl, fit: BoxFit.cover),
                  ClipRect(
                    clipper: _SplitClipper(_split),
                    child: Image.network(_before.photoUrl, fit: BoxFit.cover),
                  ),
                  Align(
                    alignment: Alignment(_split * 2 - 1, 0),
                    child: Container(width: 2, color: Colors.white),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _DateBadge(label: 'Teraz', date: _after.createdAt),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _DateBadge(label: 'Wtedy', date: _before.createdAt),
                  ),
                ],
              ),
            ),
          ),
          Slider(
            value: _split,
            onChanged: (value) => setState(() => _split = value),
          ),
          Text(
            '${_formatDate(_before.createdAt)}  →  ${_formatDate(_after.createdAt)}',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _photoChoice(
    String label,
    TankPhoto selected,
    ValueChanged<TankPhoto> onChanged,
  ) => DropdownButtonFormField<TankPhoto>(
    initialValue: selected,
    decoration: InputDecoration(labelText: label),
    isExpanded: true,
    items: widget.photos
        .map(
          (photo) => DropdownMenuItem(
            value: photo,
            child: Text(_formatDate(photo.createdAt)),
          ),
        )
        .toList(),
    onChanged: (photo) {
      if (photo != null) onChanged(photo);
    },
  );
}

class _SplitClipper extends CustomClipper<Rect> {
  const _SplitClipper(this.split);
  final double split;
  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * split, size.height);
  @override
  bool shouldReclip(_SplitClipper oldClipper) => oldClipper.split != split;
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.label, required this.date});

  final String label;
  final DateTime date;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.68),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        '$label: ${_formatDate(date)}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
