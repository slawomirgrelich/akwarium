import 'package:flutter_test/flutter_test.dart';

import 'package:akwarium/models/aquarium_firestore_model.dart';
import 'package:akwarium/services/aquarium_journal_service.dart';
import 'package:akwarium/services/pdf_report_service.dart';

void main() {
  test(
    'generates an A4 aquarium report with measurements and journal',
    () async {
      final aquarium = AquariumModel(
        id: 'tank-1',
        userId: 'user-1',
        name: 'Akwarium testowe',
        capacityLiters: 112,
        setupDate: DateTime(2025, 1, 1),
        type: 'Słodkowodne',
        createdAt: DateTime(2025, 1, 1),
      );
      final bytes = await PdfReportService().generateAquariumReportPdf(
        aquarium: aquarium,
        parametersHistory: [
          WaterParametersModel(
            id: 'measurement-1',
            aquariumId: aquarium.id,
            timestamp: DateTime.now(),
            ph: 7,
            kh: 5,
            gh: 8,
            no3: 15,
            po4: 1,
            fe: 0.2,
            temp: 25,
            notes: 'Pomiar kontrolny',
          ),
        ],
        journalEntries: [
          JournalEntryModel(
            id: 'entry-1',
            aquariumId: aquarium.id,
            timestamp: DateTime.now(),
            entryType: JournalEntryType.waterChange,
            title: 'Podmiana wody',
            notes: 'Podmieniono wodę',
            percentageWaterChanged: 30,
          ),
        ],
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    },
  );
  TestWidgetsFlutterBinding.ensureInitialized();
}
