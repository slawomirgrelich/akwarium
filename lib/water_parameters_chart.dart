import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final tests = context.watch<AquariumProvider>().waterTests.reversed.toList();
    final standard = waterStandards[_selected]!;
    final values = tests.map((test) => waterValue(test, _selected)).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Historia parametrów',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${standard.optimalMin}-${standard.optimalMax} ${standard.unit}',
                  style: TextStyle(color: Colors.teal.shade700, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: WaterParameter.values.map((parameter) {
                  final item = waterStandards[parameter]!;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(item.label),
                      selected: _selected == parameter,
                      onSelected: (_) => setState(() => _selected = parameter),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 230,
              child: tests.length < 2
                  ? const Center(child: Text('Dodaj co najmniej dwa pomiary, aby zobaczyć wykres.'))
                  : LineChart(
                      LineChartData(
                        minY: standard.chartMin,
                        maxY: _maxY(standard, values),
                        minX: 0,
                        maxX: (values.length - 1).toDouble(),
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        rangeAnnotations: RangeAnnotations(
                          horizontalRangeAnnotations: [
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
                            sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                final index = value.round();
                                if (index < 0 || index >= tests.length) return const SizedBox();
                                final date = tests[index].date;
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text('${date.day}.${date.month}', style: const TextStyle(fontSize: 10)),
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