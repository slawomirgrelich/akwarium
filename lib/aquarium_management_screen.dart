import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'models/aquarium_model.dart';
import 'models/species_models.dart';
import 'l10n/app_localizations.dart';
import 'screens/species_atlas_screen.dart';
import 'screens/tank_stocking_screen.dart';
import 'screens/tank_photo_journal_screen.dart';
import 'services/firestore_service.dart';
import 'services/pro_access_service.dart';
import 'widgets/confirm_livestock_removal_dialog.dart';
import 'widgets/pro_paywall_dialog.dart';
import 'widgets/species_autocomplete_field.dart';
import 'utils/localized_labels.dart';

Future<void> showCreateAquariumDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (_) => const AddAquariumModal(),
  );
}

String _tankTypeLabel(AppLocalizations l10n, TankType type) => switch (type) {
  TankType.freshwater => l10n.freshwater,
  TankType.marine => l10n.saltwater,
  TankType.planted => l10n.plantedTankType,
  TankType.biotope => l10n.biotopeTankType,
  TankType.shrimp => l10n.shrimpTankType,
};

String _formatSetupDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

class TankSwitcher extends StatelessWidget {
  const TankSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AquariumProvider>();
    final activeAquarium = provider.selectedAquarium;
    if (activeAquarium == null) {
      return ActionChip(
        avatar: const Icon(Icons.add, size: 18),
        label: Text(AppLocalizations.of(context)!.addTank),
        onPressed: () => Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const AquariumManagementScreen(),
          ),
        ),
      );
    }
    return PopupMenuButton<String>(
      tooltip: AppLocalizations.of(context)!.changeAquariumTooltip,
      onSelected: provider.selectAquarium,
      itemBuilder: (context) => provider.aquariums
          .map(
            (aquarium) => PopupMenuItem<String>(
              value: aquarium.id,
              child: Row(
                children: [
                  Icon(
                    aquarium.id == provider.activeAquariumId
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(aquarium.name),
                ],
              ),
            ),
          )
          .toList(),
      child: Chip(
        avatar: const Icon(Icons.water_drop_outlined, size: 18),
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Text(activeAquarium.name, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

class AquariumManagementScreen extends StatelessWidget {
  const AquariumManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        title: Text(l10n.tanksAndStockTitle),
        actions: [
          IconButton(
            tooltip: l10n.aquariumLivestockTitle,
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const TankStockingScreen()),
            ),
            icon: const Icon(Icons.pets_outlined),
          ),
          IconButton(
            tooltip: l10n.speciesAtlasTitle,
            onPressed: () {
              final tankId = context.read<AquariumProvider>().activeAquariumId;
              Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => SpeciesAtlasScreen(
                    tankId: tankId,
                    onCreateAquarium: () => showCreateAquariumDialog(context),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.menu_book_outlined),
          ),
          IconButton(
            tooltip: l10n.photoJournalTitle,
            onPressed: () {
              final tankId = context.read<AquariumProvider>().activeAquariumId;
              Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => TankPhotoJournalScreen(tankId: tankId),
                ),
              );
            },
            icon: const Icon(Icons.photo_library_outlined),
          ),
          IconButton(
            tooltip: l10n.addTank,
            onPressed: () => _showAddAquarium(context),
            icon: const Icon(Icons.add_business_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = _ManagementContent(
              wide: constraints.maxWidth >= 720,
              onAddAquarium: () => _showAddAquarium(context),
              onAddInhabitant: () => _showAddInhabitant(context),
            );
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: content,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAddAquarium(BuildContext context) {
    showCreateAquariumDialog(context);
  }

  void _showAddInhabitant(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const AddInhabitantModal(),
    );
  }
}

class _ManagementContent extends StatefulWidget {
  const _ManagementContent({
    required this.wide,
    required this.onAddAquarium,
    required this.onAddInhabitant,
  });

  final bool wide;
  final VoidCallback onAddAquarium;
  final VoidCallback onAddInhabitant;

  @override
  State<_ManagementContent> createState() => _ManagementContentState();
}

class _ManagementContentState extends State<_ManagementContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  final _search = TextEditingController();
  final _firestoreService = FirestoreService();
  String? _streamAquariumId;
  Stream<List<Map<String, dynamic>>>? _livestockStream;

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AquariumProvider>();
    final aquariumId = provider.activeAquariumId;
    if (_streamAquariumId != aquariumId) {
      _streamAquariumId = aquariumId;
      _livestockStream = aquariumId.isEmpty
          ? Stream<List<Map<String, dynamic>>>.value(const [])
          : _firestoreService.getLivestock(aquariumId);
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _livestockStream,
      builder: (context, stockSnapshot) {
        final inhabitants =
            (stockSnapshot.data ?? const <Map<String, dynamic>>[])
                .map((entry) => _inhabitantFromFirestore(entry, aquariumId))
                .toList(growable: false);
        final query = _search.text.toLowerCase();
        final filtered = inhabitants.where((item) {
          return '${item.name} ${item.latinName} ${item.notes ?? ''}'
              .toLowerCase()
              .contains(query);
        }).toList();
        final fauna = filtered
            .where((item) => item.category != CreatureCategory.plant)
            .toList();
        final flora = filtered
            .where((item) => item.category == CreatureCategory.plant)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (stockSnapshot.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    AppLocalizations.of(context)!
                        .livestockSyncError('${stockSnapshot.error}'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                )
              else if (stockSnapshot.connectionState ==
                      ConnectionState.waiting &&
                  !stockSnapshot.hasData)
                const LinearProgressIndicator(),
              _TankProfileStrip(onAdd: widget.onAddAquarium),
              const SizedBox(height: 16),
              _StockingSummary(inhabitants: inhabitants),
              const SizedBox(height: 18),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchSpeciesOrVar,
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabs,
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color,
                tabs: [
                  Tab(text: 'Fauna (${fauna.length})'),
                  Tab(text: 'Flora (${flora.length})'),
                ],
              ),
              SizedBox(
                height: 450,
                child: _ManagementTabView(
                  controller: _tabs,
                  fauna: fauna,
                  flora: flora,
                ),
              ),
              FilledButton.icon(
                onPressed: widget.onAddInhabitant,
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.addSpeciesToStock),
              ),
            ],
          ),
        );
      },
    );
  }
}

Inhabitant _inhabitantFromFirestore(
  Map<String, dynamic> data,
  String aquariumId,
) {
  final rawCategory = '${data['category'] ?? data['categoryLabel'] ?? ''}'
      .toLowerCase();
  final isPlant =
      rawCategory.contains('flora') ||
      rawCategory.contains('plant') ||
      rawCategory.contains('roślin') ||
      rawCategory.contains('roslin');
  final rawDate = data['addedAt'];
  final addedDate = rawDate is Timestamp
      ? rawDate.toDate()
      : rawDate is DateTime
      ? rawDate
      : DateTime.tryParse('${rawDate ?? ''}') ?? DateTime.now();
  return Inhabitant(
    id: '${data['id'] ?? ''}',
    aquariumId: aquariumId,
    name: '${data['namePl'] ?? data['name'] ?? 'Nieznany gatunek'}',
    latinName: '${data['nameLatin'] ?? data['latinName'] ?? ''}',
    category: isPlant ? CreatureCategory.plant : CreatureCategory.fish,
    count: data['count'] is num ? (data['count'] as num).toInt() : 1,
    addedDate: addedDate,
    status: 'Zdrowe',
    difficulty: data['difficulty']?.toString(),
    notes: data['notes']?.toString(),
    imagePath: data['photoUrl']?.toString(),
  );
}

class _ManagementTabView extends StatelessWidget {
  const _ManagementTabView({
    required this.controller,
    required this.fauna,
    required this.flora,
  });

  final TabController controller;
  final List<Inhabitant> fauna;
  final List<Inhabitant> flora;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      children: [
        _InhabitantList(items: fauna),
        _InhabitantList(items: flora),
      ],
    );
  }
}

class _TankProfileStrip extends StatelessWidget {
  const _TankProfileStrip({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AquariumProvider>();
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.aquariums.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == provider.aquariums.length) {
            return InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 176,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withAlpha(100),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    SizedBox(height: 6),
                    Text(AppLocalizations.of(context)!.addTank),
                  ],
                ),
              ),
            );
          }
          final aquarium = provider.aquariums[index];
          final active = aquarium.id == provider.activeAquariumId;
          return InkWell(
            onTap: () => provider.selectAquarium(aquarium.id),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 176,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: active
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).dividerColor,
                  width: active ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor
                        .withAlpha(active ? 25 : 5),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.water, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          aquarium.name,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (active)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 18,
                        ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          size: 18,
                        ),
                        onSelected: (action) async {
                          if (action == 'delete') {
                            try {
                              await provider.deleteAquarium(aquarium.id);
                            } on Object catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error.toString())),
                                );
                              }
                            }
                          } else {
                            showDialog<void>(
                              context: context,
                              builder: (_) =>
                                  AddAquariumModal(initial: aquarium),
                            );
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(
                              AppLocalizations.of(context)!.editAction,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              AppLocalizations.of(context)!.deleteAction,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '${AppLocalizations.of(context)!.netVolumeShort(aquarium.volumeNetLiters.round())} · ${_tankTypeLabel(AppLocalizations.of(context)!, aquarium.type)}',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: FirestoreService().getLivestock(aquarium.id),
                    builder: (context, snapshot) {
                      final count =
                          (snapshot.data ?? const <Map<String, dynamic>>[])
                              .fold<int>(
                                0,
                                (total, item) =>
                                    total +
                                    (item['count'] is num
                                        ? (item['count'] as num).toInt()
                                        : 1),
                              );
                      return Text(
                        '${AppLocalizations.of(context)!.daysCount(aquarium.ageInDays)} · ${AppLocalizations.of(context)!.inhabitantsCount(count)}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StockingSummary extends StatelessWidget {
  const _StockingSummary({required this.inhabitants});
  final List<Inhabitant> inhabitants;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AquariumProvider>();
    final species = inhabitants.length;
    final animals = inhabitants
        .where((item) => item.category != CreatureCategory.plant)
        .fold<int>(0, (total, item) => total + item.count);
    final activeAquarium = provider.selectedAquarium;
    final litersPerAnimal = animals == 0 || activeAquarium == null
        ? double.infinity
        : activeAquarium.volumeNetLiters / animals;
    final overloaded = litersPerAnimal < 2;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              (overloaded
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.secondary)
                  .withAlpha(90),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryMetric(
              label: AppLocalizations.of(context)!.speciesCount,
              value: '$species',
              icon: Icons.category_outlined,
            ),
          ),
          Expanded(
            child: _SummaryMetric(
              label: AppLocalizations.of(context)!.itemCount,
              value: '$animals',
              icon: Icons.pets_outlined,
            ),
          ),
          Expanded(
            child: _SummaryMetric(
              label: 'L / szt.',
              value: animals == 0 ? '-' : litersPerAnimal.toStringAsFixed(1),
              icon: overloaded
                  ? Icons.warning_amber
                  : Icons.check_circle_outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: Theme.of(context).primaryColor),
      const SizedBox(height: 5),
      Text(
        value,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 11,
        ),
      ),
    ],
  );
}

class _InhabitantList extends StatelessWidget {
  const _InhabitantList({required this.items});
  final List<Inhabitant> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noEntriesInCategory,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => _InhabitantCard(item: items[index]),
    );
  }
}

class _InhabitantCard extends StatelessWidget {
  const _InhabitantCard({required this.item});
  final Inhabitant item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = item.status == 'Zdrowe' ? l10n.healthy : item.status;
    return Card(
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
          child: Icon(
            item.category == CreatureCategory.plant
                ? Icons.local_florist
                : Icons.pets,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${item.latinName} · ${l10n.livestockCount(item.count)}\n$status${item.plantPosition == null ? '' : ' · ${plantPositionLabel(l10n, item.plantPosition!)}'}',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          onPressed: () async {
            if (!await confirmLivestockRemoval(context, item.name) ||
                !context.mounted) {
              return;
            }
            try {
              await FirestoreService().deleteLivestockItem(
                item.aquariumId,
                item.id,
              );
            } on Object catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error.toString())));
              }
            }
          },
        ),
      ),
    );
  }
}

class AddAquariumModal extends StatefulWidget {
  const AddAquariumModal({this.initial, super.key});

  final AquariumProfile? initial;

  @override
  State<AddAquariumModal> createState() => _AddAquariumModalState();
}

class _AddAquariumModalState extends State<AddAquariumModal> {
  final _name = TextEditingController();
  final _net = TextEditingController(text: '100');
  final _gross = TextEditingController(text: '120');
  TankType _type = TankType.freshwater;
  late DateTime _setupDate;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _setupDate = initial?.setupDate ?? DateTime.now();
    if (initial != null) {
      _name.text = initial.name;
      _net.text = initial.volumeNetLiters.toString();
      _gross.text = (initial.volumeGrossLiters ?? initial.volumeNetLiters)
          .toString();
      _type = initial.type;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _net.dispose();
    _gross.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(AppLocalizations.of(context)!.addNewTank),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.aquariumName,
            ),
          ),
          TextField(
            controller: _net,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.netVolume,
              suffixText: 'l',
            ),
          ),
          TextField(
            controller: _gross,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.grossVolume,
              suffixText: 'l',
            ),
          ),
          DropdownButtonFormField<TankType>(
            initialValue: _type,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.tankType,
            ),
            items: TankType.values
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(
                      _tankTypeLabel(AppLocalizations.of(context)!, type),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _type = value!),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(AppLocalizations.of(context)!.setupDateLabel),
            subtitle: Text(_formatSetupDate(_setupDate)),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickSetupDate,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(AppLocalizations.of(context)!.cancel),
      ),
      FilledButton(
        onPressed: _save,
        child: Text(AppLocalizations.of(context)!.add),
      ),
    ],
  );

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    final provider = context.read<AquariumProvider>();
    final isProUser = context.read<ProAccessService>().isProUser;
    if (widget.initial == null &&
        !isProUser &&
        provider.aquariums.length >= ProAccessService.freeAquariumLimit) {
      await ProPaywallDialog.show(context, headline: 'Nielimitowane akwaria');
      return;
    }
    final profile = AquariumProfile(
      id:
          widget.initial?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      volumeNetLiters: double.tryParse(_net.text.replaceAll(',', '.')) ?? 0,
      volumeGrossLiters: double.tryParse(_gross.text.replaceAll(',', '.')),
      setupDate: _setupDate,
      type: _type,
      imagePath: widget.initial?.imagePath,
    );
    try {
      if (widget.initial == null) {
        await provider.addAquarium(profile);
      } else {
        await provider.updateAquarium(profile);
      }
      if (mounted) Navigator.pop(context);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _pickSetupDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _setupDate.isAfter(DateTime.now())
          ? DateTime.now()
          : _setupDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (selected != null && mounted) setState(() => _setupDate = selected);
  }
}

class AddInhabitantModal extends StatefulWidget {
  const AddInhabitantModal({super.key});

  @override
  State<AddInhabitantModal> createState() => _AddInhabitantModalState();
}

class _AddInhabitantModalState extends State<AddInhabitantModal> {
  final _latin = TextEditingController();
  final _count = TextEditingController(text: '1');
  final _notes = TextEditingController();
  final _picker = ImagePicker();
  CreatureCategory _category = CreatureCategory.fish;
  String _name = '';
  Species? _selectedSpecies;
  PlantPosition? _position;
  String? _image;

  @override
  void dispose() {
    for (final controller in [_latin, _count, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.addSpecies),
      content: SingleChildScrollView(
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
                _position = null;
              }),
              decoration: InputDecoration(labelText: l10n.speciesNameLabel),
            ),
            TextField(
              controller: _latin,
              decoration: InputDecoration(
                labelText: l10n.latinNameOptionalLabel,
              ),
            ),
            TextField(
              controller: _count,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.speciesCountLabel),
            ),
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
              onChanged: (value) => setState(() {
                _category = value!;
                if (_category != CreatureCategory.plant) _position = null;
              }),
            ),
            if (_category == CreatureCategory.plant)
              DropdownButtonFormField<PlantPosition>(
                initialValue: _position,
                decoration: InputDecoration(
                  labelText: l10n.plantPositionFieldLabel,
                ),
                items: PlantPosition.values
                    .map(
                      (position) => DropdownMenuItem(
                        value: position,
                        child: Text(plantPositionLabel(l10n, position)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _position = value),
              ),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: InputDecoration(labelText: l10n.notesOptionalLabel),
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(l10n.galleryAction),
                ),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(l10n.cameraAction),
                ),
                if (_image != null)
                  Expanded(
                    child: Text(
                      l10n.photoAdded,
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.add)),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 80);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (mounted) {
      setState(
        () => _image =
            'data:image/${file.name.split('.').last};base64,${base64Encode(bytes)}',
      );
    }
  }

  Future<void> _save() async {
    if (_name.trim().isEmpty) return;
    final provider = context.read<AquariumProvider>();
    final aquariumId = provider.activeAquariumId;
    if (aquariumId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.selectAquariumFirst),
        ),
      );
      return;
    }
    try {
      await FirestoreService().addLivestockItem(
        aquariumId,
        namePl: _selectedSpecies?.namePl ?? _name.trim(),
        nameLatin: _selectedSpecies?.nameLatin ?? _latin.text.trim(),
        category: _category.name,
        count: int.tryParse(_count.text) ?? 1,
        phRange: _selectedSpecies == null
            ? ''
            : speciesRangeLabel(_selectedSpecies!.phRange),
        tempRange: _selectedSpecies == null
            ? ''
            : speciesRangeLabel(_selectedSpecies!.tempRange),
        minTankVolume: _selectedSpecies?.minTankVolumeLiters ?? 0,
        addedAt: DateTime.now(),
        notes: _notes.text.trim(),
        photoUrl: _image,
      );
      if (mounted) Navigator.pop(context);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}
