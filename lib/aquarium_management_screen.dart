import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'models/aquarium_model.dart';

const _managementInk = Color(0xFF12181F);
const _managementPanel = Color(0xFF1C2730);
const _managementCyan = Color(0xFF00E5FF);
const _managementGreen = Color(0xFF00E676);

class TankSwitcher extends StatelessWidget {
  const TankSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AquariumProvider>();
    return PopupMenuButton<String>(
      tooltip: 'Zmień akwarium',
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
                    color: Colors.teal,
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
        label: const Text('Zbiornik'),
      ),
    );
  }
}

class AquariumManagementScreen extends StatelessWidget {
  const AquariumManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _managementInk,
      appBar: AppBar(
        backgroundColor: _managementInk,
        foregroundColor: Colors.white,
        title: const Text('Akwaria i obsada'),
        actions: [
          IconButton(
            tooltip: 'Dodaj akwarium',
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
    showDialog<void>(
      context: context,
      builder: (_) => const AddAquariumModal(),
    );
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

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AquariumProvider>();
    final inhabitants = provider.inhabitants;
    final query = _search.text.toLowerCase();
    final filtered = inhabitants.where((item) {
      return '${item.name} ${item.latinName} ${item.notes ?? ''}'
          .toLowerCase()
          .contains(query);
    }).toList();
    final fauna = filtered.where((item) => item.category != CreatureCategory.plant).toList();
    final flora = filtered.where((item) => item.category == CreatureCategory.plant).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TankProfileStrip(onAdd: widget.onAddAquarium),
          const SizedBox(height: 16),
          _StockingSummary(inhabitants: inhabitants),
          const SizedBox(height: 18),
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Szukaj gatunku lub odmiany',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: _managementCyan),
              filled: true,
              fillColor: Colors.white.withAlpha(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabs,
            indicatorColor: _managementCyan,
            labelColor: _managementCyan,
            unselectedLabelColor: Colors.white60,
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
            label: const Text('Dodaj gatunek do obsady'),
          ),
        ],
      ),
    );
  }
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
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.aquariums.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == provider.aquariums.length) {
            return InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _managementCyan.withAlpha(100)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: _managementCyan),
                    SizedBox(height: 6),
                    Text('Dodaj akwarium', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            );
          }
          final aquarium = provider.aquariums[index];
          final active = aquarium.id == provider.activeAquariumId;
          final count = provider.inhabitants
              .where((item) => item.aquariumId == aquarium.id)
              .fold<int>(0, (sum, item) => sum + item.count);
          return InkWell(
            onTap: () => provider.selectAquarium(aquarium.id),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 240,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _managementPanel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: active ? _managementCyan : Colors.white12,
                  width: active ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(color: _managementCyan.withAlpha(active ? 25 : 5), blurRadius: 16),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.water, color: _managementCyan),
                    const SizedBox(width: 8),
                    Expanded(child: Text(aquarium.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                    if (active) const Icon(Icons.check_circle, color: _managementGreen, size: 18),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white54, size: 18),
                      onSelected: (action) {
                        if (action == 'delete') {
                          provider.deleteAquarium(aquarium.id);
                        } else {
                          showDialog<void>(
                            context: context,
                            builder: (_) => AddAquariumModal(initial: aquarium),
                          );
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edytuj')),
                        PopupMenuItem(value: 'delete', child: Text('Usuń')),
                      ],
                    ),
                  ]),
                  const Spacer(),
                  Text('${aquarium.volumeNetLiters.toStringAsFixed(0)} l netto · ${aquarium.type.label}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${aquarium.ageInDays} dni · $count mieszkańców', style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
        .fold<int>(0, (sum, item) => sum + item.count);
    final litersPerAnimal = animals == 0 ? double.infinity : provider.activeAquarium.volumeNetLiters / animals;
    final overloaded = litersPerAnimal < 2;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _managementPanel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: (overloaded ? Colors.redAccent : _managementGreen).withAlpha(90)),
      ),
      child: Row(
        children: [
          Expanded(child: _SummaryMetric(label: 'Gatunki', value: '$species', icon: Icons.category_outlined)),
          Expanded(child: _SummaryMetric(label: 'Sztuki', value: '$animals', icon: Icons.pets_outlined)),
          Expanded(child: _SummaryMetric(label: 'L / szt.', value: animals == 0 ? '-' : litersPerAnimal.toStringAsFixed(1), icon: overloaded ? Icons.warning_amber : Icons.check_circle_outline)),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Column(children: [Icon(icon, color: _managementCyan), const SizedBox(height: 5), Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11))]);
}

class _InhabitantList extends StatelessWidget {
  const _InhabitantList({required this.items});
  final List<Inhabitant> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text('Brak wpisów w tej kategorii.', style: TextStyle(color: Colors.white54)));
    return ListView.builder(itemCount: items.length, itemBuilder: (context, index) => _InhabitantCard(item: items[index]));
  }
}

class _InhabitantCard extends StatelessWidget {
  const _InhabitantCard({required this.item});
  final Inhabitant item;

  @override
  Widget build(BuildContext context) => Card(color: _managementPanel, child: ListTile(leading: CircleAvatar(backgroundColor: _managementCyan.withAlpha(25), child: Icon(item.category == CreatureCategory.plant ? Icons.local_florist : Icons.pets, color: _managementCyan)), title: Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), subtitle: Text('${item.latinName} · ${item.count} szt.\n${item.status}${item.plantPosition == null ? '' : ' · ${item.plantPosition!.label}'}', style: const TextStyle(color: Colors.white60)), isThreeLine: true, trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.white54), onPressed: () => context.read<AquariumProvider>().deleteInhabitant(item.id))));
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

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _name.text = initial.name;
      _net.text = initial.volumeNetLiters.toString();
      _gross.text = (initial.volumeGrossLiters ?? initial.volumeNetLiters).toString();
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
  Widget build(BuildContext context) => AlertDialog(title: const Text('Nowe akwarium'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nazwa')), TextField(controller: _net, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Pojemność netto', suffixText: 'l')), TextField(controller: _gross, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Pojemność brutto', suffixText: 'l')), DropdownButtonFormField<TankType>(initialValue: _type, decoration: const InputDecoration(labelText: 'Typ zbiornika'), items: TankType.values.map((type) => DropdownMenuItem(value: type, child: Text(type.label))).toList(), onChanged: (value) => setState(() => _type = value!))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')), FilledButton(onPressed: _save, child: const Text('Dodaj'))]);

  void _save() {
    if (_name.text.trim().isEmpty) return;
    final provider = context.read<AquariumProvider>();
    final profile = AquariumProfile(
      id: widget.initial?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      volumeNetLiters: double.tryParse(_net.text.replaceAll(',', '.')) ?? 0,
      volumeGrossLiters: double.tryParse(_gross.text.replaceAll(',', '.')),
      setupDate: widget.initial?.setupDate ?? DateTime.now(),
      type: _type,
      imagePath: widget.initial?.imagePath,
    );
    if (widget.initial == null) {
      provider.addAquarium(profile);
    } else {
      provider.updateAquarium(profile);
    }
    Navigator.pop(context);
  }
}

class AddInhabitantModal extends StatefulWidget {
  const AddInhabitantModal({super.key});

  @override
  State<AddInhabitantModal> createState() => _AddInhabitantModalState();
}

class _AddInhabitantModalState extends State<AddInhabitantModal> {
  final _name = TextEditingController();
  final _latin = TextEditingController();
  final _count = TextEditingController(text: '1');
  final _notes = TextEditingController();
  final _picker = ImagePicker();
  CreatureCategory _category = CreatureCategory.fish;
  PlantPosition? _position;
  String? _image;

  @override
  void dispose() {
    for (final controller in [_name, _latin, _count, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(title: const Text('Dodaj gatunek'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nazwa gatunkowa')), TextField(controller: _latin, decoration: const InputDecoration(labelText: 'Nazwa łacińska')), TextField(controller: _count, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Liczba sztuk')), DropdownButtonFormField<CreatureCategory>(initialValue: _category, decoration: const InputDecoration(labelText: 'Kategoria'), items: CreatureCategory.values.map((category) => DropdownMenuItem(value: category, child: Text(category.label))).toList(), onChanged: (value) => setState(() { _category = value!; if (_category != CreatureCategory.plant) _position = null; })), if (_category == CreatureCategory.plant) DropdownButtonFormField<PlantPosition>(initialValue: _position, decoration: const InputDecoration(labelText: 'Pozycja rośliny'), items: PlantPosition.values.map((position) => DropdownMenuItem(value: position, child: Text(position.label))).toList(), onChanged: (value) => setState(() => _position = value)), TextField(controller: _notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notatki')), Row(children: [OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: const Text('Galeria')), OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt_outlined), label: const Text('Aparat')), if (_image != null) const Expanded(child: Text(' Zdjęcie dodane', style: TextStyle(color: Colors.green)))]),])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')), FilledButton(onPressed: _save, child: const Text('Dodaj'))]);

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 80);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (mounted) setState(() => _image = 'data:image/${file.name.split('.').last};base64,${base64Encode(bytes)}');
  }

  void _save() {
    if (_name.text.trim().isEmpty) return;
    final provider = context.read<AquariumProvider>();
    provider.addInhabitant(Inhabitant(id: DateTime.now().microsecondsSinceEpoch.toString(), aquariumId: provider.activeAquariumId, name: _name.text.trim(), latinName: _latin.text.trim(), category: _category, count: int.tryParse(_count.text) ?? 1, addedDate: DateTime.now(), plantPosition: _position, notes: _notes.text.trim(), imagePath: _image));
    Navigator.pop(context);
  }
}