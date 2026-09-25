import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/aquarium_knowledge_base.dart';
import '../models/aquarium_model.dart';
import '../services/aquarium_diagnostic_service.dart';
import '../services/pro_access_service.dart';
import '../widgets/pro_paywall_dialog.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  KnowledgeCategory _category = KnowledgeCategory.fish;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isPro = context.watch<ProAccessService>().isProUser;
    final aquarium = context.watch<AquariumProvider>().activeAquarium;
    final provider = context.watch<AquariumProvider>();
    final latestTest = provider.waterTests.isEmpty
      ? null
      : provider.waterTests.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Baza wiedzy i Atlas'),
        actions: [
          IconButton(
            tooltip: 'Diagnoza PRO',
            onPressed: () => _openDiagnostic(context, aquarium, latestTest),
            icon: const Icon(Icons.health_and_safety_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          onChanged: (value) => setState(() => _query = value),
                          decoration: const InputDecoration(
                            labelText: 'Szukaj w Atlasie',
                            hintText: 'np. neon, anubias, zielenice',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: KnowledgeCategory.values.map((category) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(_categoryLabel(category)),
                                  selected: _category == category,
                                  onSelected: (_) =>
                                      setState(() => _category = category),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Wiedza dla stabilnego zbiornika',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (!isPro) const ProBadge(compact: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ..._buildResults(context, aquarium, latestTest, isPro),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResults(
    BuildContext context,
    AquariumProfile aquarium,
    WaterTest? latestTest,
    bool isPro,
  ) {
    switch (_category) {
      case KnowledgeCategory.fish:
        final source = isPro ? fishSpecies : fishSpecies.take(2).toList();
        return source
            .where((fish) => _matches('${fish.polishName} ${fish.latinName}'))
            .map(
              (fish) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: _FishCard(
                    fish: fish,
                    compatible: _isCompatible(fish, aquarium, latestTest),
                    onTap: () => _showFishDetails(context, fish),
                  ),
                ),
              ),
            )
            .toList();
      case KnowledgeCategory.plants:
        final source = isPro ? plantSpecies : plantSpecies.take(2).toList();
        return source
            .where((plant) => _matches(plant.name))
            .map(
              (plant) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: _PlantCard(
                    plant: plant,
                    onTap: () => _showPlantDetails(context, plant),
                  ),
                ),
              ),
            )
            .toList();
      case KnowledgeCategory.algae:
        return algaeSpecies
            .where((algae) => _matches(algae.name))
            .map(
              (algae) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: _AlgaeCard(
                    algae: algae,
                    onTap: () => _showAlgaeDetails(context, algae),
                  ),
                ),
              ),
            )
            .toList();
    }
  }

  bool _matches(String text) =>
      _query.trim().isEmpty || text.toLowerCase().contains(_query.toLowerCase());

  bool _isCompatible(
    FishSpeciesModel fish,
    AquariumProfile aquarium,
    WaterTest? latestTest,
  ) {
    if (aquarium.volumeNetLiters < fish.minimumLiters) return false;
    if (latestTest == null) return true;
    return latestTest.ph >= fish.phMin &&
        latestTest.ph <= fish.phMax &&
        latestTest.temp >= fish.temperatureMin &&
        latestTest.temp <= fish.temperatureMax &&
        latestTest.gh >= fish.ghMin &&
        latestTest.gh <= fish.ghMax;
  }

  void _openDiagnostic(
    BuildContext context,
    AquariumProfile aquarium,
    WaterTest? latestTest,
  ) {
    if (!context.read<ProAccessService>().isProUser) {
      ProPaywallDialog.show(
        context,
        headline: 'Zdiagnozuj i uratuj swoje akwarium z Akwarysta PRO',
      );
      return;
    }
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => AquariumDiagnosticScreen(
          aquarium: aquarium,
          latestTest: latestTest,
        ),
      ),
    );
  }

  void _showFishDetails(BuildContext context, FishSpeciesModel fish) {
    _showDetails(
      context,
      fish.polishName,
      fish.latinName,
      [
        'pH: ${fish.phMin}–${fish.phMax}',
        'Temperatura: ${fish.temperatureMin}–${fish.temperatureMax}°C',
        'GH: ${fish.ghMin}–${fish.ghMax}',
        'Minimum: ${fish.minimumLiters} l',
        'Trudność: ${fish.difficulty}',
        'Usposobienie: ${fish.temperament}',
      ],
    );
  }

  void _showPlantDetails(BuildContext context, PlantSpeciesModel plant) {
    _showDetails(context, plant.name, 'Wymagania rośliny', [
      'Światło: ${plant.lightRequirements}',
      'CO2: ${plant.co2Requirements}',
      'Tempo wzrostu: ${plant.growthRate}',
      'Pozycja: ${plant.position}',
    ]);
  }

  void _showAlgaeDetails(BuildContext context, AlgaeModel algae) {
    _showDetails(context, algae.name, 'Objawy i zwalczanie', [
      'Przyczyny: ${algae.causes.join(', ')}',
      'Objawy: ${algae.symptoms.join(', ')}',
      'Plan: ${algae.controlSteps.join(' ')}',
    ]);
  }

  void _showDetails(
    BuildContext context,
    String title,
    String subtitle,
    List<String> lines,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 16),
              ...lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(line),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(KnowledgeCategory category) {
    switch (category) {
      case KnowledgeCategory.fish:
        return 'Ryby';
      case KnowledgeCategory.plants:
        return 'Rośliny';
      case KnowledgeCategory.algae:
        return 'Glony';
    }
  }
}

class _FishCard extends StatelessWidget {
  const _FishCard({required this.fish, required this.compatible, required this.onTap});

  final FishSpeciesModel fish;
  final bool compatible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(child: Icon(Icons.phishing_outlined)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fish.polishName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(fish.latinName, style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 6),
                    Text('pH ${fish.phMin}–${fish.phMax} · min. ${fish.minimumLiters} l'),
                    if (compatible)
                      Text(
                        'Idealne do Twojego akwarium',
                        style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                  ],
                ),
              ),
              Icon(compatible ? Icons.check_circle : Icons.chevron_right, color: compatible ? Colors.teal : null),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  const _PlantCard({required this.plant, required this.onTap});

  final PlantSpeciesModel plant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.eco_outlined)),
        title: Text(plant.name),
        subtitle: Text('${plant.position} · Światło: ${plant.lightRequirements}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _AlgaeCard extends StatelessWidget {
  const _AlgaeCard({required this.algae, required this.onTap});

  final AlgaeModel algae;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.grass)),
        title: Text(algae.name),
        subtitle: Text(algae.symptoms.first),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class AquariumDiagnosticScreen extends StatefulWidget {
  const AquariumDiagnosticScreen({required this.aquarium, this.latestTest, super.key});

  final AquariumProfile aquarium;
  final WaterTest? latestTest;

  @override
  State<AquariumDiagnosticScreen> createState() => _AquariumDiagnosticScreenState();
}

class _AquariumDiagnosticScreenState extends State<AquariumDiagnosticScreen> {
  final _service = AquariumDiagnosticService();
  late final TextEditingController _ph;
  late final TextEditingController _no3;
  late final TextEditingController _po4;
  late final TextEditingController _co2;
  late final TextEditingController _previousPh;
  double _lightHours = 8;
  AquariumDiagnosticResult? _result;

  @override
  void initState() {
    super.initState();
    final test = widget.latestTest;
    _ph = TextEditingController(text: (test?.ph ?? 7).toString());
    _no3 = TextEditingController(text: (test?.no3 ?? 15).toString());
    _po4 = TextEditingController(text: (test?.po4 ?? 1).toString());
    _co2 = TextEditingController(text: '20');
    _previousPh = TextEditingController(text: (test?.ph ?? 7).toString());
  }

  @override
  void dispose() {
    for (final controller in [_ph, _no3, _po4, _co2, _previousPh]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inteligentna diagnoza'),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: ProBadge())],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(widget.aquarium.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          const Text('Wprowadź aktualne dane, aby otrzymać plan działania.'),
          const SizedBox(height: 18),
          _numberField(_ph, 'Aktualne pH'),
          _numberField(_previousPh, 'pH z poprzedniego pomiaru'),
          _numberField(_no3, 'NO3 (mg/l)'),
          _numberField(_po4, 'PO4 (mg/l)'),
          _numberField(_co2, 'CO2 (ppm)'),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(children: [const Text('Czas świecenia'), const Spacer(), Text('${_lightHours.toStringAsFixed(0)} h')]),
                  Slider(value: _lightHours, min: 4, max: 12, divisions: 8, label: '${_lightHours.toStringAsFixed(0)} h', onChanged: (value) => setState(() => _lightHours = value)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(onPressed: _diagnose, icon: const Icon(Icons.auto_awesome), label: const Text('Uruchom diagnozę PRO')),
          if (_result != null) ...[
            const SizedBox(height: 20),
            _DiagnosticResultCard(result: _result!),
          ],
        ],
      ),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  void _diagnose() {
    setState(() {
      _result = _service.diagnose(
        AquariumDiagnosticInput(
          ph: _number(_ph),
          no3: _number(_no3),
          po4: _number(_po4),
          co2Ppm: _number(_co2),
          previousPh: _number(_previousPh),
          lightHours: _lightHours,
        ),
      );
    });
  }

  double _number(TextEditingController controller) =>
      double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
}

class _DiagnosticResultCard extends StatelessWidget {
  const _DiagnosticResultCard({required this.result});

  final AquariumDiagnosticResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.redfieldRatio == null
                  ? 'Stosunek NO3:PO4: brak danych'
                  : 'Stosunek NO3:PO4: ${result.redfieldRatio!.toStringAsFixed(1)}:1',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            ...result.findings.map(
              (finding) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  finding.severity == DiagnosticSeverity.critical
                      ? Icons.error
                      : finding.severity == DiagnosticSeverity.warning
                      ? Icons.warning_amber
                      : Icons.info_outline,
                  color: finding.severity == DiagnosticSeverity.critical
                      ? Colors.red
                      : finding.severity == DiagnosticSeverity.warning
                      ? Colors.orange
                      : Colors.teal,
                ),
                title: Text(finding.title),
                subtitle: Text(finding.message),
              ),
            ),
            const Divider(),
            const Text('Plan działania', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...result.actionPlan.indexed.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('${item.$1 + 1}. ${item.$2}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}