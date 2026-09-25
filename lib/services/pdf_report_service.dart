import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/aquarium_firestore_model.dart';
import 'aquarium_journal_service.dart';

class PdfReportService {
  Future<Uint8List> generateAquariumReportPdf({
    required AquariumModel aquarium,
    required List<WaterParametersModel> parametersHistory,
    required List<JournalEntryModel> journalEntries,
  }) async {
    final document = pw.Document(
      theme: pw.ThemeData.withFont(
        base: await PdfGoogleFonts.notoSansRegular(),
        bold: await PdfGoogleFonts.notoSansBold(),
      ),
    );
    final recentEntries =
        journalEntries
            .where(
              (entry) =>
                  DateTime.now().difference(entry.timestamp).inDays <= 30,
            )
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final sortedParameters = [...parametersHistory]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => _header(aquarium),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Akwarysta PRO · strona ${context.pageNumber}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),
        build: (_) => [
          pw.SizedBox(height: 18),
          _sectionTitle('Podsumowanie zbiornika'),
          pw.SizedBox(height: 8),
          _summaryTable(aquarium),
          pw.SizedBox(height: 22),
          _sectionTitle('Historia testów wody'),
          pw.SizedBox(height: 8),
          if (sortedParameters.isEmpty)
            _emptyText('Brak zapisanych pomiarów wody.')
          else
            _parametersTable(sortedParameters),
          pw.SizedBox(height: 22),
          _sectionTitle('Dziennik akwarysty · ostatnie 30 dni'),
          pw.SizedBox(height: 8),
          if (recentEntries.isEmpty)
            _emptyText('Brak wpisów w ostatnich 30 dniach.')
          else
            ...recentEntries.map(_journalEntry),
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _header(AquariumModel aquarium) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.teal700)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            color: PdfColors.teal700,
            child: pw.Text(
              'AKWARYSTA PRO',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Text(
              aquarium.name,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _summaryTable(AquariumModel aquarium) {
    final estimatedWeight = aquarium.capacityLiters * 1.25;
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: const {
        0: pw.FlexColumnWidth(1),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            'Pojemność netto',
            'Szacowana waga',
            'Typ akwarium',
          ].map(_tableHeader).toList(),
        ),
        pw.TableRow(
          children: [
            '${aquarium.capacityLiters.toStringAsFixed(1)} l',
            '${estimatedWeight.toStringAsFixed(1)} kg',
            aquarium.type,
          ].map(_tableCell).toList(),
        ),
      ],
    );
  }

  pw.Widget _parametersTable(List<WaterParametersModel> parameters) {
    final headers = ['Data', 'pH', 'KH', 'GH', 'NO3', 'PO4', 'Fe', 'Temp.'];
    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey100),
        children: headers.map(_tableHeader).toList(),
      ),
      ...parameters
          .take(30)
          .map(
            (item) => pw.TableRow(
              children: [
                _tableCell(_date(item.timestamp)),
                _parameterCell(item.ph, 6.5, 7.5),
                _parameterCell(item.kh, 3, 8),
                _parameterCell(item.gh, 5, 12),
                _parameterCell(item.no3, 10, 25),
                _parameterCell(item.po4, 0.5, 1.5),
                _parameterCell(item.fe, 0.1, 0.5),
                _parameterCell(item.temp, 22, 28),
              ],
            ),
          ),
    ];
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  pw.Widget _journalEntry(JournalEntryModel entry) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(9),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  entry.title,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Text(
                _date(entry.timestamp),
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
          pw.SizedBox(height: 3),
          pw.Text('${entry.entryType.label} · ${entry.notes}'),
          if (entry.percentageWaterChanged != null)
            pw.Text(
              'Podmieniono: ${entry.percentageWaterChanged!.toStringAsFixed(0)}%',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
        ],
      ),
    );
  }

  pw.Widget _parameterCell(double value, double min, double max) {
    final inRange = value >= min && value <= max;
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      color: inRange ? PdfColors.white : PdfColors.red100,
      child: pw.Text(
        value.toStringAsFixed(value.abs() < 10 ? 2 : 1),
        style: pw.TextStyle(
          fontSize: 8,
          color: inRange ? PdfColors.grey900 : PdfColors.red900,
          fontWeight: inRange ? pw.FontWeight.normal : pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _sectionTitle(String text) => pw.Text(
    text,
    style: pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.teal800,
    ),
  );

  pw.Widget _tableHeader(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(5),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
    ),
  );

  pw.Widget _tableCell(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(5),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 8)),
  );

  pw.Widget _emptyText(String text) => pw.Text(
    text,
    style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
  );

  String _date(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}
