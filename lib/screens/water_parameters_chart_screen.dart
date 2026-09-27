import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/aquarium_firestore_model.dart';
import '../services/firestore_service.dart';

enum _ChartParameter { ph, no3, po4, temp, gh, kh, fe, k, mg }

enum _ChartRange { days7, days30, days90, all }

class WaterParametersChartScreen extends StatefulWidget {
  const WaterParametersChartScreen({required this.aquarium, super.key});

  final AquariumModel aquarium;

  @override
  State<WaterParametersChartScreen> createState() =>
      _WaterParametersChartScreenState();
}

class _WaterParametersChartScreenState
    extends State<WaterParametersChartScreen> {
  late final FirestoreService _service;
  late final Stream<List<WaterParametersModel>> _parametersStream;
  _ChartParameter _selected = _ChartParameter.ph;
  _ChartRange _range = _ChartRange.all;

  @override
  void initState() {
    super.initState();
    _service = FirestoreService();
    _parametersStream = _service.getWaterParameters(widget.aquarium.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trendy parametrów'),
        actions: [
          IconButton(
            tooltip: 'Dodaj pomiar',
            onPressed: () => _openMeasurementForm(context),
            icon: const Icon(Icons.add_chart_outlined),
          ),
        ],
      ),
      body: StreamBuilder<List<WaterParametersModel>>(
        stream: _parametersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError && !snapshot.hasData) {
            return _ErrorView(message: _errorMessage(snapshot.error));
          }

          final measurements = snapshot.data ?? const <WaterParametersModel>[];
          if (measurements.isEmpty) {
            return _EmptyMeasurementsView(
              onAdd: () => _openMeasurementForm(context),
            );
          }

          return _ChartContent(
            aquarium: widget.aquarium,
            measurements: measurements,
            selected: _selected,
            range: _range,
            onParameterChanged: (parameter) =>
                setState(() => _selected = parameter),
            onRangeChanged: (range) => setState(() => _range = range),
            onAddMeasurement: () => _openMeasurementForm(context),
          );
        },
      ),
    );
  }

  Future<void> _openMeasurementForm(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            FirestoreWaterParametersFormScreen(aquarium: widget.aquarium),
      ),
    );
  }

  String _errorMessage(Object? error) {
    if (error is FirestoreServiceException) return error.message;
    return 'Nie udało się wczytać pomiarów. Spróbuj ponownie.';
  }
}

class _ChartContent extends StatelessWidget {
  const _ChartContent({
    required this.aquarium,
    required this.measurements,
    required this.selected,
    required this.range,
    required this.onParameterChanged,
    required this.onAddMeasurement,
    required this.onRangeChanged,
  });

  final AquariumModel aquarium;
  final List<WaterParametersModel> measurements;
  final _ChartParameter selected;
  final _ChartRange range;
  final ValueChanged<_ChartParameter> onParameterChanged;
  final ValueChanged<_ChartRange> onRangeChanged;
  final VoidCallback onAddMeasurement;

  @override
  Widget build(BuildContext context) {
    final measurementsInRange = _filterMeasurements(measurements, range);
    final visibleMeasurements = measurementsInRange.isEmpty
      ? measurements
      : measurementsInRange;
    final standard = _standardFor(selected, aquarium.type);
    final values = visibleMeasurements
        .map((measurement) => _valueFor(measurement, selected))
        .toList();
    final chronological = visibleMeasurements.reversed.toList();
    final chronologicalValues = values.reversed.toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AquariumHeading(aquarium: aquarium),
                const SizedBox(height: 16),
                _QuickStatsCard(
                  parameter: selected,
                  latest: visibleMeasurements.first,
                  previous: visibleMeasurements.length > 1
                      ? visibleMeasurements[1]
                      : null,
                  standard: standard,
                ),
                const SizedBox(height: 20),
                SegmentedButton<_ChartRange>(
                  segments: _ChartRange.values
                      .map(
                        (range) => ButtonSegment(
                          value: range,
                          label: Text(_rangeLabel(range)),
                        ),
                      )
                      .toList(),
                  selected: {range},
                  onSelectionChanged: (selection) =>
                      onRangeChanged(selection.first),
                ),
                const SizedBox(height: 16),
                Text(
                  'Wybierz parametr',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _ChartParameter.values.map((parameter) {
                    return ChoiceChip(
                      label: Text(_labelFor(parameter)),
                      selected: selected == parameter,
                      onSelected: (_) => onParameterChanged(parameter),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 18, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Zmiana w czasie · ${_labelFor(selected)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              'Optimum ${_formatNumber(standard.min)}–${_formatNumber(standard.max)} ${standard.unit}',
                              style: TextStyle(
                                color: Colors.teal.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 280,
                          child: _LineChart(
                            measurements: chronological,
                            values: chronologicalValues,
                            standard: standard,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onAddMeasurement,
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj kolejny pomiar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({
    required this.measurements,
    required this.values,
    required this.standard,
  });

  final List<WaterParametersModel> measurements;
  final List<double> values;
  final _ChartStandard standard;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold(standard.max, (max, value) {
      return value > max ? value : max;
    });
    final minValue = values.fold(standard.min, (min, value) {
      return value < min ? value : min;
    });
    final minY = (minValue < standard.chartMin ? minValue : standard.chartMin);
    final maxY = (maxValue > standard.chartMax ? maxValue : standard.chartMax);
    final paddedMin = minY == maxY ? minY - 1 : minY;
    final paddedMax = minY == maxY ? maxY + 1 : maxY;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (values.length - 1).toDouble().clamp(1, double.infinity),
        minY: paddedMin,
        maxY: paddedMax,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.grey.withValues(alpha: 0.16),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((spot) {
              final measurement = measurements[spot.x.round()];
              return LineTooltipItem(
                '${_fullDate(measurement.timestamp)}\n${_formatNumber(spot.y)} ${standard.unit}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              );
            }).toList(),
          ),
        ),
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(
              y1: standard.min,
              y2: standard.max,
              color: Colors.teal.withValues(alpha: 0.10),
            ),
          ],
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(value.abs() < 10 ? 1 : 0),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: values.length > 6
                  ? (values.length / 4).ceilToDouble()
                  : 1,
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= measurements.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    _shortDate(measurements[index].timestamp),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: values.indexed
                .map((entry) => FlSpot(entry.$1.toDouble(), entry.$2))
                .toList(),
            isCurved: values.length > 2,
            color: const Color(0xFF10B981),
            barWidth: 3,
            dotData: FlDotData(
              show: values.length <= 24,
              getDotPainter: (spot, _, _, index) => FlDotCirclePainter(
                radius: 4,
                color: _pointColor(spot.y, standard),
                strokeWidth: 1.5,
                strokeColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF10B981).withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsCard extends StatelessWidget {
  const _QuickStatsCard({
    required this.parameter,
    required this.latest,
    required this.previous,
    required this.standard,
  });

  final _ChartParameter parameter;
  final WaterParametersModel latest;
  final WaterParametersModel? previous;
  final _ChartStandard standard;

  @override
  Widget build(BuildContext context) {
    final latestValue = _valueFor(latest, parameter);
    final previousValue = previous == null
        ? null
        : _valueFor(previous!, parameter);
    final difference = previousValue == null
        ? null
        : latestValue - previousValue;
    final isStable = difference == null || difference.abs() < 0.05;
    final isUp = difference != null && difference > 0;
    final trendColor = isStable
        ? Colors.blueGrey.shade600
        : isUp
        ? Colors.orange.shade800
        : Colors.teal.shade700;
    final trendIcon = isStable
        ? Icons.trending_flat
        : isUp
        ? Icons.trending_up
        : Icons.trending_down;
    final trendLabel = previous == null
        ? 'Brak wcześniejszego pomiaru'
        : isStable
        ? 'Stabilnie względem poprzedniego'
        : isUp
        ? 'Wzrost względem poprzedniego'
        : 'Spadek względem poprzedniego';
    final inRange = latestValue >= standard.min && latestValue <= standard.max;
    final status = latestValue < standard.min
      ? 'Poniżej zakresu'
      : latestValue > standard.max
      ? 'Powyżej zakresu'
      : 'W zakresie';
    final statusColor = inRange
      ? const Color(0xFF10B981)
      : const Color(0xFFF59E0B);

    return Card(
      color: inRange ? Colors.white : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights_outlined, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'Ostatni pomiar · ${_labelFor(parameter)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Icon(
                  inRange ? Icons.check_circle_outline : Icons.warning_amber,
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatNumber(latestValue),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF123D39),
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(standard.unit),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(trendIcon, color: trendColor),
                    Text(
                      trendLabel,
                      style: TextStyle(color: trendColor, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Status: $status',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              _fullDate(latest.timestamp),
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _AquariumHeading extends StatelessWidget {
  const _AquariumHeading({required this.aquarium});

  final AquariumModel aquarium;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          aquarium.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF123D39),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_formatNumber(aquarium.capacityLiters)} l · ${aquarium.type}',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

class _EmptyMeasurementsView extends StatelessWidget {
  const _EmptyMeasurementsView({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 56, color: Colors.teal.shade300),
            const SizedBox(height: 16),
            Text(
              'Brak pomiarów wody',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Dodaj pierwszy pomiar, aby zobaczyć trendy parametrów.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_chart_outlined),
              label: const Text('Dodaj pierwszy pomiar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 44,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class FirestoreWaterParametersFormScreen extends StatefulWidget {
  const FirestoreWaterParametersFormScreen({required this.aquarium, super.key});

  final AquariumModel aquarium;

  @override
  State<FirestoreWaterParametersFormScreen> createState() =>
      _FirestoreWaterParametersFormScreenState();
}

class _FirestoreWaterParametersFormScreenState
    extends State<FirestoreWaterParametersFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{
    'pH': TextEditingController(),
    'KH': TextEditingController(),
    'GH': TextEditingController(),
    'NO3': TextEditingController(),
    'PO4': TextEditingController(),
    'Fe': TextEditingController(),
    'K': TextEditingController(),
    'Mg': TextEditingController(),
    'Temperatura': TextEditingController(),
    'Notatka': TextEditingController(),
  };
  final _service = FirestoreService();
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nowy pomiar wody')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  Text(
                    widget.aquarium.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF123D39),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Wartości zostaną zapisane z bieżącą datą i godziną.',
                  ),
                  const SizedBox(height: 20),
                  if (_error != null) ...[
                    Text(_error!, style: TextStyle(color: Colors.red.shade700)),
                    const SizedBox(height: 12),
                  ],
                  ..._controllers.entries
                      .where((entry) => entry.key != 'Notatka')
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: entry.value,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: entry.key == 'Temperatura'
                                  ? AppLocalizations.of(context)!.temperature
                                  : entry.key,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Wpisz wartość.';
                              }
                              return double.tryParse(
                                        value.trim().replaceAll(',', '.'),
                                      ) ==
                                      null
                                  ? 'Wpisz poprawną liczbę.'
                                  : null;
                            },
                          ),
                        ),
                      ),
                  TextField(
                    controller: _controllers['Notatka'],
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notatka (opcjonalnie)',
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_isSaving ? 'Zapisywanie...' : 'Zapisz pomiar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await _service.addWaterParameters(
        WaterParametersModel(
          id: '',
          aquariumId: widget.aquarium.id,
          timestamp: DateTime.now(),
          ph: _number('pH'),
          kh: _number('KH'),
          gh: _number('GH'),
          no3: _number('NO3'),
          po4: _number('PO4'),
          fe: _number('Fe'),
          k: _number('K'),
          mg: _number('Mg'),
          temp: _number('Temperatura'),
          notes: _controllers['Notatka']!.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context);
    } on FirestoreServiceException catch (error) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _error = error.message;
        });
      }
    }
  }

  double _number(String key) {
    return double.parse(_controllers[key]!.text.trim().replaceAll(',', '.'));
  }
}

class _ChartStandard {
  const _ChartStandard({
    required this.min,
    required this.max,
    required this.chartMin,
    required this.chartMax,
    this.unit = '',
  });

  final double min;
  final double max;
  final double chartMin;
  final double chartMax;
  final String unit;
}

_ChartStandard _standardFor(_ChartParameter parameter, String aquariumType) {
  final type = aquariumType.toLowerCase();
  final marine = type.contains('morsk');
  final shrimp = type.contains('krewet');

  switch (parameter) {
    case _ChartParameter.ph:
      return marine
          ? const _ChartStandard(min: 7.8, max: 8.4, chartMin: 7, chartMax: 9)
          : shrimp
          ? const _ChartStandard(min: 6, max: 7.2, chartMin: 5, chartMax: 8.5)
          : const _ChartStandard(min: 6.5, max: 7.5, chartMin: 5, chartMax: 9);
    case _ChartParameter.no3:
      return marine
          ? const _ChartStandard(
              min: 2,
              max: 15,
              chartMin: 0,
              chartMax: 40,
              unit: 'mg/l',
            )
          : const _ChartStandard(
              min: 10,
              max: 25,
              chartMin: 0,
              chartMax: 60,
              unit: 'mg/l',
            );
    case _ChartParameter.po4:
      return marine
          ? const _ChartStandard(
              min: 0.02,
              max: 0.2,
              chartMin: 0,
              chartMax: 1,
              unit: 'mg/l',
            )
          : const _ChartStandard(
              min: 0.5,
              max: 1.5,
              chartMin: 0,
              chartMax: 3,
              unit: 'mg/l',
            );
    case _ChartParameter.temp:
      return marine
          ? const _ChartStandard(
              min: 24,
              max: 27,
              chartMin: 20,
              chartMax: 30,
              unit: '°C',
            )
          : const _ChartStandard(
              min: 22,
              max: 28,
              chartMin: 18,
              chartMax: 32,
              unit: '°C',
            );
    case _ChartParameter.gh:
      return shrimp
          ? const _ChartStandard(
              min: 4,
              max: 10,
              chartMin: 0,
              chartMax: 18,
              unit: 'dGH',
            )
          : const _ChartStandard(
              min: 5,
              max: 12,
              chartMin: 0,
              chartMax: 18,
              unit: 'dGH',
            );
    case _ChartParameter.kh:
      return marine
          ? const _ChartStandard(
              min: 7,
              max: 12,
              chartMin: 0,
              chartMax: 16,
              unit: 'dKH',
            )
          : const _ChartStandard(
              min: 3,
              max: 8,
              chartMin: 0,
              chartMax: 12,
              unit: 'dKH',
            );
    case _ChartParameter.fe:
      return const _ChartStandard(
        min: 0.05,
        max: 0.2,
        chartMin: 0,
        chartMax: 0.5,
        unit: 'mg/l',
      );
    case _ChartParameter.k:
      return const _ChartStandard(
        min: 5,
        max: 15,
        chartMin: 0,
        chartMax: 25,
        unit: 'mg/l',
      );
    case _ChartParameter.mg:
      return const _ChartStandard(
        min: 5,
        max: 20,
        chartMin: 0,
        chartMax: 30,
        unit: 'mg/l',
      );
  }
}

Color _pointColor(double value, _ChartStandard standard) {
  if (value >= standard.min && value <= standard.max) {
    return const Color(0xFF10B981);
  }
  return const Color(0xFFF59E0B);
}

double _valueFor(WaterParametersModel measurement, _ChartParameter parameter) {
  switch (parameter) {
    case _ChartParameter.ph:
      return measurement.ph;
    case _ChartParameter.no3:
      return measurement.no3;
    case _ChartParameter.po4:
      return measurement.po4;
    case _ChartParameter.temp:
      return measurement.temp;
    case _ChartParameter.gh:
      return measurement.gh;
    case _ChartParameter.kh:
      return measurement.kh;
    case _ChartParameter.fe:
      return measurement.fe;
    case _ChartParameter.k:
      return measurement.k;
    case _ChartParameter.mg:
      return measurement.mg;
  }
}

String _labelFor(_ChartParameter parameter) {
  switch (parameter) {
    case _ChartParameter.ph:
      return 'pH';
    case _ChartParameter.no3:
      return 'NO3';
    case _ChartParameter.po4:
      return 'PO4';
    case _ChartParameter.temp:
      return 'Temp.';
    case _ChartParameter.gh:
      return 'GH';
    case _ChartParameter.kh:
      return 'KH';
    case _ChartParameter.fe:
      return 'Fe';
    case _ChartParameter.k:
      return 'K';
    case _ChartParameter.mg:
      return 'Mg';
  }
}

String _rangeLabel(_ChartRange range) {
  switch (range) {
    case _ChartRange.days7:
      return '7 dni';
    case _ChartRange.days30:
      return '30 dni';
    case _ChartRange.days90:
      return '90 dni';
    case _ChartRange.all:
      return 'Wszystko';
  }
}

List<WaterParametersModel> _filterMeasurements(
  List<WaterParametersModel> measurements,
  _ChartRange range,
) {
  if (range == _ChartRange.all) return measurements;
  final days = switch (range) {
    _ChartRange.days7 => 7,
    _ChartRange.days30 => 30,
    _ChartRange.days90 => 90,
    _ChartRange.all => 0,
  };
  final cutoff = DateTime.now().subtract(Duration(days: days));
  return measurements
      .where((measurement) => !measurement.timestamp.isBefore(cutoff))
      .toList(growable: false);
}

String _formatNumber(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}

String _shortDate(DateTime date) => '${date.day}.${date.month}';

String _fullDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day.$month.${date.year}, $hour:$minute';
}
