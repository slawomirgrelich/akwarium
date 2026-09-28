import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/species_catalog.dart';
import '../models/aquarium_model.dart';
import '../aquarium_management_screen.dart';
import '../l10n/app_localizations.dart';
import '../models/species_models.dart';
import '../services/firestore_service.dart';
import '../services/stocking_compatibility_service.dart';
import 'species_atlas_screen.dart';

class TankStockingScreen extends StatelessWidget {
  const TankStockingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final provider = context.watch<AquariumProvider>();
    final tankId = provider.activeAquariumId;
    final aquarium = provider.selectedAquarium;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Zaloguj się, aby zobaczyć obsadę.')),
      );
    }
    if (aquarium == null || tankId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.aquariumLivestockTitle)),
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
                label: Text(AppLocalizations.of(context)!.addTank),
              ),
            ],
          ),
        ),
      );
    }
    return _StockingBody(tankId: tankId, aquarium: aquarium);
  }
}

class _StockingBody extends StatelessWidget {
  const _StockingBody({required this.tankId, required this.aquarium});

  final String tankId;
  final AquariumProfile aquarium;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AquariumProvider>();
    final latest = provider.waterTests.isEmpty
        ? null
        : provider.waterTests.first;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.aquariumLivestockTitle),
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().getLivestock(tankId),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          final species = items
              .map(_catalogSpeciesForEntry)
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
              if (snapshot.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Nie udało się zsynchronizować obsady: ${snapshot.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData)
                const LinearProgressIndicator(),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.noSpeciesAddedOpenAtlas,
                    ),
                  ),
                )
              else
                ...items.map((item) {
                  final category = '${item['category'] ?? ''}'.toLowerCase();
                  final isPlant =
                      category == 'flora' ||
                      category == 'plant' ||
                      category.contains('roślin') ||
                      category.contains('roslin');
                  final count = item['count'] is num
                      ? (item['count'] as num).toInt()
                      : 1;
                  final name = '${item['namePl'] ?? 'Nieznany gatunek'}';
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        isPlant ? Icons.local_florist : Icons.pets,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(name),
                      subtitle: Text(
                        '${item['nameLatin'] ?? ''} · $count szt. · ${item['categoryLabel'] ?? (isPlant ? 'Flora' : 'Fauna')}',
                      ),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            tooltip: 'Zmień ilość',
                            onPressed: () => _changeCount(
                              context,
                              tankId,
                              '${item['id'] ?? ''}',
                              count,
                              -1,
                            ),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          IconButton(
                            tooltip: 'Zwiększ ilość',
                            onPressed: () => _changeCount(
                              context,
                              tankId,
                              '${item['id'] ?? ''}',
                              count,
                              1,
                            ),
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
        label: Text(AppLocalizations.of(context)!.addSpecies),
      ),
    );
  }

  Future<void> _changeCount(
    BuildContext context,
    String tankId,
    String itemId,
    int currentCount,
    int delta,
  ) async {
    final count = currentCount + delta;
    try {
      if (count <= 0) {
        await FirestoreService().deleteLivestockItem(tankId, itemId);
      } else {
        await FirestoreService().updateLivestockCount(tankId, itemId, count);
      }
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

Species? _catalogSpeciesForEntry(Map<String, dynamic> entry) {
  final latinName = entry['nameLatin']?.toString().toLowerCase();
  if (latinName == null || latinName.isEmpty) return null;
  return speciesCatalog
      .where((species) => species.nameLatin.toLowerCase() == latinName)
      .firstOrNull;
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
                Icon(
                  report.isCompatible
                      ? Icons.check_circle
                      : Icons.warning_amber,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.compatibilityPercent(report.score),
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (report.isCompatible)
              Text(AppLocalizations.of(context)!.livestockWithinRange)
            else
              ...report.warnings.map(
                (warning) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('• ${warning.message}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
