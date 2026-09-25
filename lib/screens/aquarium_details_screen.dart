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
