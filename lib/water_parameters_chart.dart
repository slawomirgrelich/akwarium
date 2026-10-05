import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'models/aquarium_model.dart';
import 'models/water_standards.dart';

class WaterParametersChart extends StatefulWidget {
  const WaterParametersChart({super.key});

  @override
  State<WaterParametersChart> createState() => _WaterParametersChartState();
}

class _WaterParametersChartState extends State<WaterParametersChart> {
  WaterParameter _selected = WaterParameter.ph;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tests = context
        .watch<AquariumProvider>()
        .waterTests
        .reversed
        .toList();
    final standard = waterStandards[_selected]!;
    final compactRangeHeader =
        standard.hasUniversalOptimalRange &&
        _selected != WaterParameter.nh3Nh4 &&
        _selected != WaterParameter.no2;
    final points = <({WaterTest test, double value})>[
      for (final test in tests)
        if (waterValue(test, _selected) case final value?)
          (test: test, value: value),
    ];
    final values = points.map((point) => point.value).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (compactRangeHeader)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.chartHistoryTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _standardDescription(_selected, standard, l10n),
                    style: TextStyle(color: Colors.teal.shade700, fontSize: 12),
                  ),
                ],
              )
            else ...[
              Text(
                l10n.chartHistoryTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _standardDescription(_selected, standard, l10n),
                style: TextStyle(
                  color: standard.hasUniversalOptimalRange
                      ? Colors.teal.shade700
                      : Colors.blueGrey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: WaterParameter.values.map((parameter) {
                  final item = waterStandards[parameter]!;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        parameter == WaterParameter.nh3Nh4
                            ? l10n.ammoniaParameterLabel
                            : item.label,
                      ),
                      selected: _selected == parameter,
                      onSelected: (_) => setState(() => _selected = parameter),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            if (points.length < 2)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    l10n.chartTwoMeasurementsRequired,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              SizedBox(
                height: 230,
                child: LineChart(
                  LineChartData(
                    minY: standard.chartMin,
                    maxY: _maxY(standard, values),
                    minX: 0,
                    maxX: (points.length - 1).toDouble(),
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    rangeAnnotations: RangeAnnotations(
                      horizontalRangeAnnotations: [
                        if (standard.hasUniversalOptimalRange &&
                            standard.optimalMax > standard.optimalMin)
                          HorizontalRangeAnnotation(
                            y1: standard.optimalMin,
                            y2: standard.optimalMax,
                            color: Colors.teal.withAlpha(24),
                          ),
                      ],
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final index = value.round();
                            if (index < 0 || index >= points.length) {
                              return const SizedBox();
                            }
                            final date = points[index].test.date;
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                '${date.day}.${date.month}',
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
                            .map((item) => FlSpot(item.$1.toDouble(), item.$2))
                            .toList(),
                        isCurved: true,
                        color: Colors.teal.shade700,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.teal.withAlpha(24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _maxY(WaterStandard standard, List<double> values) {
    final maximum = values.fold(standard.optimalMax, (a, b) => a > b ? a : b);
    return maximum > standard.chartMax ? maximum * 1.1 : standard.chartMax;
  }
}

String _standardDescription(
  WaterParameter parameter,
  WaterStandard standard,
  AppLocalizations l10n,
) => switch (parameter) {
  WaterParameter.no2 => l10n.nitriteNonDetectableTarget,
  WaterParameter.nh3Nh4 => l10n.ammoniaNonDetectableTarget,
  WaterParameter.tds => l10n.tdsNoUniversalTarget,
  _ => '${standard.optimalMin}-${standard.optimalMax} ${standard.unit}',
};
