import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/aquarium_firestore_model.dart';
import '../models/aquarium_model.dart' as local_models;
import '../services/aquarium_journal_service.dart';
import '../services/firestore_service.dart';
import '../services/pdf_report_service.dart';
import '../services/pro_access_service.dart';
import '../utils/localized_labels.dart';
import '../widgets/maintenance_schedule_section.dart';
import '../widgets/pro_paywall_dialog.dart';
import 'water_parameters_chart_screen.dart';

import 'package:akwarium/utils/app_snackbar.dart';

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
  late AquariumModel _aquarium;

  @override
  void initState() {
    super.initState();
    _aquarium = widget.aquarium;
    _firestoreService = FirestoreService();
    _journalService = AquariumJournalService();
    _pdfService = PdfReportService();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final aquariumId = context
        .read<local_models.AquariumProvider>()
        .resolveAquariumId(_aquarium.id);
    if (aquariumId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.aquariumDetailsTitle)),
        body: Center(child: Text(l10n.addAquariumToStart)),
      );
    }
    final aquarium = _aquarium.id == aquariumId
        ? _aquarium
        : _aquarium.copyWith(id: aquariumId);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aquariumDetailsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _ReportIconButton(
            onPressed: () => _requestReport(context, aquarium: aquarium),
          ),
        ],
      ),
      body: StreamBuilder<List<WaterParametersModel>>(
        stream: _firestoreService.getWaterParameters(aquarium.id),
        builder: (context, parametersSnapshot) {
          return StreamBuilder<List<JournalEntryModel>>(
            stream: _journalService.getJournalEntries(aquarium.id),
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
                aquarium: aquarium,
                parameters: parameters,
                onEditEquipment: () => _editEquipment(context, aquarium),
                onShowChart: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        WaterParametersChartScreen(aquarium: _aquarium),
                  ),
                ),
                onGenerateReport: () => _requestReport(
                  context,
                  aquarium: aquarium,
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

  Future<void> _editEquipment(
    BuildContext context,
    AquariumModel aquarium,
  ) async {
    final equipment = await showDialog<AquariumEquipment>(
      context: context,
      builder: (_) => _EquipmentFormDialog(initial: aquarium.equipment),
    );
    if (equipment == null || !context.mounted) return;

    final updated = aquarium.copyWith(equipment: equipment);
    try {
      await _firestoreService.updateAquarium(updated);
      if (!context.mounted) return;
      setState(() => _aquarium = updated);
      context.showAppSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.equipmentSaved)),
      );
    } on FirestoreServiceException catch (error) {
      if (context.mounted) {
        context.showAppSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  Future<void> _requestReport(
    BuildContext context, {
    required AquariumModel aquarium,
    List<WaterParametersModel>? parameters,
    List<JournalEntryModel>? entries,
  }) async {
    if (!context.read<ProAccessService>().isProUser) {
      await ProPaywallDialog.show(
        context,
        headline: AppLocalizations.of(context)!.reportProHeadline,
      );
      return;
    }

    try {
      parameters ??= await _firestoreService
          .getWaterParameters(aquarium.id)
          .first;
      entries ??= await _journalService.getJournalEntries(aquarium.id).first;
      if (!context.mounted) return;
      final bytes = await _pdfService.generateAquariumReportPdf(
        aquarium: aquarium,
        parametersHistory: parameters,
        journalEntries: entries,
      );
      if (!context.mounted) return;
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } on Object catch (error) {
      if (context.mounted) {
        context.showAppSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.reportGenerationError('$error'),
            ),
          ),
        );
      }
    }
  }

  String _errorMessage(Object error) {
    if (error is FirestoreServiceException) return error.message;
    if (error is AquariumJournalServiceException) return error.message;
    return AppLocalizations.of(context)!.aquariumDetailsLoadError;
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.aquarium,
    required this.parameters,
    required this.onEditEquipment,
    required this.onShowChart,
    required this.onGenerateReport,
  });

  final AquariumModel aquarium;
  final List<WaterParametersModel> parameters;
  final VoidCallback onEditEquipment;
  final VoidCallback onShowChart;
  final VoidCallback onGenerateReport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            '${aquarium.capacityLiters.toStringAsFixed(1)} l · ${aquariumTypeLabel(l10n, aquarium.type)}',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 18),
          _SummaryCard(aquarium: aquarium),
          const SizedBox(height: 16),
          _EquipmentCard(
            equipment: aquarium.equipment,
            onEdit: onEditEquipment,
          ),
          const SizedBox(height: 16),
          if (latest == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(l10n.noWaterMeasurements),
              ),
            )
          else
            _LatestParametersCard(latest: latest),
          const SizedBox(height: 16),
          MaintenanceScheduleSection(aquariumId: aquarium.id),
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
                    label: Text(l10n.chartTrendsTitle),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: onGenerateReport,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(l10n.reportPdfAction),
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

enum _HistoryParameter { ph, temperature, no3, no2, co2, nh3Nh4, tds }

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
    final l10n = AppLocalizations.of(context)!;
    final measurements = widget.parameters.reversed.toList(growable: false);
    final chartMeasurements = measurements
        .where((measurement) => _valueForSelected(measurement) != null)
        .toList(growable: false);
    final values = chartMeasurements
        .map(_valueForSelected)
        .whereType<double>()
        .toList(growable: false);
    if (values.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.chartNoParameterData(_parameterLabel(_selected))),
        ),
      );
    }
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
              l10n.chartHistoryTitle,
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
                  maxX: chartMeasurements.length < 2
                      ? 1
                      : (chartMeasurements.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Theme.of(context).dividerColor
                          .withValues(alpha: 0.45),
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontSize: 9),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: chartMeasurements.length > 5
                            ? (chartMeasurements.length / 4).ceilToDouble()
                            : 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.round();
                          if (index < 0 || index >= chartMeasurements.length) {
                            return const SizedBox.shrink();
                          }
                          final date = chartMeasurements[index].timestamp;
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
                        final index = spot.x.round().clamp(
                          0,
                          chartMeasurements.length - 1,
                        );
                        final date = chartMeasurements[index].timestamp;
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

  double? _valueForSelected(WaterParametersModel measurement) =>
      switch (_selected) {
        _HistoryParameter.ph => measurement.ph,
        _HistoryParameter.temperature => measurement.temp,
        _HistoryParameter.no3 => measurement.no3,
        _HistoryParameter.no2 => measurement.no2,
        _HistoryParameter.co2 => measurement.co2,
        _HistoryParameter.nh3Nh4 => measurement.nh3Nh4,
        _HistoryParameter.tds => measurement.tds,
      };

  String get _unit => switch (_selected) {
    _HistoryParameter.ph => '',
    _HistoryParameter.temperature => '°C',
    _HistoryParameter.no3 => 'mg/l',
    _HistoryParameter.no2 => 'mg/l',
    _HistoryParameter.co2 => 'mg/L',
    _HistoryParameter.nh3Nh4 => 'mg/L',
    _HistoryParameter.tds => 'ppm',
  };

  String _parameterLabel(_HistoryParameter parameter) => switch (parameter) {
    _HistoryParameter.ph => 'pH',
    _HistoryParameter.temperature => 'Temperatura',
    _HistoryParameter.no3 => 'Azotany (NO3)',
    _HistoryParameter.no2 => 'Azotyny (NO2)',
    _HistoryParameter.co2 => 'CO2',
    _HistoryParameter.nh3Nh4 => 'NH3/NH4',
    _HistoryParameter.tds => 'TDS',
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
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      tooltip: l10n.reportPdfAction,
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
    final l10n = AppLocalizations.of(context)!;
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
                '${l10n.aquariumCapacityLabel}: ${aquarium.capacityLiters.toStringAsFixed(1)} l\n'
                '${l10n.estimatedWeightLabel}: ${estimatedWeight.toStringAsFixed(1)} kg\n'
                '${l10n.aquariumTypeLabel}: ${aquariumTypeLabel(l10n, aquarium.type)}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  const _EquipmentCard({required this.equipment, required this.onEdit});

  final AquariumEquipment? equipment;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = equipment;
    final lines = <String>[
      if (data?.lightingModel?.isNotEmpty ?? false)
        '${l10n.equipmentLighting}: ${data!.lightingModel}',
      if (data?.lightingPowerWatts != null)
        '${l10n.equipmentLightingPower}: ${_formatEquipmentValue(data!.lightingPowerWatts!)} W',
      if (data?.lightingHoursPerDay != null)
        '${l10n.equipmentPhotoperiod}: ${_formatEquipmentValue(data!.lightingHoursPerDay!)} h',
      if (data?.co2System?.isNotEmpty ?? false)
        '${l10n.equipmentCo2System}: ${data!.co2System}',
      if (data?.co2BubblesPerSecond != null)
        '${l10n.equipmentCo2Bubbles}: ${_formatEquipmentValue(data!.co2BubblesPerSecond!)}',
      if (data?.feedingNotes?.isNotEmpty ?? false)
        '${l10n.equipmentFeeding}: ${data!.feedingNotes}',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.equipmentTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: l10n.editAction,
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            if (lines.isEmpty)
              Text(l10n.equipmentNotConfigured)
            else
              ...lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(line),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EquipmentFormDialog extends StatefulWidget {
  const _EquipmentFormDialog({required this.initial});

  final AquariumEquipment? initial;

  @override
  State<_EquipmentFormDialog> createState() => _EquipmentFormDialogState();
}

class _EquipmentFormDialogState extends State<_EquipmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _lightingModel = TextEditingController(
    text: widget.initial?.lightingModel ?? '',
  );
  late final _lightingPower = TextEditingController(
    text: _initialNumber(widget.initial?.lightingPowerWatts),
  );
  late final _lightingHours = TextEditingController(
    text: _initialNumber(widget.initial?.lightingHoursPerDay),
  );
  late final _co2System = TextEditingController(
    text: widget.initial?.co2System ?? '',
  );
  late final _co2Rate = TextEditingController(
    text: _initialNumber(widget.initial?.co2BubblesPerSecond),
  );
  late final _feedingNotes = TextEditingController(
    text: widget.initial?.feedingNotes ?? '',
  );

  @override
  void dispose() {
    _lightingModel.dispose();
    _lightingPower.dispose();
    _lightingHours.dispose();
    _co2System.dispose();
    _co2Rate.dispose();
    _feedingNotes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.equipmentTitle),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.65,
          maxWidth: 480,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _lightingModel,
                  decoration: InputDecoration(
                    labelText: l10n.equipmentLighting,
                  ),
                ),
                TextFormField(
                  controller: _lightingPower,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.equipmentLightingPower,
                    suffixText: 'W',
                  ),
                  validator: _validateOptionalNumber,
                ),
                TextFormField(
                  controller: _lightingHours,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.equipmentPhotoperiod,
                    suffixText: 'h',
                  ),
                  validator: _validateOptionalNumber,
                ),
                TextFormField(
                  controller: _co2System,
                  decoration: InputDecoration(
                    labelText: l10n.equipmentCo2System,
                  ),
                ),
                TextFormField(
                  controller: _co2Rate,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.equipmentCo2Bubbles,
                    suffixText: 'b/s',
                  ),
                  validator: _validateOptionalNumber,
                ),
                TextFormField(
                  controller: _feedingNotes,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.equipmentFeeding,
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }

  String? _validateOptionalNumber(String? value) {
    final text = value?.trim().replaceAll(',', '.') ?? '';
    if (text.isEmpty || double.tryParse(text) != null) return null;
    return AppLocalizations.of(context)!.equipmentInvalidNumber;
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      AquariumEquipment(
        lightingModel: _optionalText(_lightingModel.text),
        lightingPowerWatts: _optionalNumber(_lightingPower.text),
        lightingHoursPerDay: _optionalNumber(_lightingHours.text),
        co2System: _optionalText(_co2System.text),
        co2BubblesPerSecond: _optionalNumber(_co2Rate.text),
        feedingNotes: _optionalText(_feedingNotes.text),
      ),
    );
  }

  String? _optionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  double? _optionalNumber(String value) {
    final trimmed = value.trim().replaceAll(',', '.');
    return trimmed.isEmpty ? null : double.parse(trimmed);
  }

  String _initialNumber(double? value) => value == null ? '' : '$value';
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
            if (latest.ph case final value?)
              Text('pH ${value.toStringAsFixed(2)}'),
            if (latest.no3 case final value?)
              Text('NO3 ${value.toStringAsFixed(1)}'),
            if (latest.no2 case final value?)
              Text('NO2 ${value.toStringAsFixed(2)}'),
            if (latest.po4 case final value?)
              Text('PO4 ${value.toStringAsFixed(2)}'),
            if (latest.co2 case final value?)
              Text('CO2 ${value.toStringAsFixed(1)} mg/L'),
            if (latest.nh3Nh4 case final value?)
              Text('NH3/NH4 ${value.toStringAsFixed(2)} mg/L'),
            if (latest.tds case final value?)
              Text('TDS ${value.toStringAsFixed(0)} ppm'),
            Text(_date(latest.timestamp)),
          ],
        ),
      ),
    );
  }
}

String _formatEquipmentValue(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(2);

String _date(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day.$month.${value.year}';
}
