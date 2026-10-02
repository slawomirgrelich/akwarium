import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../data/species_catalog.dart';
import '../data/species_catalog_en.dart';
import '../l10n/app_localizations.dart';
import '../models/aquarium_firestore_model.dart';
import '../models/aquarium_model.dart' as local_models;
import '../models/species_models.dart';
import '../services/compatibility_checker.dart';
import '../services/firestore_service.dart';
import '../services/species_image_service.dart';
import 'aquarium_livestock_screen.dart';

class SpeciesAtlasScreen extends StatefulWidget {
  const SpeciesAtlasScreen({
    required this.tankId,
    this.onCreateAquarium,
    super.key,
  });

  final String tankId;
  final VoidCallback? onCreateAquarium;

  @override
  State<SpeciesAtlasScreen> createState() => _SpeciesAtlasScreenState();
}

class _SpeciesAtlasScreenState extends State<SpeciesAtlasScreen> {
  final _search = TextEditingController();
  SpeciesCategory? _category;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = _search.text.trim().toLowerCase();
    final filtered = speciesCatalog.where((species) {
      final matchesQuery =
          query.isEmpty ||
          '${_localizedSpeciesName(context, species)} ${species.namePl} ${species.nameLatin}'
              .toLowerCase()
              .contains(query);
      return matchesQuery &&
          (_category == null || species.category == _category);
    }).toList();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.speciesAtlasTitle)),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: l10n.searchSpeciesLabel,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _filterChip(l10n.filterAll, null),
              _filterChip(l10n.filterFish, SpeciesCategory.fish),
              _filterChip(l10n.filterPlants, SpeciesCategory.plant),
              _filterChip(
                l10n.filterInvertebrates,
                SpeciesCategory.invertebrate,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...filtered.map(
            (species) => Card(
              child: ListTile(
                leading: _SpeciesThumbnail(species: species, size: 48),
                title: Text(_localizedSpeciesName(context, species)),
                subtitle: Text(
                  '${species.nameLatin} · ${l10n.speciesMinimumVolumeFrom(species.minTankVolumeLiters)}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showDetails(species),
              ),
            ),
          ),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(l10n.noSpeciesFound)),
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, SpeciesCategory? category) => FilterChip(
    label: Text(label),
    selected: _category == category,
    onSelected: (_) => setState(() => _category = category),
  );

  Future<void> _showDetails(Species species) async {
    final l10n = AppLocalizations.of(context)!;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showAtlasMessage(context, l10n.loginToAddSpecies, isError: true);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_localizedSpeciesName(context, species)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: _SpeciesThumbnail(
                  species: species,
                  size: 140,
                  showAttribution: true,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                species.nameLatin,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              Text(
                _localizedSpeciesText(context, species, species.description),
              ),
              const SizedBox(height: 16),
              if (species.careNotes?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.careNotesLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _localizedSpeciesText(
                    context,
                    species,
                    species.careNotes!.trim(),
                    careNotes: true,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(l10n.minTankVolumeLabel(species.minTankVolumeLiters)),
              Text(
                l10n.temperatureRangeLabel(
                  species.tempRange.min,
                  species.tempRange.max,
                ),
              ),
              Text(l10n.phRangeLabel(species.phRange.min, species.phRange.max)),
              Text(l10n.ghRangeLabel(species.ghRange.min, species.ghRange.max)),
              Text(
                l10n.difficultyLabel(
                  _difficultyLabel(context, species.difficulty),
                ),
              ),
              Text(
                l10n.swimmingZoneLabel(
                  _zoneLabel(context, species.swimmingZone),
                ),
              ),
              const SizedBox(height: 16),
              _CompatibilitySection(species: species),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              _addSpeciesToAquarium(context, species);
            },
            icon: const Icon(Icons.water_drop_outlined),
            label: Text(l10n.addToMyAquarium),
          ),
        ],
      ),
    );
  }

  Future<void> _addSpeciesToAquarium(
    BuildContext pageContext,
    Species species,
  ) async {
    final firestore = FirestoreService();
    try {
      final aquariums = await _loadAquariums(firestore);
      if (!pageContext.mounted) return;
      final selection = aquariums.length == 1
          ? _AquariumPickerResult.select(aquariums.single)
          : await showModalBottomSheet<_AquariumPickerResult>(
              context: pageContext,
              showDragHandle: true,
              builder: (_) => _AquariumSelectionSheet(
                aquariums: aquariums,
                onCreateAquarium: widget.onCreateAquarium != null,
              ),
            );
      if (selection == null || !pageContext.mounted) return;
      if (selection.create) {
        if (widget.onCreateAquarium != null) {
          widget.onCreateAquarium!();
        } else {
          ScaffoldMessenger.of(pageContext).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              showCloseIcon: true,
              content: Text(
                AppLocalizations.of(pageContext)!
                    .openManagementToCreateAquarium,
              ),
            ),
          );
        }
        return;
      }
      final selectedAquarium = selection.aquarium!;
      final aquarium = selectedAquarium.aquarium;
      if (!selectedAquarium.isStoredInFirestore) {
        await firestore.addAquarium(aquarium);
      }
      if (!pageContext.mounted) return;

      final addition = await showDialog<_SpeciesAddition>(
        context: pageContext,
        builder: (_) => _SpeciesAdditionDialog(species: species),
      );
      if (addition == null || !pageContext.mounted) return;

      await firestore.addLivestockItem(
        aquarium.id,
        namePl: species.namePl,
        nameLatin: species.nameLatin,
        category: _categoryLabel(species.category),
        count: addition.count,
        phRange: '${species.phRange.min} - ${species.phRange.max}',
        tempRange: '${species.tempRange.min} - ${species.tempRange.max} °C',
        minTankVolume: species.minTankVolumeLiters,
        addedAt: addition.addedAt,
        notes: addition.notes,
      );
      if (!pageContext.mounted) return;
      final messenger = ScaffoldMessenger.of(pageContext);
      messenger.hideCurrentSnackBar();
      final pageL10n = AppLocalizations.of(pageContext)!;
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          showCloseIcon: true,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          content: Text(
            pageL10n.addedSpeciesToAquarium(
              _localizedSpeciesName(pageContext, species),
              aquarium.name,
            ),
          ),
          action: SnackBarAction(
            label: pageL10n.viewLivestock,
            onPressed: () => Navigator.of(pageContext).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => AquariumLivestockScreen(aquarium: aquarium),
              ),
            ),
          ),
        ),
      );
    } on FirestoreServiceException catch (error) {
      if (pageContext.mounted) {
        _showAtlasMessage(pageContext, error.message, isError: true);
      }
    } on FirebaseException catch (error) {
      if (pageContext.mounted) {
        _showAtlasMessage(
          pageContext,
          'FirebaseException (${error.code}): ${error.message ?? error.toString()}',
          isError: true,
        );
      }
    } catch (error) {
      if (pageContext.mounted) {
        _showAtlasMessage(pageContext, error.toString(), isError: true);
      }
    }
  }

  Future<List<_AquariumOption>> _loadAquariums(
    FirestoreService firestore,
  ) async {
    final provider = context.read<local_models.AquariumProvider>();
    final localAquariums = provider.aquariums;
    final providerAquariumId = provider.activeAquariumId.trim();
    final activeAquariumId = providerAquariumId.isNotEmpty
        ? providerAquariumId
        : widget.tankId.trim();
    final options = <String, _AquariumOption>{};
    try {
      final cloudAquariums = await firestore.getAquariums().first;
      for (final aquarium in cloudAquariums) {
        options[aquarium.id] = _AquariumOption(
          aquarium: aquarium,
          isStoredInFirestore: true,
        );
      }
    } on FirestoreServiceException {
      if (localAquariums.isEmpty) rethrow;
    }
    for (final aquarium in localAquariums) {
      options.putIfAbsent(
        aquarium.id,
        () => _AquariumOption(
          aquarium: AquariumModel(
            id: aquarium.id,
            name: aquarium.name,
            capacityLiters: aquarium.volumeNetLiters,
            setupDate: aquarium.setupDate,
            type: aquarium.type.label,
          ),
          isStoredInFirestore: false,
        ),
      );
    }
    final result = options.values.toList();
    result.sort((first, second) {
      if (first.aquarium.id == activeAquariumId) return -1;
      if (second.aquarium.id == activeAquariumId) return 1;
      return 0;
    });
    return result;
  }
}

void _showAtlasMessage(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        showCloseIcon: true,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        content: Text(message),
      ),
    );
}

class _AquariumSelectionSheet extends StatelessWidget {
  const _AquariumSelectionSheet({
    required this.aquariums,
    required this.onCreateAquarium,
  });

  final List<_AquariumOption> aquariums;
  final bool onCreateAquarium;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.chooseAquarium,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (aquariums.isEmpty) ...[
            const Icon(Icons.water_drop_outlined, size: 36),
            const SizedBox(height: 12),
            Text(l10n.noAquariumYet, textAlign: TextAlign.center),
            if (onCreateAquarium) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.pop(
                  context,
                  const _AquariumPickerResult.create(),
                ),
                icon: const Icon(Icons.add),
                label: Text(l10n.createAquariumAction),
              ),
            ],
          ] else ...[
            ...aquariums.map(
              (option) => ListTile(
                leading: const Icon(Icons.water_drop_outlined),
                title: Text(option.aquarium.name),
                subtitle: Text(
                  '${option.aquarium.capacityLiters.round()} l · ${option.aquarium.type}',
                ),
                onTap: () => Navigator.pop(
                  context,
                  _AquariumPickerResult.select(option),
                ),
              ),
            ),
            if (onCreateAquarium)
              TextButton.icon(
                onPressed: () => Navigator.pop(
                  context,
                  const _AquariumPickerResult.create(),
                ),
                icon: const Icon(Icons.add),
                label: Text(l10n.createNewAquariumAction),
              ),
          ],
        ],
      ),
    );
  }
}

/// Sekcja pokazująca wynik walidacji kompatybilności gatunku z aktywnym akwarium.
class _CompatibilitySection extends StatelessWidget {
  const _CompatibilitySection({required this.species});

  final Species species;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<local_models.AquariumProvider>();
    final aquarium = provider.selectedAquarium;
    if (aquarium == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<WaterParametersModel>>(
      stream: FirestoreService().getWaterParameters(aquarium.id),
      builder: (context, snapshot) {
        final latest = snapshot.data?.firstOrNull;
        final result = checkCompatibility(
          species: species,
          volumeLiters: aquarium.volumeNetLiters,
          ph: latest?.ph,
          temperature: latest?.temp,
        );
        final theme = Theme.of(context);
        final color = result.isCompatible
            ? theme.colorScheme.primary
            : theme.colorScheme.error;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    result.isCompatible
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_outlined,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.isCompatible
                          ? AppLocalizations.of(context)!
                                .compatibleWithAquarium(aquarium.name)
                          : AppLocalizations.of(context)!
                                .warningsForAquarium(aquarium.name),
                      style: theme.textTheme.titleSmall?.copyWith(color: color),
                    ),
                  ),
                ],
              ),
              for (final warning in result.warningTypes) ...[
                const SizedBox(height: 6),
                Text(
                  '• ${_compatibilityWarningText(AppLocalizations.of(context)!, warning, species, aquarium.volumeNetLiters, latest?.ph, latest?.temp)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AquariumOption {
  const _AquariumOption({
    required this.aquarium,
    required this.isStoredInFirestore,
  });

  final AquariumModel aquarium;
  final bool isStoredInFirestore;
}

String _compatibilityWarningText(
  AppLocalizations l10n,
  CompatibilityWarningType warning,
  Species species,
  double volumeLiters,
  double? ph,
  double? temperature,
) => switch (warning) {
  CompatibilityWarningType.volume => l10n.compatibilityVolumeWarning(
    volumeLiters.round(),
    species.minTankVolumeLiters,
  ),
  CompatibilityWarningType.ph => l10n.compatibilityPhWarning(
    ph!,
    species.phRange.min,
    species.phRange.max,
  ),
  CompatibilityWarningType.temperature => l10n.compatibilityTemperatureWarning(
    temperature!,
    species.tempRange.min,
    species.tempRange.max,
  ),
};

class _AquariumPickerResult {
  const _AquariumPickerResult.select(this.aquarium) : create = false;
  const _AquariumPickerResult.create() : aquarium = null, create = true;

  final _AquariumOption? aquarium;
  final bool create;
}

class _SpeciesAddition {
  const _SpeciesAddition({
    required this.count,
    required this.addedAt,
    required this.notes,
  });

  final int count;
  final DateTime addedAt;
  final String notes;
}

class _SpeciesAdditionDialog extends StatefulWidget {
  const _SpeciesAdditionDialog({required this.species});

  final Species species;

  @override
  State<_SpeciesAdditionDialog> createState() => _SpeciesAdditionDialogState();
}

class _SpeciesAdditionDialogState extends State<_SpeciesAdditionDialog> {
  final _notesController = TextEditingController();
  int _count = 1;
  DateTime _addedAt = DateTime.now();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        l10n.addSpeciesDialogTitle(
          _localizedSpeciesName(context, widget.species),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _count > 1 ? () => setState(() => _count--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_count', style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  onPressed: () => setState(() => _count++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(l10n.additionDateLabel),
              subtitle: Text(_formatAdditionDate(_addedAt)),
              onTap: _pickDate,
            ),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.notesOptionalLabel,
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _SpeciesAddition(
              count: _count,
              addedAt: _addedAt,
              notes: _notesController.text.trim(),
            ),
          ),
          child: Text(l10n.save),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _addedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (selected != null) {
      setState(() {
        _addedAt = DateTime(
          selected.year,
          selected.month,
          selected.day,
          _addedAt.hour,
          _addedAt.minute,
        );
      });
    }
  }
}

/// Returns the English description/care-notes text when the app language is
/// English and a translation exists, otherwise falls back to the Polish text.
String _localizedSpeciesText(
  BuildContext context,
  Species species,
  String plText, {
  bool careNotes = false,
}) {
  if (Localizations.localeOf(context).languageCode != 'en') {
    return plText;
  }
  if (careNotes) return speciesCareNotesEn[species.id] ?? plText;
  return speciesDescriptionsEn[species.id] ?? species.nameLatin;
}

String _localizedSpeciesName(BuildContext context, Species species) {
  if (Localizations.localeOf(context).languageCode != 'en') {
    return species.namePl;
  }
  return speciesNamesEn[species.id] ?? species.nameLatin;
}

String _categoryLabel(SpeciesCategory category) => switch (category) {
  SpeciesCategory.fish => 'Ryba',
  SpeciesCategory.plant => 'Roślina',
  SpeciesCategory.invertebrate => 'Bezkręgowiec',
};

String _formatAdditionDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

IconData _iconFor(SpeciesCategory category) => switch (category) {
  SpeciesCategory.fish => Icons.pets,
  SpeciesCategory.plant => Icons.local_florist,
  SpeciesCategory.invertebrate => Icons.bug_report_outlined,
};

class _SpeciesThumbnail extends StatefulWidget {
  const _SpeciesThumbnail({
    required this.species,
    required this.size,
    this.showAttribution = false,
  });

  final Species species;
  final double size;
  final bool showAttribution;

  @override
  State<_SpeciesThumbnail> createState() => _SpeciesThumbnailState();
}

class _SpeciesThumbnailState extends State<_SpeciesThumbnail> {
  late String _providedSource;
  late bool _showFallback;
  Future<SpeciesImageSource?>? _fallbackImage;

  @override
  void initState() {
    super.initState();
    _providedSource = widget.species.imageUrl.trim();
    _showFallback = _providedSource.isEmpty;
    if (_showFallback) _fallbackImage = _findFallbackImage();
  }

  @override
  void didUpdateWidget(covariant _SpeciesThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.species.id == widget.species.id) return;
    _providedSource = widget.species.imageUrl.trim();
    _showFallback = _providedSource.isEmpty;
    _fallbackImage = _showFallback ? _findFallbackImage() : null;
  }

  Future<SpeciesImageSource?> _findFallbackImage() =>
      speciesImageService.findByScientificName(widget.species.nameLatin);

  void _useFallbackAfterError() {
    if (_showFallback) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _showFallback) return;
      setState(() {
        _showFallback = true;
        _fallbackImage = _findFallbackImage();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showFallback) {
      return FutureBuilder<SpeciesImageSource?>(
        future: _fallbackImage,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _withAttribution(_loading(context), '');
          }
          final source = snapshot.data;
          if (source == null) {
            return _withAttribution(_placeholder(context), '');
          }
          return _withAttribution(
            _image(context, source.url, isFallback: true),
            source.attribution,
          );
        },
      );
    }

    return _withAttribution(
      _image(context, _providedSource, isFallback: false),
      widget.species.imageAttribution,
    );
  }

  Widget _image(
    BuildContext context,
    String source, {
    required bool isFallback,
  }) {
    final uri = Uri.tryParse(source);
    final isInsecureNetworkImage =
        uri != null && uri.scheme == 'http' && uri.host.isNotEmpty;
    if (isInsecureNetworkImage) {
      if (!isFallback) {
        _useFallbackAfterError();
        return _loading(context);
      }
      return _placeholder(context);
    }
    final isNetworkImage =
        uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty;
    Widget errorBuilder(
      BuildContext context,
      Object error,
      StackTrace? stackTrace,
    ) {
      if (isFallback) return _placeholder(context);
      _useFallbackAfterError();
      return _loading(context);
    }

    final image = isNetworkImage
        ? Image.network(
            source,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : _loading(context),
            errorBuilder: errorBuilder,
          )
        : Image.asset(
            source.startsWith('asset:')
                ? source
                      .substring('asset:'.length)
                      .replaceFirst(RegExp(r'^/+'), '')
                : source,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            errorBuilder: errorBuilder,
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.size / 4),
      child: image,
    );
  }

  Widget _withAttribution(Widget image, String attribution) {
    if (!widget.showAttribution || attribution.trim().isEmpty) return image;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        image,
        const SizedBox(height: 6),
        Text(
          attribution,
          textAlign: TextAlign.end,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _loading(BuildContext context) => SizedBox(
    width: widget.size,
    height: widget.size,
    child: Center(
      child: SizedBox(
        width: widget.size * 0.35,
        height: widget.size * 0.35,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ),
  );

  Widget _placeholder(BuildContext context) {
    final colors = switch (widget.species.category) {
      SpeciesCategory.fish => const [Color(0xFFD8EEF4), Color(0xFFA9D7E3)],
      SpeciesCategory.plant => const [Color(0xFFE1F0D8), Color(0xFFB9D9A8)],
      SpeciesCategory.invertebrate => const [
        Color(0xFFF8E4D5),
        Color(0xFFECC3A6),
      ],
    };
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.size / 4),
      child: Container(
        width: widget.size,
        height: widget.size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(widget.size / 4),
        ),
        child: Icon(
          _iconFor(widget.species.category),
          size: widget.size * 0.45,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

String _difficultyLabel(BuildContext context, SpeciesDifficulty difficulty) {
  final l10n = AppLocalizations.of(context)!;
  return switch (difficulty) {
    SpeciesDifficulty.veryEasy => l10n.difficultyVeryEasy,
    SpeciesDifficulty.easy => l10n.difficultyEasy,
    SpeciesDifficulty.medium => l10n.difficultyMedium,
    SpeciesDifficulty.hard => l10n.difficultyHard,
  };
}

String _zoneLabel(BuildContext context, SwimmingZone zone) {
  final l10n = AppLocalizations.of(context)!;
  return switch (zone) {
    SwimmingZone.bottom => l10n.zoneBottom,
    SwimmingZone.middle => l10n.zoneMiddle,
    SwimmingZone.top => l10n.zoneTop,
    SwimmingZone.all => l10n.zoneAll,
  };
}
