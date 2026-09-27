import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/species_catalog.dart';
import '../models/aquarium_firestore_model.dart';
import '../models/species_models.dart';
import '../services/firestore_service.dart';
import 'aquarium_livestock_screen.dart';

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
            onPressed: () => _addSpeciesToAquarium(
              context,
              dialogContext,
              userId,
              species,
            ),
            icon: const Icon(Icons.water_drop_outlined),
            label: const Text('Dodaj do mojego akwarium'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSpeciesToAquarium(
    BuildContext pageContext,
    BuildContext detailsContext,
    String userId,
    Species species,
  ) async {
    final firestore = FirestoreService();
    try {
      final aquariums = await firestore.getAquariums().first;
      if (!pageContext.mounted) return;
      if (aquariums.isEmpty) {
        ScaffoldMessenger.of(pageContext).showSnackBar(
          const SnackBar(content: Text('Nie znaleziono akwariów na Twoim koncie.')),
        );
        return;
      }

      final aquarium = aquariums.length == 1
          ? aquariums.single
          : await showModalBottomSheet<AquariumModel>(
              context: pageContext,
              showDragHandle: true,
              builder: (_) => _AquariumSelectionSheet(aquariums: aquariums),
            );
      if (aquarium == null || !pageContext.mounted) return;

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
      if (detailsContext.mounted) Navigator.pop(detailsContext);
      ScaffoldMessenger.of(pageContext).showSnackBar(
        SnackBar(
          content: Text('Dodano ${species.namePl} do akwarium ${aquarium.name}'),
          action: SnackBarAction(
            label: 'Zobacz obsadę',
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
        ScaffoldMessenger.of(pageContext).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    }
  }
}

class _AquariumSelectionSheet extends StatelessWidget {
  const _AquariumSelectionSheet({required this.aquariums});

  final List<AquariumModel> aquariums;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Wybierz akwarium',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ...aquariums.map(
          (aquarium) => ListTile(
            leading: const Icon(Icons.water_drop_outlined),
            title: Text(aquarium.name),
            subtitle: Text('${aquarium.capacityLiters.round()} l · ${aquarium.type}'),
            onTap: () => Navigator.pop(context, aquarium),
          ),
        ),
      ],
    ),
  );
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
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Dodaj ${widget.species.namePl}'),
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
            title: const Text('Data dodania'),
            subtitle: Text(_formatAdditionDate(_addedAt)),
            onTap: _pickDate,
          ),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notatki (opcjonalnie)',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Anuluj'),
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
        child: const Text('Zapisz'),
      ),
    ],
  );

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

String _difficultyLabel(SpeciesDifficulty difficulty) => switch (difficulty) {
  SpeciesDifficulty.veryEasy => 'bardzo łatwa',
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
