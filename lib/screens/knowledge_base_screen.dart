import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../data/aquarium_knowledge_base.dart';
import '../models/aquarium_model.dart';
import '../aquarium_management_screen.dart';
import '../services/aquarium_diagnostic_service.dart';
import '../utils/aquarium_diagnostic_localization.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final isPro = context.watch<ProAccessService>().isProUser;
    final provider = context.watch<AquariumProvider>();
    final aquarium = provider.selectedAquarium;
    if (aquarium == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.knowledgeBaseTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.knowledgeBaseAddAquariumPrompt),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const AquariumManagementScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addNewAquarium),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final latestTest = provider.waterTests.isEmpty
        ? null
        : provider.waterTests.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.knowledgeBaseTitle),
        actions: [
          IconButton(
            tooltip: l10n.diagnoseWithProTooltip,
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
                          decoration: InputDecoration(
                            labelText: l10n.searchAtlas,
                            hintText: l10n.atlasSearchPlaceholder,
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
                                  label: Text(_categoryLabel(l10n, category)),
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
                            Expanded(
                              child: Text(
                                l10n.knowledgeForStableTank,
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
                    compatibleLabel: AppLocalizations.of(context)!
                        .idealForYourTank,
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
      _query.trim().isEmpty ||
      text.toLowerCase().contains(_query.toLowerCase());

  bool _isCompatible(
    FishSpeciesModel fish,
    AquariumProfile aquarium,
    WaterTest? latestTest,
  ) {
    if (aquarium.volumeNetLiters < fish.minimumLiters) return false;
    if (latestTest == null) return true;
    final ph = latestTest.ph;
    final temperature = latestTest.temp;
    final gh = latestTest.gh;
    return (ph == null || (ph >= fish.phMin && ph <= fish.phMax)) &&
        (temperature == null ||
            (temperature >= fish.temperatureMin &&
                temperature <= fish.temperatureMax)) &&
        (gh == null || (gh >= fish.ghMin && gh <= fish.ghMax));
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
    final l10n = AppLocalizations.of(context)!;
    final name = Localizations.localeOf(context).languageCode == 'en'
        ? fish.latinName
        : fish.polishName;
    _showDetails(context, name, fish.latinName, [
      l10n.phRangeLabel(fish.phMin, fish.phMax),
      l10n.temperatureRangeLabel(fish.temperatureMin, fish.temperatureMax),
      l10n.ghRangeLabel(fish.ghMin, fish.ghMax),
      l10n.speciesMinimumVolumeFrom(fish.minimumLiters),
      l10n.difficultyLabel(_localizedDifficulty(l10n, fish.difficulty)),
      l10n.temperamentLabel(_localizedTemperament(l10n, fish.temperament)),
    ]);
  }

  void _showPlantDetails(BuildContext context, PlantSpeciesModel plant) {
    final l10n = AppLocalizations.of(context)!;
    _showDetails(context, plant.name, l10n.plantRequirementsTitle, [
      '${l10n.lightLabel}: ${_localizedLight(l10n, plant.lightRequirements)}',
      '${l10n.co2Label}: ${_localizedCo2(l10n, plant.co2Requirements)}',
      '${l10n.growthRateLabel}: ${_localizedGrowth(l10n, plant.growthRate)}',
      '${l10n.positionLabel}: ${_localizedPlantPosition(l10n, plant.position)}',
    ]);
  }

  void _showAlgaeDetails(BuildContext context, AlgaeModel algae) {
    final l10n = AppLocalizations.of(context)!;
    _showDetails(
      context,
      _localizedKnowledgeText(l10n, algae.name),
      l10n.algaeSymptomsTitle,
      [
        '${l10n.causesLabel}: ${algae.causes.map((value) => _localizedKnowledgeText(l10n, value)).join(', ')}',
        '${l10n.symptomsLabel}: ${algae.symptoms.map((value) => _localizedKnowledgeText(l10n, value)).join(', ')}',
        '${l10n.controlPlanLabel}: ${algae.controlSteps.map((value) => _localizedKnowledgeText(l10n, value)).join(' ')}',
      ],
    );
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

  String _categoryLabel(AppLocalizations l10n, KnowledgeCategory category) {
    switch (category) {
      case KnowledgeCategory.fish:
        return l10n.filterFish;
      case KnowledgeCategory.plants:
        return l10n.filterPlants;
      case KnowledgeCategory.algae:
        return l10n.knowledgeCategoryAlgae;
    }
  }

  String _localizedDifficulty(AppLocalizations l10n, String value) =>
      switch (value.toLowerCase()) {
        'łatwa' || 'łatwy' => l10n.difficultyEasy,
        'bardzo łatwa' || 'bardzo łatwy' => l10n.difficultyVeryEasy,
        'średnia' || 'średni' => l10n.difficultyMedium,
        'trudna' || 'trudny' => l10n.difficultyHard,
        'zaawansowana' || 'zaawansowany' => l10n.difficultyAdvanced,
        _ => value,
      };

  String _localizedTemperament(AppLocalizations l10n, String value) =>
      switch (value.toLowerCase()) {
        'łagodny, stadny' => l10n.temperamentShoalingPeaceful,
        'łagodna, stadna' => l10n.temperamentShoalingPeacefulFeminine,
        'łagodny, aktywny' => l10n.temperamentActivePeaceful,
        'spokojna, terytorialna' => l10n.temperamentTerritorialPeaceful,
        'samiec terytorialny' => l10n.temperamentTerritorialMale,
        _ => value,
      };
}

String _localizedLight(AppLocalizations l10n, String value) =>
    switch (value.toLowerCase()) {
      'niskie' => l10n.lightLow,
      'niskie do średniego' => l10n.lightLowMedium,
      'średnie' => l10n.lightMedium,
      'średnie do wysokiego' => l10n.lightMediumHigh,
      _ => value,
    };

String _localizedCo2(AppLocalizations l10n, String value) =>
    switch (value.toLowerCase()) {
      'niewymagane' => l10n.co2NotRequired,
      'opcjonalne' => l10n.co2Optional,
      'zalecane' => l10n.co2Recommended,
      _ => value,
    };

String _localizedGrowth(AppLocalizations l10n, String value) =>
    switch (value.toLowerCase()) {
      'wolne' => l10n.growthSlow,
      'średnie' => l10n.growthMedium,
      'szybkie' => l10n.growthFast,
      _ => value,
    };

String _localizedPlantPosition(AppLocalizations l10n, String value) =>
    switch (value.toLowerCase()) {
      'środek / korzeń' => l10n.plantPositionMiddleRoot,
      'środek / tył' => l10n.plantPositionMiddleBackground,
      'środek' => l10n.plantPositionMiddle,
      'tył' => l10n.plantPositionBack,
      'przód' => l10n.plantPositionFront,
      _ => value,
    };

String _localizedKnowledgeText(AppLocalizations l10n, String value) =>
    switch (value) {
      'Krasnorosty' => l10n.algaeNameBlackBeard,
      'Zielenice' => l10n.algaeNameGreen,
      'Sinice' => l10n.algaeNameCyanobacteria,
      'Okrzemki' => l10n.algaeNameDiatoms,
      'Wahania CO2' => l10n.algaeCauseCo2Fluctuations,
      'Słaba cyrkulacja' => l10n.algaeCausePoorCirculation,
      'Niestabilne nawożenie' => l10n.algaeCauseUnstableFertilization,
      'Nadmiar światła' => l10n.algaeCauseExcessLight,
      'Niedobór PO4' => l10n.algaeCausePo4Deficiency,
      'Niestabilne CO2' => l10n.algaeCauseUnstableCo2,
      'Brak NO3' => l10n.algaeCauseNo3Deficiency,
      'Zastoiny wody' => l10n.algaeCauseStagnantWater,
      'Nadmiar materii organicznej' => l10n.algaeCauseOrganicMatter,
      'Nowy zbiornik' => l10n.algaeCauseNewTank,
      'Krzemiany w wodzie' => l10n.algaeCauseSilicates,
      'Niedojrzały filtr' => l10n.algaeCauseImmatureFilter,
      'Czarne lub czerwone kępki na liściach i dekoracjach' =>
        l10n.algaeSymptomBlackTufts,
      'Zielony nalot na szybach lub punktowe plamy na liściach' =>
        l10n.algaeSymptomGreenFilm,
      'Śluzowata niebieskozielona warstwa o charakterystycznym zapachu' =>
        l10n.algaeSymptomCyanobacteriaMat,
      'Brązowy pył na szybach, podłożu i dekoracjach' =>
        l10n.algaeSymptomBrownDust,
      'Ustabilizuj podawanie CO2 i popraw cyrkulację.' =>
        l10n.algaeActionStabilizeCo2,
      'Usuń mechanicznie porażone liście i dekoracje.' =>
        l10n.algaeActionRemoveAffected,
      'Ogranicz światło do 6–8 godzin i obserwuj zbiornik przez tydzień.' =>
        l10n.algaeActionReduceLight,
      'Skróć świecenie i regularnie czyść szyby.' => l10n.algaeActionCleanGlass,
      'Sprawdź PO4 i uzupełniaj je stopniowo.' => l10n.algaeActionSupplementPo4,
      'Zwiększ masę szybko rosnących roślin.' => l10n.algaeActionAddFastPlants,
      'Usuń matę mechanicznie i wykonaj większą podmianę wody.' =>
        l10n.algaeActionRemoveMat,
      'Przywróć mierzalny poziom NO3 i popraw przepływ.' =>
        l10n.algaeActionRestoreNo3,
      'Ogranicz światło oraz karmienie do czasu ustabilizowania zbiornika.' =>
        l10n.algaeActionReduceFeeding,
      'Usuwaj nalot przy podmianach i utrzymuj regularność prac.' =>
        l10n.algaeActionCleanDiatoms,
      'Daj biologii czas na dojrzewanie i nie myj całego wkładu naraz.' =>
        l10n.algaeActionMatureFilter,
      'Sprawdź krzemiany w wodzie kranowej, jeśli problem trwa długo.' =>
        l10n.algaeActionCheckSilicates,
      _ => value,
    };

class _FishCard extends StatelessWidget {
  const _FishCard({
    required this.fish,
    required this.compatible,
    required this.compatibleLabel,
    required this.onTap,
  });

  final FishSpeciesModel fish;
  final bool compatible;
  final String compatibleLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayName = Localizations.localeOf(context).languageCode == 'en'
        ? fish.latinName
        : fish.polishName;
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
                    Text(
                      displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      fish.latinName,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'pH ${fish.phMin}–${fish.phMax} · min. ${fish.minimumLiters} l',
                    ),
                    if (compatible)
                      Text(
                        compatibleLabel,
                        style: TextStyle(
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                compatible ? Icons.check_circle : Icons.chevron_right,
                color: compatible ? Colors.teal : null,
              ),
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
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.eco_outlined)),
        title: Text(plant.name),
        subtitle: Text(
          '${_localizedPlantPosition(l10n, plant.position)} · '
          '${l10n.lightLabel}: ${_localizedLight(l10n, plant.lightRequirements)}',
        ),
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
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.grass)),
        title: Text(_localizedKnowledgeText(l10n, algae.name)),
        subtitle: Text(_localizedKnowledgeText(l10n, algae.symptoms.first)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class AquariumDiagnosticScreen extends StatefulWidget {
  const AquariumDiagnosticScreen({
    required this.aquarium,
    this.latestTest,
    super.key,
  });

  final AquariumProfile aquarium;
  final WaterTest? latestTest;

  @override
  State<AquariumDiagnosticScreen> createState() =>
      _AquariumDiagnosticScreenState();
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.smartDiagnosis),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 12), child: ProBadge()),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            widget.aquarium.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(l10n.smartDiagnosisSubtitle),
          const SizedBox(height: 18),
          _numberField(_ph, l10n.currentPh),
          _numberField(_previousPh, l10n.previousPh),
          _numberField(_no3, 'NO3 (mg/l)'),
          _numberField(_po4, 'PO4 (mg/l)'),
          _numberField(_co2, 'CO2 (ppm)'),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(l10n.lightingTime),
                      const Spacer(),
                      Text('${_lightHours.toStringAsFixed(0)} h'),
                    ],
                  ),
                  Slider(
                    value: _lightHours,
                    min: 4,
                    max: 12,
                    divisions: 8,
                    label: '${_lightHours.toStringAsFixed(0)} h',
                    onChanged: (value) => setState(() => _lightHours = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _diagnose,
            icon: const Icon(Icons.auto_awesome),
            label: Text(l10n.runProDiagnosis),
          ),
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
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.redfieldRatio == null
                  ? l10n.diagnosticRedfieldRatioNoData
                  : l10n.diagnosticRedfieldRatio(
                      result.redfieldRatio!.toStringAsFixed(1),
                    ),
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
                title: Text(diagnosticFindingTitle(l10n, finding.key)),
                subtitle: Text(diagnosticFindingMessage(l10n, finding.key)),
              ),
            ),
            const Divider(),
            Text(
              l10n.diagnosticActionPlanTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...result.actionPlan.indexed.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${item.$1 + 1}. ${diagnosticAction(l10n, item.$2)}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
