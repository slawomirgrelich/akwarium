import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../models/aquarium_firestore_model.dart';
import '../services/aquarium_journal_service.dart';
import '../services/firestore_service.dart';
import '../services/pdf_report_service.dart';
import '../services/pro_access_service.dart';
import '../widgets/pro_paywall_dialog.dart';
import 'water_parameters_chart_screen.dart';

class AquariumDetailsScreen extends StatefulWidget {
  const AquariumDetailsScreen({required this.aquarium, super.key});

  final AquariumModel aquarium;

  @override
  State<AquariumDetailsScreen> createState() => _AquariumDetailsScreenState();
}

class _AquariumDetailsScreenState extends State<AquariumDetailsScreen> {
  late final FirestoreService _firestoreService;
  late final AquariumJournalService _journalService;
  late final PdfReportService _pdfService;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _journalService = AquariumJournalService();
    _pdfService = PdfReportService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły akwarium'),
        actions: [_ReportIconButton(onPressed: () => _requestReport(context))],
      ),
      body: StreamBuilder<List<WaterParametersModel>>(
        stream: _firestoreService.getWaterParameters(widget.aquarium.id),
        builder: (context, parametersSnapshot) {
          return StreamBuilder<List<JournalEntryModel>>(
            stream: _journalService.getJournalEntries(widget.aquarium.id),
            builder: (context, journalSnapshot) {
              if (parametersSnapshot.connectionState ==
                      ConnectionState.waiting &&
                  journalSnapshot.connectionState == ConnectionState.waiting &&
                  !parametersSnapshot.hasData &&
                  !journalSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final parameters =
                  parametersSnapshot.data ?? const <WaterParametersModel>[];
              final entries =
                  journalSnapshot.data ?? const <JournalEntryModel>[];
              final error = parametersSnapshot.error ?? journalSnapshot.error;
              if (error != null && parameters.isEmpty && entries.isEmpty) {
                return Center(child: Text(_errorMessage(error)));
              }

              return _DetailsContent(
                aquarium: widget.aquarium,
                parameters: parameters,
                onShowChart: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        WaterParametersChartScreen(aquarium: widget.aquarium),
                  ),
                ),
                onGenerateReport: () => _requestReport(
                  context,
                  parameters: parameters,
                  entries: entries,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _requestReport(
    BuildContext context, {
    List<WaterParametersModel>? parameters,
    List<JournalEntryModel>? entries,
  }) async {
    if (!context.read<ProAccessService>().isProUser) {
      await ProPaywallDialog.show(
        context,
        headline:
            'Generuj profesjonalne raporty PDF swoich akwariów z Akwarysta PRO',
      );
      return;
    }

    try {
      parameters ??= await _firestoreService
          .getWaterParameters(widget.aquarium.id)
          .first;
      entries ??= await _journalService
          .getJournalEntries(widget.aquarium.id)
          .first;
      if (!context.mounted) return;
      final bytes = await _pdfService.generateAquariumReportPdf(
        aquarium: widget.aquarium,
        parametersHistory: parameters,
        journalEntries: entries,
      );
      if (!context.mounted) return;
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie udało się wygenerować raportu: $error')),
        );
      }
    }
  }

  String _errorMessage(Object error) {
    if (error is FirestoreServiceException) return error.message;
    if (error is AquariumJournalServiceException) return error.message;
    return 'Nie udało się wczytać szczegółów akwarium.';
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.aquarium,
    required this.parameters,
    required this.onShowChart,
    required this.onGenerateReport,
  });

  final AquariumModel aquarium;
  final List<WaterParametersModel> parameters;
  final VoidCallback onShowChart;
  final VoidCallback onGenerateReport;

  @override
  Widget build(BuildContext context) {
    final latest = parameters.isEmpty ? null : parameters.first;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            aquarium.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF123D39),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${aquarium.capacityLiters.toStringAsFixed(1)} l · ${aquarium.type}',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 18),
          _SummaryCard(aquarium: aquarium),
          const SizedBox(height: 16),
          if (latest == null)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('Brak pomiarów parametrów wody.'),
              ),
            )
          else
            _LatestParametersCard(latest: latest),
          if (parameters.isNotEmpty) ...[
            const SizedBox(height: 16),
            _WaterHistoryChart(parameters: parameters),
          ],
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Raporty i trendy',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const ProBadge(compact: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onShowChart,
                    icon: const Icon(Icons.show_chart),
                    label: const Text('Zobacz trendy parametrów'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: onGenerateReport,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Generuj Raport PDF'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _HistoryParameter { ph, temperature, no3 }

class _WaterHistoryChart extends StatefulWidget {
  const _WaterHistoryChart({required this.parameters});

  final List<WaterParametersModel> parameters;

  @override
  State<_WaterHistoryChart> createState() => _WaterHistoryChartState();
}

class _WaterHistoryChartState extends State<_WaterHistoryChart> {
  _HistoryParameter _selected = _HistoryParameter.ph;

  @override
  Widget build(BuildContext context) {
    final measurements = widget.parameters.reversed.toList(growable: false);
    final values = measurements.map(_valueForSelected).toList(growable: false);
    final minimum = values.reduce((a, b) => a < b ? a : b);
    final maximum = values.reduce((a, b) => a > b ? a : b);
    final padding = maximum == minimum ? 1.0 : (maximum - minimum) * 0.12;
    final minY = minimum - padding;
    final maxY = maximum + padding;
    final unit = _unit;
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Historia parametrów wody',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _HistoryParameter.values.map((parameter) {
                return ChoiceChip(
                  label: Text(_parameterLabel(parameter)),
                  selected: _selected == parameter,
                  onSelected: (_) => setState(() => _selected = parameter),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 230,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: measurements.length < 2
                      ? 1
                      : (measurements.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.45),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
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
                        reservedSize: 62,
                        getTitlesWidget: (value, _) => Text(
                          '${_axisValue(value)}${unit.isEmpty ? '' : ' $unit'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: measurements.length > 5
                            ? (measurements.length / 4).ceilToDouble()
                            : 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.round();
                          if (index < 0 || index >= measurements.length) {
                            return const SizedBox.shrink();
                          }
                          final date = measurements[index].timestamp;
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots.map((spot) {
                        final index = spot.x.round().clamp(0, measurements.length - 1);
                        final date = measurements[index].timestamp;
                        return LineTooltipItem(
                          '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}\n${_axisValue(spot.y)}${unit.isEmpty ? '' : ' $unit'}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: values.indexed
                          .map((entry) => FlSpot(entry.$1.toDouble(), entry.$2))
                          .toList(growable: false),
                      isCurved: true,
                      curveSmoothness: 0.22,
                      color: primary,
                      barWidth: 3,
                      dotData: FlDotData(show: values.length <= 18),
                      belowBarData: BarAreaData(
                        show: true,
                        color: primary.withValues(alpha: 0.10),
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

  double _valueForSelected(WaterParametersModel measurement) => switch (_selected) {
    _HistoryParameter.ph => measurement.ph,
    _HistoryParameter.temperature => measurement.temp,
    _HistoryParameter.no3 => measurement.no3,
  };

  String get _unit => switch (_selected) {
    _HistoryParameter.ph => '',
    _HistoryParameter.temperature => '°C',
    _HistoryParameter.no3 => 'mg/l',
  };

  String _parameterLabel(_HistoryParameter parameter) => switch (parameter) {
    _HistoryParameter.ph => 'pH',
    _HistoryParameter.temperature => 'Temperatura',
    _HistoryParameter.no3 => 'Azotany (NO3)',
  };

  String _axisValue(double value) => _selected == _HistoryParameter.ph
      ? value.toStringAsFixed(1)
      : value.toStringAsFixed(value.abs() < 10 ? 1 : 0);
}

class _ReportIconButton extends StatelessWidget {
  const _ReportIconButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Generuj Raport PDF · PRO',
      onPressed: onPressed,
      icon: const Icon(Icons.picture_as_pdf_outlined),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.aquarium});

  final AquariumModel aquarium;

  @override
  Widget build(BuildContext context) {
    final estimatedWeight = aquarium.capacityLiters * 1.25;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.water_drop_outlined, color: Colors.teal, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Pojemność ${aquarium.capacityLiters.toStringAsFixed(1)} l\n'
                'Szacowana waga ${estimatedWeight.toStringAsFixed(1)} kg\n'
                'Typ: ${aquarium.type}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestParametersCard extends StatelessWidget {
  const _LatestParametersCard({required this.latest});

  final WaterParametersModel latest;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            const Text(
              'Ostatni pomiar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('pH ${latest.ph.toStringAsFixed(2)}'),
            Text('NO3 ${latest.no3.toStringAsFixed(1)}'),
            Text('PO4 ${latest.po4.toStringAsFixed(2)}'),
            Text(_date(latest.timestamp)),
          ],
        ),
      ),
    );
  }
}

String _date(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day.$month.${value.year}';
}
