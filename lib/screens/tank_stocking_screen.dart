import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/species_catalog.dart';
import '../models/aquarium_model.dart';
import '../aquarium_management_screen.dart';
import '../models/species_models.dart';
import '../services/database_service.dart';
import '../services/stocking_compatibility_service.dart';
import 'species_atlas_screen.dart';

class TankStockingScreen extends StatelessWidget {
  const TankStockingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final provider = context.watch<AquariumProvider>();
    final tankId = provider.activeAquariumId;
    final aquarium = provider.activeAquarium;
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Zaloguj się, aby zobaczyć obsadę.')));
    }
    if (aquarium == null || tankId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Obsada akwarium')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Najpierw dodaj akwarium.'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AquariumManagementScreen(),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Dodaj akwarium'),
              ),
            ],
          ),
        ),
      );
    }
    return _StockingBody(
      userId: userId,
      tankId: tankId,
      aquarium: aquarium,
    );
  }
}

class _StockingBody extends StatelessWidget {
  const _StockingBody({
    required this.userId,
    required this.tankId,
    required this.aquarium,
  });

  final String userId;
  final String tankId;
  final AquariumProfile aquarium;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AquariumProvider>();
    final latest = provider.waterTests.isEmpty ? null : provider.waterTests.first;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obsada akwarium'),
        actions: [
          IconButton(
            tooltip: 'Atlas gatunków',
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => SpeciesAtlasScreen(
                  tankId: tankId,
                  onCreateAquarium: () => showCreateAquariumDialog(context),
                ),
              ),
            ),
            icon: const Icon(Icons.menu_book_outlined),
          ),
        ],
      ),
      body: StreamBuilder<List<TankStockItem>>(
        stream: DatabaseService().getTankStockingStream(userId, tankId),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <TankStockItem>[];
          final species = items
              .map((item) => speciesCatalog.where((entry) => entry.id == item.speciesId).firstOrNull)
              .whereType<Species>()
              .toList();
          final report = StockingCompatibilityService().validate(
            volumeLiters: aquarium.volumeNetLiters,
            temperature: latest?.temp,
            pH: latest?.ph,
            species: species,
          );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CompatibilityCard(report: report),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Brak dodanych gatunków. Otwórz atlas, aby dodać obsadę.')),
                )
              else
                ...items.map((item) {
                  final match = speciesCatalog.where((entry) => entry.id == item.speciesId).firstOrNull;
                  if (match == null) return const SizedBox.shrink();
                  return Card(
                    child: ListTile(
                      leading: Icon(_iconFor(match.category), color: Theme.of(context).colorScheme.primary),
                      title: Text(match.namePl),
                      subtitle: Text('${match.nameLatin} · ${item.count} szt.'),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            tooltip: 'Zmień ilość',
                            onPressed: () => _changeCount(context, userId, tankId, item, -1),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          IconButton(
                            tooltip: 'Zwiększ ilość',
                            onPressed: () => _changeCount(context, userId, tankId, item, 1),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => SpeciesAtlasScreen(
              tankId: tankId,
              onCreateAquarium: () => showCreateAquariumDialog(context),
            ),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Dodaj gatunek'),
      ),
    );
  }

  Future<void> _changeCount(
    BuildContext context,
    String userId,
    String tankId,
    TankStockItem item,
    int delta,
  ) async {
    final count = item.count + delta;
    if (count <= 0) {
      await DatabaseService().deleteStockItem(userId, tankId, item.id);
    } else {
      await DatabaseService().updateStockItem(userId, tankId, item.copyWith(count: count));
    }
  }
}

class _CompatibilityCard extends StatelessWidget {
  const _CompatibilityCard({required this.report});

  final CompatibilityReport report;

  @override
  Widget build(BuildContext context) {
    final color = report.isCompatible
        ? const Color(0xFF10B981)
        : report.warnings.any((warning) => warning.isCritical)
            ? Theme.of(context).colorScheme.error
            : const Color(0xFFF59E0B);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(report.isCompatible ? Icons.check_circle : Icons.warning_amber, color: color),
                const SizedBox(width: 8),
                Text('${report.score}% kompatybilności', style: TextStyle(color: color, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 8),
            if (report.isCompatible)
              const Text('Obsada mieści się w sprawdzonych zakresach.')
            else
              ...report.warnings.map((warning) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('• ${warning.message}'),
                  )),
          ],
        ),
      ),
    );
  }
}

IconData _iconFor(SpeciesCategory category) => switch (category) {
  SpeciesCategory.fish => Icons.pets,
  SpeciesCategory.plant => Icons.local_florist,
  SpeciesCategory.invertebrate => Icons.bug_report_outlined,
};
