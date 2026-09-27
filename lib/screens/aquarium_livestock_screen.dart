import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/aquarium_firestore_model.dart';
import '../services/firestore_service.dart';

class AquariumLivestockScreen extends StatelessWidget {
  const AquariumLivestockScreen({required this.aquarium, super.key});

  final AquariumModel aquarium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Obsada: ${aquarium.name}')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().getLivestock(aquarium.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Nie udało się wczytać obsady.'));
          }
          final entries = snapshot.data ?? const <Map<String, dynamic>>[];
          if (entries.isEmpty) {
            return const Center(child: Text('To akwarium nie ma jeszcze obsady.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
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
                  leading: const Icon(Icons.pets_outlined),
                  title: Text(entry['namePl']?.toString() ?? 'Nieznany gatunek'),
                  subtitle: Text(
                    [
                      if ((entry['nameLatin']?.toString() ?? '').isNotEmpty)
                        entry['nameLatin'].toString(),
                      entry['category']?.toString() ?? '',
                      'Liczba: ${entry['count'] ?? 1}',
                      if (date != null)
                        'Dodano: ${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
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
}

class _StockHealthCard extends StatelessWidget {
  const _StockHealthCard({required this.aquarium, required this.entries});

  final AquariumModel aquarium;
  final List<Map<String, dynamic>> entries;

  @override
  Widget build(BuildContext context) {
    final requiredVolume = entries.fold<int>(
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
                    'Zdrowie i zgodność obsady',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (exceedsCapacity || ph.conflicts.isNotEmpty || temperature.conflicts.isNotEmpty)
                  const Chip(
                    avatar: Icon(Icons.warning_amber_rounded, size: 18),
                    label: Text('Ostrzeżenia'),
                  )
                else
                  const Chip(
                    avatar: Icon(Icons.check_circle_outline, size: 18),
                    label: Text('Zgodna'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Minimalna objętość dla obsady: $requiredVolume l / ${capacity.toStringAsFixed(0)} l',
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
                'Wymagania obsady przekraczają pojemność akwarium o ${(requiredVolume - capacity).ceil()} l.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 14),
            _RangeStatusLine(label: 'Zakres pH', summary: ph),
            const SizedBox(height: 8),
            _RangeStatusLine(label: 'Temperatura', summary: temperature, suffix: '°C'),
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
    final hasConflicts = summary.conflicts.isNotEmpty;
    final color = hasConflicts
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;
    final value = summary.hasRange
        ? '${_formatRangeValue(summary.minimum!)} - ${_formatRangeValue(summary.maximum!)}$suffix'
        : 'Brak danych';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            if (hasConflicts)
              Icon(Icons.warning_amber_rounded, color: color, size: 18),
            const SizedBox(width: 6),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
        if (hasConflicts)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              'Brak wspólnego zakresu dla: ${summary.conflicts.join(', ')}',
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

  final minimum = ranges.map((range) => range.minimum).reduce((a, b) => a > b ? a : b);
  final maximum = ranges.map((range) => range.maximum).reduce((a, b) => a < b ? a : b);
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

String _formatRangeValue(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
