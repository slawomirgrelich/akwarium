import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'services/aquarium_calculators_service.dart';
import 'services/pro_access_service.dart';
import 'widgets/pro_paywall_dialog.dart';

const _calculatorBackground = Color(0xFF12181F);
const _calculatorPanel = Color(0xFF1C2730);
const _calculatorCyan = Color(0xFF00E5FF);

class AquariumCalculatorsScreen extends StatefulWidget {
  const AquariumCalculatorsScreen({super.key});

  @override
  State<AquariumCalculatorsScreen> createState() =>
      _AquariumCalculatorsScreenState();
}

class _AquariumCalculatorsScreenState extends State<AquariumCalculatorsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);
  int _lastAllowedTab = 0;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProUser = context.watch<ProAccessService>().isProUser;
    return Scaffold(
      backgroundColor: _calculatorBackground,
      appBar: AppBar(
        backgroundColor: _calculatorBackground,
        foregroundColor: Colors.white,
        title: const Text('Kalkulatory akwarystyczne'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: _calculatorCyan,
          labelColor: _calculatorCyan,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.straighten), text: 'Objętość'),
            Tab(icon: Icon(Icons.bubble_chart), text: 'CO2'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.eco_outlined),
                  SizedBox(width: 6),
                  Text('Nawozy'),
                  SizedBox(width: 6),
                  ProBadge(compact: true),
                ],
              ),
            ),
          ],
          onTap: (index) {
            if (index == 2 && !isProUser) {
              _tabs.animateTo(_lastAllowedTab);
              ProPaywallDialog.show(context);
              return;
            }
            _lastAllowedTab = index;
          },
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        physics: isProUser ? null : const NeverScrollableScrollPhysics(),
        children: const [
          _VolumeCalculator(),
          _Co2Calculator(),
          _FertilizerCalculator(),
        ],
      ),
    );
  }
}

class _VolumeCalculator extends StatefulWidget {
  const _VolumeCalculator();

  @override
  State<_VolumeCalculator> createState() => _VolumeCalculatorState();
}

class _VolumeCalculatorState extends State<_VolumeCalculator> {
  final _length = TextEditingController(text: '100');
  final _width = TextEditingController(text: '40');
  final _height = TextEditingController(text: '45');
  final _substrate = TextEditingController(text: '5');
  final _glass = TextEditingController(text: '6');
  double _decorations = 10;

  @override
  void dispose() {
    for (final controller in [_length, _width, _height, _substrate, _glass]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = calculateVolume(
      lengthCm: _number(_length),
      widthCm: _number(_width),
      heightCm: _number(_height),
      substrateThicknessCm: _number(_substrate),
      decorationPercent: _decorations,
      glassThicknessCm: _number(_glass) / 10,
    );
    return _CalculatorScroll(
      children: [
        const _CalculatorIntro(
          title: 'Objętość zbiornika',
          subtitle: 'Porównaj pojemność brutto z realną ilością wody.',
        ),
        _GlassCard(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      label: 'Długość',
                      unit: 'cm',
                      controller: _length,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _NumberField(
                      label: 'Szerokość',
                      unit: 'cm',
                      controller: _width,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _NumberField(
                label: 'Wysokość',
                unit: 'cm',
                controller: _height,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              _NumberField(
                label: 'Grubość szkła',
                unit: 'mm',
                controller: _glass,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              _NumberField(
                label: 'Grubość podłoża',
                unit: 'cm',
                controller: _substrate,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text(
                    'Dekoracje i sprzęt',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const Spacer(),
                  Text(
                    '${_decorations.round()}%',
                    style: const TextStyle(
                      color: _calculatorCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _decorations,
                min: 5,
                max: 20,
                divisions: 15,
                activeColor: _calculatorCyan,
                onChanged: (value) => setState(() => _decorations = value),
              ),
            ],
          ),
        ),
        _VolumeResult(result: result),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => _saveCapacity(context, result.netLiters),
          icon: const Icon(Icons.bookmark_add_outlined),
          label: const Text('Zapisz netto jako domyślne'),
        ),
      ],
    );
  }

  double _number(TextEditingController controller) =>
      double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;

  Future<void> _saveCapacity(BuildContext context, double liters) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble('aquarium.default_net_liters', liters);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Zapisano pojemność netto: ${liters.toStringAsFixed(1)} l',
        ),
      ),
    );
  }
}

class _Co2Calculator extends StatefulWidget {
  const _Co2Calculator();

  @override
  State<_Co2Calculator> createState() => _Co2CalculatorState();
}

class _Co2CalculatorState extends State<_Co2Calculator> {
  double _ph = 7;
  double _kh = 6;

  @override
  Widget build(BuildContext context) {
    final result = calculateCo2(ph: _ph, kh: _kh);
    final statusColor = switch (result.status) {
      Co2Status.low => Colors.amber,
      Co2Status.optimal => Colors.greenAccent,
      Co2Status.high => Colors.redAccent,
    };
    final statusText = switch (result.status) {
      Co2Status.low => 'Niedobór CO2 - słaby wzrost roślin',
      Co2Status.optimal => 'Poziom optymalny - bezpieczny dla ryb',
      Co2Status.high => 'Nadmiar CO2 - ryzyko przyduchy dla ryb',
    };
    return _CalculatorScroll(
      children: [
        const _CalculatorIntro(
          title: 'Kalkulator CO2',
          subtitle:
              'Wybierz pH i KH, aby sprawdzić stężenie rozpuszczonego CO2.',
        ),
        _GlassCard(
          child: Column(
            children: [
              _SliderRow(
                label: 'pH',
                value: _ph,
                min: 6,
                max: 8,
                divisions: 20,
                display: _ph.toStringAsFixed(1),
                onChanged: (value) => setState(() => _ph = value),
              ),
              _SliderRow(
                label: 'KH',
                value: _kh,
                min: 1,
                max: 20,
                divisions: 19,
                display: '${_kh.round()} dKH',
                onChanged: (value) => setState(() => _kh = value),
              ),
            ],
          ),
        ),
        _GlassCard(
          child: Column(
            children: [
              Text(
                '${result.mgPerLiter.toStringAsFixed(1)} mg/l',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                statusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('< 15 niedobór', style: TextStyle(color: Colors.amber)),
                  Text(
                    '15-30 optimum',
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                  Text(
                    '> 30 ryzyko',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _Co2MatrixMarker(ph: _ph, kh: _kh),
            ],
          ),
        ),
      ],
    );
  }
}

class _FertilizerCalculator extends StatefulWidget {
  const _FertilizerCalculator();

  @override
  State<_FertilizerCalculator> createState() => _FertilizerCalculatorState();
}

class _FertilizerCalculatorState extends State<_FertilizerCalculator> {
  final _volume = TextEditingController(text: '100');
  final _solution = TextEditingController(text: '500');
  final _salt = TextEditingController(text: '50');
  final _target = TextEditingController(text: '10');
  SaltRecipe _recipe = saltRecipes.first;

  @override
  void dispose() {
    for (final controller in [_volume, _solution, _salt, _target]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = calculateFertilizerDose(
      aquariumLiters: _number(_volume),
      solutionMl: _number(_solution),
      saltGrams: _number(_salt),
      targetPpm: _number(_target),
      saltFactor: _recipe.factor,
    );
    return _CalculatorScroll(
      children: [
        const _CalculatorIntro(
          title: 'Dawkowanie nawozów',
          subtitle: 'Sprawdź, ile pierwiastka wnosi każdy mililitr roztworu.',
        ),
        _GlassCard(
          child: Column(
            children: [
              _NumberField(
                label: 'Pojemność netto',
                unit: 'l',
                controller: _volume,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              _NumberField(
                label: 'Pojemność roztworu',
                unit: 'ml',
                controller: _solution,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              _NumberField(
                label: 'Wsypana sól',
                unit: 'g',
                controller: _salt,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SaltRecipe>(
                initialValue: _recipe,
                isExpanded: true,
                dropdownColor: _calculatorPanel,
                decoration: const InputDecoration(
                  labelText: 'Sól bazowa',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: true,
                  fillColor: _calculatorPanel,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: _calculatorCyan, width: 2),
                  ),
                ),
                items: saltRecipes
                    .map(
                      (recipe) => DropdownMenuItem(
                        value: recipe,
                        child: Text('${recipe.name} - ${recipe.element}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _recipe = value!),
              ),
              const SizedBox(height: 16),
              _NumberField(
                label: 'Cel tygodniowy',
                unit: 'mg/l',
                controller: _target,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_recipe.element} po 1 ml',
                style: const TextStyle(
                  color: _calculatorCyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${result.ppmPerMl.toStringAsFixed(3)} mg/l',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Dawka dzienna: ${result.dailyMl.toStringAsFixed(2)} ml',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                'Dawka tygodniowa: ${result.weeklyMl.toStringAsFixed(2)} ml',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _number(TextEditingController controller) =>
      double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
}

class _CalculatorScroll extends StatelessWidget {
  const _CalculatorScroll({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final child in children)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: child,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalculatorIntro extends StatelessWidget {
  const _CalculatorIntro({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: Colors.white60)),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _calculatorPanel.withAlpha(225),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _calculatorCyan.withAlpha(35)),
      boxShadow: [
        BoxShadow(color: _calculatorCyan.withAlpha(12), blurRadius: 18),
      ],
    ),
    child: child,
  );
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.unit,
    required this.controller,
    required this.onChanged,
  });
  final String label;
  final String unit;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60),
      suffixText: unit,
      suffixStyle: const TextStyle(color: _calculatorCyan),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: _calculatorPanel,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.white24),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _calculatorCyan, width: 2),
      ),
    ),
  );
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(
            display,
            style: const TextStyle(
              color: _calculatorCyan,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        activeColor: _calculatorCyan,
        onChanged: onChanged,
      ),
    ],
  );
}

class _VolumeResult extends StatelessWidget {
  const _VolumeResult({required this.result});
  final AquariumVolumeResult result;

  @override
  Widget build(BuildContext context) => _GlassCard(
    child: Column(
      children: [
        Text(
          '${result.netLiters.toStringAsFixed(1)} l',
          style: const TextStyle(
            color: _calculatorCyan,
            fontSize: 38,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Text(
          'Rzeczywista objętość wody',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 14),
        LinearProgressIndicator(
          value: result.grossLiters <= 0
              ? 0
              : result.netLiters / result.grossLiters,
          minHeight: 12,
          borderRadius: BorderRadius.circular(8),
          color: _calculatorCyan,
          backgroundColor: Colors.white12,
        ),
        const SizedBox(height: 12),
        _BreakdownRow(
          label: 'Woda netto',
          value: result.netLiters,
          color: _calculatorCyan,
        ),
        _BreakdownRow(
          label: 'Podłoże',
          value: result.substrateLiters,
          color: Colors.amber,
        ),
        _BreakdownRow(
          label: 'Skały / drewno',
          value: result.decorationsLiters,
          color: Colors.deepOrangeAccent,
        ),
        _BreakdownRow(
          label: 'Szkło',
          value: result.glassVolumeLiters,
          color: Colors.lightBlueAccent,
        ),
        Text(
          'Brutto: ${result.grossLiters.toStringAsFixed(1)} l',
          style: const TextStyle(color: Colors.white54),
        ),
        const SizedBox(height: 12),
        Text(
          'Szacowany ciężar całkowity: ${result.totalWeightKg.toStringAsFixed(1)} kg',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
        const Spacer(),
        Text(
          '${value.toStringAsFixed(1)} l',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

class _Co2MatrixMarker extends StatelessWidget {
  const _Co2MatrixMarker({required this.ph, required this.kh});
  final double ph;
  final double kh;

  @override
  Widget build(BuildContext context) => Container(
    height: 100,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Colors.amber, Colors.green, Colors.red],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Align(
      alignment: Alignment(((ph - 6) / 2 * 2) - 1, ((kh - 1) / 19 * 2) - 1),
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _calculatorBackground, width: 3),
        ),
      ),
    ),
  );
}
