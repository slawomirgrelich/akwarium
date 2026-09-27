import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/species_catalog.dart';
import '../models/species_models.dart';
import '../services/database_service.dart';

class SpeciesAtlasScreen extends StatefulWidget {
  const SpeciesAtlasScreen({required this.tankId, super.key});

  final String tankId;

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
    final query = _search.text.trim().toLowerCase();
    final filtered = speciesCatalog.where((species) {
      final matchesQuery = query.isEmpty ||
          '${species.namePl} ${species.nameLatin}'.toLowerCase().contains(query);
      return matchesQuery && (_category == null || species.category == _category);
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Atlas gatunków')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Szukaj gatunku',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _filterChip('Wszystkie', null),
              _filterChip('Ryby', SpeciesCategory.fish),
              _filterChip('Rośliny', SpeciesCategory.plant),
              _filterChip('Bezkręgowce', SpeciesCategory.invertebrate),
            ],
          ),
          const SizedBox(height: 16),
          ...filtered.map((species) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(_iconFor(species.category)),
                  ),
                  title: Text(species.namePl),
                  subtitle: Text(
                    '${species.nameLatin} · od ${species.minTankVolumeLiters} l',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDetails(species),
                ),
              )),
          if (filtered.isEmpty) const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Nie znaleziono gatunków.')),
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
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(species.namePl),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                species.nameLatin,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Text(species.description),
              const SizedBox(height: 16),
              const Text(
                'Wskazówki pielęgnacyjne',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(species.careNotes),
              const SizedBox(height: 16),
              Text('Minimum akwarium: ${species.minTankVolumeLiters} l'),
              Text('Temperatura: ${species.tempRange.min}–${species.tempRange.max}°C'),
              Text('pH: ${species.phRange.min}–${species.phRange.max}'),
              Text('GH: ${species.ghRange.min}–${species.ghRange.max}'),
              Text('Trudność: ${_difficultyLabel(species.difficulty)}'),
              Text('Strefa pływania: ${_zoneLabel(species.swimmingZone)}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Anuluj')),
          FilledButton.icon(
            onPressed: () async {
              await DatabaseService().addStockItem(
                userId,
                widget.tankId,
                TankStockItem(
                  id: '',
                  tankId: widget.tankId,
                  speciesId: species.id,
                  count: 1,
                  addedDate: DateTime.now(),
                ),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            icon: const Icon(Icons.add),
            label: const Text('Dodaj do akwarium'),
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(SpeciesCategory category) => switch (category) {
  SpeciesCategory.fish => Icons.pets,
  SpeciesCategory.plant => Icons.local_florist,
  SpeciesCategory.invertebrate => Icons.bug_report_outlined,
};

String _difficultyLabel(SpeciesDifficulty difficulty) => switch (difficulty) {
  SpeciesDifficulty.easy => 'łatwa',
  SpeciesDifficulty.medium => 'średnia',
  SpeciesDifficulty.hard => 'trudna',
};

String _zoneLabel(SwimmingZone zone) => switch (zone) {
  SwimmingZone.bottom => 'dno',
  SwimmingZone.middle => 'środek',
  SwimmingZone.top => 'powierzchnia',
  SwimmingZone.all => 'cały zbiornik',
};
