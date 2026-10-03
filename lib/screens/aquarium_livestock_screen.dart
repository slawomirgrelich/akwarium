import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/aquarium_firestore_model.dart';
import '../models/aquarium_model.dart' show CreatureCategory;
import '../models/species_models.dart';
import '../services/firestore_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/localized_labels.dart';
import '../widgets/species_autocomplete_field.dart';
import 'species_atlas_screen.dart';

class AquariumLivestockScreen extends StatelessWidget {
  const AquariumLivestockScreen({required this.aquarium, super.key});

  final AquariumModel aquarium;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.aquariumLivestockTitle}: ${aquarium.name}'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOptions(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addSpecies),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().getLivestock(aquarium.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(l10n.livestockLoadError));
          }
          final entries = snapshot.data ?? const <Map<String, dynamic>>[];
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.noSpeciesAddedOpenAtlas),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _showAddOptions(context),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addFirstSpecies),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              _StockHealthCard(aquarium: aquarium, entries: entries),
              const SizedBox(height: 12),
              ...entries.map((entry) {
                final addedAt = entry['addedAt'];
                final date = addedAt is Timestamp ? addedAt.toDate() : null;
                final notes = entry['notes']?.toString() ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      onTap: () => _showLivestockDetails(context, entry),
                      leading: const Icon(Icons.pets_outlined),
                      title: Text(
                        entry['namePl']?.toString() ?? l10n.unknownSpecies,
                      ),
                      subtitle: Text(
                        [
                          if ((entry['nameLatin']?.toString() ?? '').isNotEmpty)
                            entry['nameLatin'].toString(),
                          speciesCategoryLabel(
                            l10n,
                            entry['categoryLabel']?.toString() ??
                                entry['category']?.toString(),
                          ),
                          l10n.livestockCount(
                            (entry['count'] as num?)?.toInt() ?? 1,
                          ),
                          if (date != null)
                            l10n.addedOnDate(
                              '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
                            ),
                          if (notes.isNotEmpty) notes,
                        ].where((line) => line.isNotEmpty).join(' · '),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAddOptions(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(l10n.browseSpeciesAtlas),
              onTap: () => Navigator.pop(context, 'atlas'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_note_outlined),
              title: Text(l10n.addCustomSpecies),
              onTap: () => Navigator.pop(context, 'custom'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || choice == null) return;
    if (choice == 'atlas') {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => SpeciesAtlasScreen(tankId: aquarium.id),
        ),
      );
      return;
    }
    final entry = await showDialog<_CustomSpeciesEntry>(
      context: context,
      builder: (_) => const _CustomSpeciesDialog(),
    );
    if (entry == null || !context.mounted) return;
    try {
      await FirestoreService().addLivestockItem(
        aquarium.id,
        namePl: entry.name,
        nameLatin: entry.latinName,
        category: entry.category.name,
        count: entry.count,
        phRange: entry.phRange,
        tempRange: entry.tempRange,
        minTankVolume: entry.minTankVolume,
        notes: entry.notes,
      );
    } on FirestoreServiceException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }
}

Future<void> _showLivestockDetails(
  BuildContext context,
  Map<String, dynamic> entry,
) async {
  final l10n = AppLocalizations.of(context)!;
  final latinName = entry['nameLatin']?.toString() ?? '';
  final notes = entry['notes']?.toString().trim() ?? '';
  final addedAt = entry['addedAt'];
  final addedDate = addedAt is Timestamp
      ? addedAt.toDate()
      : addedAt is DateTime
      ? addedAt
      : null;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(entry['namePl']?.toString() ?? l10n.unknownSpecies),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (latinName.isNotEmpty)
            Text(
              latinName,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          const SizedBox(height: 8),
          Text(
            speciesCategoryLabel(
              l10n,
              entry['categoryLabel']?.toString() ??
                  entry['category']?.toString(),
            ),
          ),
          Text(l10n.livestockCount((entry['count'] as num?)?.toInt() ?? 1)),
          if (addedDate != null)
            Text(
              l10n.addedOnDate(
                '${addedDate.day.toString().padLeft(2, '0')}.${addedDate.month.toString().padLeft(2, '0')}.${addedDate.year}',
              ),
            ),
          if (notes.isNotEmpty) ...[const SizedBox(height: 8), Text(notes)],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.closeAction),
        ),
      ],
    ),
  );
}

class _CustomSpeciesEntry {
  const _CustomSpeciesEntry({
    required this.name,
    required this.latinName,
    required this.category,
    required this.count,
    required this.notes,
    required this.phRange,
    required this.tempRange,
    required this.minTankVolume,
  });

  final String name;
  final String latinName;
  final CreatureCategory category;
  final int count;
  final String notes;
  final String phRange;
  final String tempRange;
  final int minTankVolume;
}

class _CustomSpeciesDialog extends StatefulWidget {
  const _CustomSpeciesDialog();

  @override
  State<_CustomSpeciesDialog> createState() => _CustomSpeciesDialogState();
}

class _CustomSpeciesDialogState extends State<_CustomSpeciesDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  final _latin = TextEditingController();
  final _count = TextEditingController(text: '1');
  final _notes = TextEditingController();
  CreatureCategory _category = CreatureCategory.fish;
  Species? _selectedSpecies;

  @override
  void dispose() {
    _latin.dispose();
    _count.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.addCustomSpecies),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpeciesAutocompleteField(
                onChanged: (value) => setState(() {
                  _name = value;
                  final selected = _selectedSpecies;
                  if (selected != null &&
                      value.trim() !=
                          localizedSpeciesDisplayName(context, selected)) {
                    if (_latin.text == selected.nameLatin) _latin.clear();
                    _selectedSpecies = null;
                  }
                }),
                onSelected: (species) => setState(() {
                  _selectedSpecies = species;
                  _name = localizedSpeciesDisplayName(context, species);
                  _latin.text = species.nameLatin;
                  _category = creatureCategoryForSpecies(species);
                }),
                decoration: InputDecoration(labelText: l10n.speciesNameLabel),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.speciesNameRequired
                    : null,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _latin,
                decoration: InputDecoration(
                  labelText: l10n.latinNameOptionalLabel,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _count,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.speciesCountLabel),
                validator: (value) {
                  final count = int.tryParse(value?.trim() ?? '');
                  return (count == null || count < 1)
                      ? l10n.positiveCountRequired
                      : null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CreatureCategory>(
                key: ValueKey(_category),
                initialValue: _category,
                decoration: InputDecoration(labelText: l10n.category),
                items: CreatureCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(creatureCategoryLabel(l10n, category)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notes,
                maxLines: 3,
                decoration: InputDecoration(labelText: l10n.notesOptionalLabel),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.pop(
              context,
              _CustomSpeciesEntry(
                name: _selectedSpecies?.namePl ?? _name.trim(),
                latinName: _selectedSpecies?.nameLatin ?? _latin.text.trim(),
                category: _category,
                count: int.parse(_count.text.trim()),
                notes: _notes.text.trim(),
                phRange: _selectedSpecies == null
                    ? ''
                    : speciesRangeLabel(_selectedSpecies!.phRange),
                tempRange: _selectedSpecies == null
                    ? ''
                    : speciesRangeLabel(_selectedSpecies!.tempRange),
                minTankVolume: _selectedSpecies?.aquariumMinimumLiters ?? 0,
              ),
            );
          },
          child: Text(l10n.add),
        ),
      ],
    );
  }
}

class _StockHealthCard extends StatelessWidget {
  const _StockHealthCard({required this.aquarium, required this.entries});

  final AquariumModel aquarium;
  final List<Map<String, dynamic>> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final requiredVolume = entries
        .where((entry) => !_isPlantEntry(entry))
        .fold<int>(
          0,
          (total, entry) => total + _integer(entry['minTankVolume']),
        );
    final capacity = aquarium.capacityLiters;
    final exceedsCapacity = capacity > 0 && requiredVolume > capacity;
    final volumeRatio = capacity <= 0
        ? 0.0
        : (requiredVolume / capacity).clamp(0.0, 1.0);
    final ph = _summarizeRange(entries, 'phRange');
    final temperature = _summarizeRange(entries, 'tempRange');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.health_and_safety_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.stockHealthTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (exceedsCapacity ||
                    ph.conflicts.isNotEmpty ||
                    temperature.conflicts.isNotEmpty)
                  Chip(
                    avatar: Icon(Icons.warning_amber_rounded, size: 18),
                    label: Text(l10n.livestockWarnings),
                  )
                else
                  Chip(
                    avatar: Icon(Icons.check_circle_outline, size: 18),
                    label: Text(l10n.livestockCompatible),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.minimumVolumeForStock(
                requiredVolume,
                capacity.toStringAsFixed(0),
              ),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: volumeRatio,
              color: exceedsCapacity
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            if (exceedsCapacity) ...[
              const SizedBox(height: 6),
              Text(
                l10n.stockCapacityExceeded((requiredVolume - capacity).ceil()),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 14),
            _RangeStatusLine(label: 'pH', summary: ph),
            const SizedBox(height: 8),
            _RangeStatusLine(
              label: 'Temperatura',
              summary: temperature,
              suffix: '°C',
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeSummary {
  const _RangeSummary({this.minimum, this.maximum, this.conflicts = const []});

  final double? minimum;
  final double? maximum;
  final List<String> conflicts;

  bool get hasRange => minimum != null && maximum != null;
}

class _RangeStatusLine extends StatelessWidget {
  const _RangeStatusLine({
    required this.label,
    required this.summary,
    this.suffix = '',
  });

  final String label;
  final _RangeSummary summary;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasConflicts = summary.conflicts.isNotEmpty;
    final color = hasConflicts
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;
    final value = summary.hasRange
        ? '${_formatRangeValue(summary.minimum!)} - ${_formatRangeValue(summary.maximum!)}$suffix'
        : l10n.noData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            if (hasConflicts)
              Icon(Icons.warning_amber_rounded, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        if (hasConflicts)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              l10n.noSharedRangeFor(summary.conflicts.join(', ')),
              style: TextStyle(color: color, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

_RangeSummary _summarizeRange(
  List<Map<String, dynamic>> entries,
  String field,
) {
  final ranges = <({String name, double minimum, double maximum})>[];
  for (final entry in entries) {
    final parsed = _parseRange(entry[field]);
    if (parsed == null) continue;
    ranges.add((
      name: entry['namePl']?.toString() ?? 'Nieznany gatunek',
      minimum: parsed.$1,
      maximum: parsed.$2,
    ));
  }
  if (ranges.isEmpty) return const _RangeSummary();

  final minimum = ranges
      .map((range) => range.minimum)
      .reduce((a, b) => a > b ? a : b);
  final maximum = ranges
      .map((range) => range.maximum)
      .reduce((a, b) => a < b ? a : b);
  final conflicts = <String>{};
  for (var first = 0; first < ranges.length; first++) {
    for (var second = first + 1; second < ranges.length; second++) {
      final a = ranges[first];
      final b = ranges[second];
      if (a.minimum > b.maximum || b.minimum > a.maximum) {
        conflicts
          ..add(a.name)
          ..add(b.name);
      }
    }
  }
  return _RangeSummary(
    minimum: minimum <= maximum ? minimum : null,
    maximum: minimum <= maximum ? maximum : null,
    conflicts: conflicts.toList(growable: false),
  );
}

(double, double)? _parseRange(Object? value) {
  if (value is! String) return null;
  final matches = RegExp(r'-?\d+(?:[.,]\d+)?')
      .allMatches(value)
      .map((match) => double.tryParse(match.group(0)!.replaceAll(',', '.')))
      .whereType<double>()
      .toList();
  if (matches.length < 2) return null;
  return (matches[0], matches[1]);
}

int _integer(Object? value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

bool _isPlantEntry(Map<String, dynamic> entry) {
  final category = '${entry['categoryLabel'] ?? entry['category'] ?? ''}'
      .toLowerCase();
  return category == 'flora' ||
      category == 'plant' ||
      category.contains('roślin') ||
      category.contains('roslin');
}

String _formatRangeValue(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toString();
