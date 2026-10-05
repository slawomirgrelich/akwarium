import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'services/aquarium_calculators_service.dart';
import 'services/pro_access_service.dart';
import 'widgets/pro_paywall_dialog.dart';

import 'package:akwarium/utils/app_snackbar.dart';

const _calculatorAccent = Color(0xFF10B981);

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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(l10n.calculatorsTitle),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: _calculatorAccent,
          labelColor: _calculatorAccent,
          unselectedLabelColor: isDark
              ? const Color(0xFF94A3B8)
              : const Color(0xFF64748B),
          tabs: [
            Tab(icon: const Icon(Icons.straighten), text: l10n.volumeTab),
            Tab(icon: const Icon(Icons.bubble_chart), text: l10n.co2Tab),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.eco_outlined),
                  const SizedBox(width: 6),
                  Text(l10n.fertilizersTab),
                  const SizedBox(width: 6),
                  const ProBadge(compact: true),
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
      body: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: _calculatorAccent,
          inactiveTrackColor: isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
          thumbColor: const Color(0xFF14B8A6),
          overlayColor: _calculatorAccent.withAlpha(35),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
          trackHeight: 5,
        ),
        child: TabBarView(
          controller: _tabs,
          physics: isProUser ? null : const NeverScrollableScrollPhysics(),
          children: const [
            _VolumeCalculator(),
            _Co2Calculator(),
            _FertilizerCalculator(),
          ],
        ),
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final length = _tryNumber(_length);
    final width = _tryNumber(_width);
    final height = _tryNumber(_height);
    final substrate = _tryNumber(_substrate);
    final glassThickness = _tryNumber(_glass);
    AquariumVolumeResult? result;
    if (length != null &&
        width != null &&
        height != null &&
        substrate != null &&
        glassThickness != null) {
      try {
        result = calculateVolume(
          lengthCm: length,
          widthCm: width,
          heightCm: height,
          substrateThicknessCm: substrate,
          decorationPercent: _decorations,
          glassThicknessCm: glassThickness / 10,
        );
      } on ArgumentError {
        result = null;
      }
    }
    return _CalculatorScroll(
      children: [
        _CalculatorIntro(
          title: l10n.volumeCalculator,
          subtitle: l10n.volumeCalculatorSubtitle,
        ),
        _GlassCard(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      label: l10n.length,
                      unit: 'cm',
                      controller: _length,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _NumberField(
                      label: l10n.width,
                      unit: 'cm',
                      controller: _width,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _NumberField(
                label: l10n.height,
                unit: 'cm',
                controller: _height,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              _NumberField(
                label: l10n.glassThickness,
                unit: 'mm',
                controller: _glass,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              _NumberField(
                label: l10n.substrateThickness,
                unit: 'cm',
                controller: _substrate,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(l10n.decorationsAndEquipment),
                  const Spacer(),
                  Text(
                    '${_decorations.round()}%',
                    style: TextStyle(
                      color: theme.primaryColor,
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
                activeColor: _calculatorAccent,
                onChanged: (value) => setState(() => _decorations = value),
              ),
            ],
          ),
        ),
        if (result != null)
          _VolumeResult(result: result)
        else
          _GlassCard(child: Text(l10n.calculatorInvalidValues)),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: result == null
              ? null
              : () => _saveCapacity(context, result!.netLiters),
          icon: const Icon(Icons.bookmark_add_outlined),
          label: Text(l10n.saveNetDefault),
        ),
      ],
    );
  }

  double? _tryNumber(TextEditingController controller) {
    final parsed = double.tryParse(controller.text.trim().replaceAll(',', '.'));
    return parsed != null && parsed.isFinite ? parsed : null;
  }

  Future<void> _saveCapacity(BuildContext context, double liters) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble('aquarium.default_net_liters', liters);
    if (!context.mounted) return;
    context.showAppSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!
              .netCapacitySaved(liters.toStringAsFixed(1)),
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
    final l10n = AppLocalizations.of(context)!;
    final result = calculateCo2(ph: _ph, kh: _kh);
    final statusColor = switch (result.status) {
      Co2Status.low => Colors.amber,
      Co2Status.optimal => Colors.greenAccent,
      Co2Status.high => Colors.redAccent,
    };
    final statusText = switch (result.status) {
      Co2Status.low => l10n.co2Low,
      Co2Status.optimal => l10n.co2Optimal,
      Co2Status.high => l10n.co2High,
    };
    return _CalculatorScroll(
      children: [
        _CalculatorIntro(
          title: l10n.co2Calculator,
          subtitle: l10n.co2CalculatorSubtitle,
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
                  color: _calculatorAccent,
                  fontSize: 34,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '< 15 ${l10n.co2Deficit}',
                    style: TextStyle(color: Colors.amber),
                  ),
                  Text(
                    '15-30 ${l10n.co2Optimum}',
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                  Text(
                    '> 30 ${l10n.co2Risk}',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _Co2MatrixMarker(mgPerLiter: result.mgPerLiter),
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final aquariumLiters = _tryNumber(_volume);
    final solutionMl = _tryNumber(_solution);
    final saltGrams = _tryNumber(_salt);
    final targetPpm = _tryNumber(_target);
    FertilizerDoseResult? result;
    if (aquariumLiters != null &&
        aquariumLiters > 0 &&
        solutionMl != null &&
        solutionMl > 0 &&
        saltGrams != null &&
        saltGrams >= 0 &&
        targetPpm != null &&
        targetPpm >= 0) {
      result = calculateFertilizerDose(
        aquariumLiters: aquariumLiters,
        solutionMl: solutionMl,
        saltGrams: saltGrams,
        targetPpm: targetPpm,
        saltFactor: _recipe.factor,
      );
    }
    return _CalculatorScroll(
      children: [
        _CalculatorIntro(
          title: l10n.fertilizerCalculatorTitle,
          subtitle: l10n.fertilizerCalculatorSubtitle,
        ),
        _GlassCard(
          child: Column(
            children: [
              _NumberField(
                label: l10n.netCapacity,
                unit: 'l',
                controller: _volume,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              _NumberField(
                label: l10n.solutionCapacity,
                unit: 'ml',
                controller: _solution,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              _NumberField(
                label: l10n.saltAmount,
                unit: 'g',
                controller: _salt,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SaltRecipe>(
                initialValue: _recipe,
                isExpanded: true,
                dropdownColor: theme.cardColor,
                decoration: InputDecoration(
                  labelText: l10n.baseSalt,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF475569)
                          : theme.dividerColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF475569)
                          : theme.dividerColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: _calculatorAccent, width: 2),
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
                label: l10n.weeklyTarget,
                unit: 'mg/l',
                controller: _target,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        if (result case final dose?) ...[
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_recipe.element} po 1 ml',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${dose.ppmPerMl.toStringAsFixed(3)} mg/l',
                  style: TextStyle(
                    color: _calculatorAccent,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${l10n.dailyDose}: ${dose.dailyMl.toStringAsFixed(2)} ml',
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                ),
                Text(
                  '${l10n.weeklyDose}: ${dose.weeklyMl.toStringAsFixed(2)} ml',
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                ),
              ],
            ),
          ),
        ] else
          _GlassCard(child: Text(l10n.calculatorInvalidValues)),
      ],
    );
  }

  double? _tryNumber(TextEditingController controller) {
    final parsed = double.tryParse(controller.text.trim().replaceAll(',', '.'));
    return parsed != null && parsed.isFinite ? parsed : null;
  }
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
          padding: const EdgeInsets.fromLTRB(16, 36, 16, 32),
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: theme.textTheme.headlineSmall?.color,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withAlpha(35)),
        boxShadow: [
          BoxShadow(color: theme.primaryColor.withAlpha(12), blurRadius: 18),
        ],
      ),
      child: child,
    );
  }
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        suffixText: unit,
        suffixStyle: TextStyle(color: _calculatorAccent),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF475569) : theme.dividerColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF475569) : theme.dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: _calculatorAccent, width: 2),
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
            const Spacer(),
            Text(
              display,
              style: TextStyle(
                color: _calculatorAccent,
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
          activeColor: _calculatorAccent,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _VolumeResult extends StatelessWidget {
  const _VolumeResult({required this.result});
  final AquariumVolumeResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return _GlassCard(
      child: Column(
        children: [
          Text(
            '${result.netLiters.toStringAsFixed(1)} l',
            style: TextStyle(
              color: _calculatorAccent,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            l10n.actualWaterVolume,
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: result.grossLiters <= 0
                ? 0
                : result.netLiters / result.grossLiters,
            minHeight: 12,
            borderRadius: BorderRadius.circular(8),
            color: theme.primaryColor,
            backgroundColor: theme.dividerColor,
          ),
          const SizedBox(height: 12),
          _BreakdownRow(
            label: l10n.netWater,
            value: result.netLiters,
            color: theme.primaryColor,
          ),
          _BreakdownRow(
            label: l10n.substrate,
            value: result.substrateLiters,
            color: Colors.amber,
          ),
          _BreakdownRow(
            label: l10n.rocksWood,
            value: result.decorationsLiters,
            color: Colors.deepOrangeAccent,
          ),
          _BreakdownRow(
            label: l10n.glass,
            value: result.glassVolumeLiters,
            color: Colors.lightBlueAccent,
          ),
          Text(
            l10n.grossVolumeValue(result.grossLiters.toStringAsFixed(1)),
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.estimatedTotalWeight(result.totalWeightKg.toStringAsFixed(1)),
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          ),
          const Spacer(),
          Text(
            '${value.toStringAsFixed(1)} l',
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _Co2MatrixMarker extends StatelessWidget {
  const _Co2MatrixMarker({required this.mgPerLiter});
  final double mgPerLiter;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.amber, Colors.green, Colors.green, Colors.red],
          stops: [0, 1 / 3, 2 / 3, 1],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: Alignment(co2ScalePosition(mgPerLiter) * 2 - 1, 0),
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF0F172A), width: 3),
          ),
        ),
      ),
    );
  }
}
