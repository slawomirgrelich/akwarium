import 'firebase_options.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'algae_assistant_service.dart';
import 'ai_scanner_service.dart';
import 'app_version_widget.dart';
import 'aquarium_management_screen.dart';
import 'local_reminder_service.dart';
import 'models/aquarium_model.dart' as models;
import 'models/water_standards.dart';
import 'screens/auth_wrapper.dart';
import 'screens/calculators_screen.dart';
import 'screens/journal_and_reminders_screen.dart';
import 'screens/knowledge_base_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'services/auth_service.dart';
import 'services/pro_access_service.dart';
import 'water_parameters_chart.dart';
import 'water_test_screen.dart';
import 'widgets/firestore_aquariums_section.dart';
import 'widgets/pro_paywall_dialog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (error) {
    debugPrint('Firebase initialization failed: $error');
  }

  final preferences = await SharedPreferences.getInstance();
  runApp(
    AkwarystaProApp(firebaseReady: firebaseReady, proPreferences: preferences),
  );
  await LocalReminderService.instance.initialize();
}

// ===========================
// MODELE DANYCH
// ===========================

class Aquarium {
  const Aquarium({
    required this.id,
    required this.name,
    required this.capacityLiters,
    required this.setupDate,
    required this.type,
  });

  final String id;
  final String name;
  final double capacityLiters;
  final DateTime setupDate;
  final String type;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'capacityLiters': capacityLiters,
      'setupDate': setupDate.toIso8601String(),
      'type': type,
    };
  }

  factory Aquarium.fromMap(Map<String, dynamic> map) {
    return Aquarium(
      id: map['id'] as String,
      name: map['name'] as String,
      capacityLiters: (map['capacityLiters'] as num).toDouble(),
      setupDate: DateTime.parse(map['setupDate'] as String),
      type: map['type'] as String,
    );
  }
}

class WaterTest {
  const WaterTest({
    required this.id,
    required this.timestamp,
    required this.ph,
    required this.no3,
    required this.po4,
    required this.fe,
    required this.kh,
    required this.gh,
    required this.temp,
  });

  final String id;
  final DateTime timestamp;
  final double ph;
  final double no3;
  final double po4;
  final double fe;
  final double kh;
  final double gh;
  final double temp;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'ph': ph,
      'no3': no3,
      'po4': po4,
      'fe': fe,
      'kh': kh,
      'gh': gh,
      'temp': temp,
    };
  }

  factory WaterTest.fromMap(Map<String, dynamic> map) {
    return WaterTest(
      id: map['id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      ph: (map['ph'] as num).toDouble(),
      no3: (map['no3'] as num).toDouble(),
      po4: (map['po4'] as num).toDouble(),
      fe: (map['fe'] as num).toDouble(),
      kh: (map['kh'] as num).toDouble(),
      gh: (map['gh'] as num).toDouble(),
      temp: (map['temp'] as num).toDouble(),
    );
  }
}

class WaterChange {
  const WaterChange({
    required this.id,
    required this.timestamp,
    required this.volumeLiters,
    required this.notes,
  });

  final String id;
  final DateTime timestamp;
  final double volumeLiters;
  final String notes;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'volumeLiters': volumeLiters,
      'notes': notes,
    };
  }

  factory WaterChange.fromMap(Map<String, dynamic> map) {
    return WaterChange(
      id: map['id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      volumeLiters: (map['volumeLiters'] as num).toDouble(),
      notes: map['notes'] as String? ?? '',
    );
  }
}

// ===========================
// APLIKACJA
// ===========================

class AkwarystaProApp extends StatelessWidget {
  const AkwarystaProApp({
    this.firebaseReady = false,
    this.proPreferences,
    super.key,
  });

  final bool firebaseReady;
  final SharedPreferences? proPreferences;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.light,
    );

    return ChangeNotifierProvider<ProAccessService>(
      create: (_) => ProAccessService(preferences: proPreferences)..init(),
      child: ChangeNotifierProvider<models.AquariumProvider>(
        create: (_) => models.AquariumProvider()..initialize(),
        child: MaterialApp(
          title: 'Akwarysta PRO',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: colorScheme,
            scaffoldBackgroundColor: const Color(0xFFE0F2F1),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF4F6F8),
              foregroundColor: Color(0xFF123D39),
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 2,
              shadowColor: Colors.black12,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            textTheme: const TextTheme(
              titleLarge: TextStyle(fontWeight: FontWeight.bold),
              titleMedium: TextStyle(fontWeight: FontWeight.bold),
              titleSmall: TextStyle(fontWeight: FontWeight.bold),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE0E7E5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.teal, width: 2),
              ),
            ),
          ),
          home: firebaseReady
              ? const AuthWrapper(authenticatedScreen: MainShell())
              : const LoginScreen(),
          routes: {'/login': (_) => const LoginScreen()},
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final Aquarium _aquarium = Aquarium(
    id: 'aquarium-001',
    name: 'Akwarium Roślinne',
    capacityLiters: 112,
    setupDate: DateTime(2024, 3, 12),
    type: 'Roślinne',
  );

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(aquarium: _aquarium),
      const JournalAndRemindersScreen(),
      ToolsPage(aquarium: _aquarium),
      const ProfilePage(),
    ];

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFE1F5FE)],
          ),
        ),
        child: SizedBox.expand(
          child: IndexedStack(index: _currentIndex, children: pages),
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.teal.shade800,
          unselectedItemColor: Colors.grey.shade600,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Pulpit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Dziennik',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build_outlined),
              activeIcon: Icon(Icons.build),
              label: 'Narzędzia',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================
// PULPIT
// ===========================

class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.aquarium, super.key});

  final Aquarium aquarium;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<models.AquariumProvider>();
    final latestTest = provider.waterTests.isEmpty
        ? null
        : provider.waterTests.first;
    final latestChange = provider.waterChanges.isEmpty
        ? null
        : provider.waterChanges.first;
    final daysSinceChange = latestChange == null
        ? 0
        : DateTime.now().difference(latestChange.date).inDays;
    final isWaterFresh = latestChange != null && daysSinceChange < 7;
    final activeAquarium = provider.activeAquarium;
    final displayedAquarium = Aquarium(
      id: activeAquarium.id,
      name: activeAquarium.name,
      capacityLiters: activeAquarium.volumeNetLiters,
      setupDate: activeAquarium.setupDate,
      type: activeAquarium.type.label,
    );

    return _PageContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              eyebrow: 'AKWARYSTA PRO',
              title: 'Twój pulpit',
              subtitle: 'Wszystko, co ważne dla Twojego akwarium.',
              greeting: 'Cześć, Sławek! 👋',
              action: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TankSwitcher(),
                  IconButton(
                    tooltip: 'Powiadomienia',
                    onPressed: () =>
                        _showMessage(context, 'Brak nowych powiadomień'),
                    icon: const Icon(Icons.notifications_none),
                  ),
                ],
              ),
            ),
            const FirestoreAquariumsSection(),
            const SizedBox(height: 24),
            _AquariumCard(aquarium: displayedAquarium),
            const SizedBox(height: 20),
            _SectionHeader(title: 'Status akwarium'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.water_drop_outlined,
                    label: 'Ostatni test',
                    value: latestTest == null
                        ? 'Brak danych'
                        : _formatDate(latestTest.date),
                    subtitle: latestTest == null
                        ? 'Dodaj pierwszy test'
                        : '7 parametrów',
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.sync,
                    label: 'Podmiana',
                    value: '$daysSinceChange dni',
                    subtitle: isWaterFresh ? 'Woda świeża' : 'Czas na podmianę',
                    color: isWaterFresh ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _WaterStatusCard(
              daysSinceChange: daysSinceChange,
              isFresh: isWaterFresh,
            ),
            if (latestWaterAlert(latestTest) case final alert?) ...[
              const SizedBox(height: 12),
              _WaterAlertCard(test: latestTest!, alert: alert),
            ],
            const SizedBox(height: 24),
            _SectionHeader(title: 'Ostatnie parametry'),
            const SizedBox(height: 12),
            _WaterParametersCard(test: latestTest),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Szybkie akcje'),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.science_outlined,
              title: 'Wpisz wyniki testu wody',
              subtitle: 'Zapisz aktualne parametry zbiornika',
              accent: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WaterTestScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.water_drop_outlined,
              title: 'Dodaj podmianę wody',
              subtitle: 'Zapisz litraż i notatkę',
              accent: true,
              onTap: () => _showWaterChangeDialog(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showWaterChangeDialog(BuildContext context) {
    final volumeController = TextEditingController(text: '30');
    final notesController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Dodaj podmianę wody'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: volumeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Objętość',
                  suffixText: 'litrów',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notatka'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              onPressed: () {
                final volume =
                    double.tryParse(
                      volumeController.text.trim().replaceAll(',', '.'),
                    ) ??
                    0;
                if (volume <= 0) {
                  return;
                }

                context.read<models.AquariumProvider>().addWaterChange(
                  models.WaterChange(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    aquariumId: context
                        .read<models.AquariumProvider>()
                        .activeAquariumId,
                    date: DateTime.now(),
                    volumeLiters: volume,
                    notes: notesController.text.trim(),
                  ),
                );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Podmiana została zapisana')),
                );
              },
              child: const Text('Zapisz'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

// ===========================
// DZIENNIK
// ===========================

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = context
        .watch<models.AquariumProvider>()
        .journalEntries
        .map(_toJournalItem)
        .toList();

    return _PageContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(
              eyebrow: 'HISTORIA ZBIORNIKA',
              title: 'Dziennik',
              subtitle: 'Pełna historia opieki nad akwarium.',
            ),
            const WaterParametersChart(),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Ostatnie wpisy'),
            const SizedBox(height: 14),
            if (entries.isEmpty)
              const _EmptyJournalState()
            else
              ...entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _JournalCard(item: entry),
                ),
              ),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Wyświetlono wszystkie wpisy')),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('Pokaż starsze wpisy'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  _JournalItem _toJournalItem(models.JournalEntry entry) {
    final isWaterChange = entry.type == 'waterChange';
    return _JournalItem(
      icon: isWaterChange ? Icons.water_drop_outlined : Icons.science_outlined,
      color: isWaterChange ? Colors.blue : Colors.teal,
      title: entry.title,
      description: entry.description,
      timestamp: entry.date,
    );
  }
}

class _JournalItem {
  const _JournalItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final DateTime timestamp;
}

class _EmptyJournalState extends StatelessWidget {
  const _EmptyJournalState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.menu_book_outlined,
              color: Colors.teal.shade700,
              size: 36,
            ),
            const SizedBox(height: 10),
            const Text(
              'Dziennik jest jeszcze pusty',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('Dodaj pierwszy test wody lub podmianę.'),
          ],
        ),
      ),
    );
  }
}

// ===========================
// NARZĘDZIA
// ===========================

class ToolsPage extends StatelessWidget {
  const ToolsPage({required this.aquarium, super.key});

  final Aquarium aquarium;

  @override
  Widget build(BuildContext context) {
    return _PageContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(
              eyebrow: 'CENTRUM NARZĘDZI',
              title: 'Narzędzia',
              subtitle: 'Praktyczne funkcje dla każdego akwarysty.',
            ),
            _ToolCard(
              icon: Icons.water_drop_outlined,
              color: Colors.cyan,
              title: 'Akwaria i obsada',
              description: 'Przełącz zbiornik i zarządzaj fauną oraz florą.',
              buttonLabel: 'Otwórz zarządzanie',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AquariumManagementScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _ToolCard(
              icon: Icons.science_outlined,
              color: Colors.teal,
              title: 'Testy wody',
              description: 'Zapisuj pH, NO3, PO4, Fe, KH, GH i temperaturę.',
              buttonLabel: 'Otwórz testy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WaterTestScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _ToolCard(
              icon: Icons.menu_book_outlined,
              color: Colors.teal.shade700,
              title: 'Baza wiedzy i Atlas',
              description: 'Poznaj ryby, rośliny i sposoby walki z glonami.',
              buttonLabel: 'Otwórz Atlas',
              premium: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const KnowledgeBaseScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _ToolCard(
              icon: Icons.calculate_outlined,
              color: Colors.indigo,
              title: 'Kalkulator nawożenia',
              description: 'Oblicz dawki dzienne i tygodniowe dla zbiornika.',
              buttonLabel: 'Otwórz kalkulator',
              premium: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AquariumCalculatorsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _ToolCard(
              icon: Icons.auto_awesome,
              color: Colors.deepPurple,
              title: 'Skaner AI ryb i roślin',
              description:
                  'Rozpoznaj gatunek ze zdjęcia i poznaj jego wymagania.',
              buttonLabel: 'Wypróbuj PRO',
              premium: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiScannerPage()),
                );
              },
            ),
            const SizedBox(height: 12),
            _ToolCard(
              icon: Icons.eco_outlined,
              color: Colors.green.shade700,
              title: 'Asystent glonów',
              description: 'Zdiagnozuj problem i otrzymaj plan działania.',
              buttonLabel: 'Rozpocznij diagnozę',
              onTap: () => _showAlgaeDialog(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAlgaeDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AlgaeAssistantPage()),
    );
  }
}

class _AlgaeTypeOption {
  const _AlgaeTypeOption(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

class AlgaeAssistantPage extends StatefulWidget {
  const AlgaeAssistantPage({super.key});

  @override
  State<AlgaeAssistantPage> createState() => _AlgaeAssistantPageState();
}

class _AlgaeAssistantPageState extends State<AlgaeAssistantPage> {
  static const _algaeTypes = [
    _AlgaeTypeOption('Krasnorosty / BBA', Icons.grass, Colors.deepOrange),
    _AlgaeTypeOption('Zielenice', Icons.brightness_5, Colors.green),
    _AlgaeTypeOption('Sinice / cyjanobakterie', Icons.water, Colors.blue),
    _AlgaeTypeOption('Okrzemki', Icons.blur_on, Colors.brown),
    _AlgaeTypeOption('Pył na szybie', Icons.blur_circular, Colors.amber),
    _AlgaeTypeOption('Nitkowate', Icons.linear_scale, Colors.lightGreen),
  ];

  final _service = AlgaeAssistantService();
  final _no3 = TextEditingController();
  final _po4 = TextEditingController();
  final _fe = TextEditingController();
  final _ph = TextEditingController();
  final _kh = TextEditingController();
  final _lightHours = TextEditingController(text: '8');
  final _picker = ImagePicker();
  String _selectedAlgae = _algaeTypes.first.label;
  String _substrate = 'Żwirek / piasek';
  bool _hasCo2 = false;
  Uint8List? _imageBytes;
  String? _imageMimeType;
  AlgaeDiagnosticResult? _result;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final latest = context
        .read<models.AquariumProvider>()
        .waterTests
        .firstOrNull;
    _no3.text = _formatMeasurement(latest?.no3);
    _po4.text = _formatMeasurement(latest?.po4);
    _fe.text = _formatMeasurement(latest?.fe);
    _ph.text = _formatMeasurement(latest?.ph);
    _kh.text = _formatMeasurement(latest?.kh);
  }

  @override
  void dispose() {
    for (final controller in [_no3, _po4, _fe, _ph, _kh, _lightHours]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asystent glonów')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Co widzisz w akwarium?',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _algaeTypes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 88,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final option = _algaeTypes[index];
                final selected = option.label == _selectedAlgae;
                return InkWell(
                  onTap: () => setState(() => _selectedAlgae = option.label),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected
                          ? option.color.withAlpha(25)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? option.color : Colors.black12,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(option.icon, color: option.color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            option.label,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(
                _imageBytes == null
                    ? 'Dodaj zdjęcie glonu (opcjonalnie)'
                    : 'Zmień zdjęcie glonu',
              ),
            ),
            if (_imageBytes != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(
                  _imageBytes!,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Ostatnie parametry wody',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Wartości zostały wczytane z najnowszego testu. Możesz je poprawić przed analizą.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            _measurementFields(),
            const SizedBox(height: 18),
            Text(
              'Warunki w akwarium',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _lightHours,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Światło',
                      suffixText: 'h',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _substrate,
                    decoration: const InputDecoration(
                      labelText: 'Podłoże',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFE0E7E5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal, width: 2),
                      ),
                    ),
                    items:
                        const [
                              'Żwirek / piasek',
                              'Soil aktywny',
                              'Podłoże mineralne',
                              'Inne',
                            ]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => _substrate = value!),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Podawanie CO2'),
              subtitle: const Text('Uwzględnij instalację CO2 w diagnozie'),
              value: _hasCo2,
              onChanged: (value) => setState(() => _hasCo2 = value),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loading ? null : _diagnose,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _loading ? 'Analizuję warunki...' : 'Zdiagnozuj problem',
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 18),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Analizuję glony i parametry akwarium...',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              ),
            ],
            if (_result case final result?) ...[
              const SizedBox(height: 18),
              _AlgaeResultCard(result: result, onSave: _saveToJournal),
            ],
          ],
        ),
      ),
    );
  }

  Widget _measurementFields() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _numberField(_no3, 'NO3', 'mg/l'),
        _numberField(_po4, 'PO4', 'mg/l'),
        _numberField(_fe, 'Fe', 'mg/l'),
        _numberField(_ph, 'pH', ''),
        _numberField(_kh, 'KH', '°dKH'),
      ],
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
    String suffix,
  ) {
    return SizedBox(
      width: 106,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, suffixText: suffix),
      ),
    );
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Aparat'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _imageMimeType = _mimeFor(file.name);
    });
  }

  Future<void> _diagnose() async {
    final input = AlgaeDiagnosticInput(
      algaeType: _selectedAlgae,
      no3: _number(_no3),
      po4: _number(_po4),
      fe: _number(_fe),
      ph: _number(_ph),
      kh: _number(_kh),
      lightHours: _number(_lightHours),
      co2: _hasCo2,
      substrate: _substrate,
      imageBytes: _imageBytes,
      imageMimeType: _imageMimeType,
    );
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await _service.diagnose(input);
      if (mounted) {
        setState(() {
          _result = result;
          _loading = false;
        });
      }
    } on Exception catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = error.toString();
        });
      }
    }
  }

  void _saveToJournal(AlgaeDiagnosticResult result) {
    final provider = context.read<models.AquariumProvider>();
    provider.addJournalEntry(
      models.JournalEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        aquariumId: provider.activeAquariumId,
        date: DateTime.now(),
        title: 'Diagnoza glonów: ${result.algaeName}',
        description:
            '${result.cause}\n\nPlan działania:\n${result.actions.asMap().entries.map((entry) => '${entry.key + 1}. ${entry.value}').join('\n')}',
        type: 'algaeDiagnosis',
        category: models.JournalCategory.algae,
        tags: const ['glony', 'diagnoza'],
        attachedWaterParameters: {
          'NO3': _number(_no3),
          'PO4': _number(_po4),
          'Fe': _number(_fe),
          'pH': _number(_ph),
          'KH': _number(_kh),
        },
        imagePaths: _imageBytes == null
            ? const []
            : ['data:${_imageMimeType ?? 'image/jpeg'};base64,${base64Encode(_imageBytes!)}'],
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnoza została zapisana w dzienniku')),
    );
  }

  double _number(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.')) ?? 0;

  String _formatMeasurement(double? value) => value == null
      ? ''
      : value.toStringAsFixed(2).replaceFirst(RegExp(r'\.00$'), '');

  String _mimeFor(String name) =>
      name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
}

class _AlgaeResultCard extends StatelessWidget {
  const _AlgaeResultCard({required this.result, required this.onSave});

  final AlgaeDiagnosticResult result;
  final ValueChanged<AlgaeDiagnosticResult> onSave;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.isMock)
              const Chip(
                avatar: Icon(Icons.science_outlined, size: 18),
                label: Text('Wynik demonstracyjny'),
              ),
            Text(
              'Diagnoza: ${result.algaeName}',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(result.cause),
            const SizedBox(height: 18),
            Text(
              'Plan działania',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...result.actions.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(entry.value)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => onSave(result),
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('Zapisz do Dziennika'),
            ),
          ],
        ),
      ),
    );
  }
}

class AiScannerPage extends StatefulWidget {
  const AiScannerPage({super.key});

  @override
  State<AiScannerPage> createState() => _AiScannerPageState();
}

class _AiScannerPageState extends State<AiScannerPage> {
  final _picker = ImagePicker();
  final _service = AiScannerService();
  Uint8List? _imageBytes;
  String? _mimeType;
  AiScanResult? _result;
  String? _error;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skaner AI')),
      body: _PageContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _PremiumBanner(),
              const SizedBox(height: 20),
              InkWell(
                onTap: _chooseSource,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 260,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F2EF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _imageBytes == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera_outlined,
                              size: 64,
                              color: Colors.teal.shade700,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Dodaj zdjęcie ryby lub rośliny',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Dotknij, aby wybrać Aparat lub Galerię',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isLoading
                    ? null
                    : (_imageBytes == null ? _chooseSource : _analyze),
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _isLoading ? 'Analizuję zdjęcie...' : 'Uruchom rozpoznawanie',
                ),
              ),
              if (_isLoading) ...[
                const SizedBox(height: 20),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text('Analizuję zdjęcie ryby/rośliny...'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 20),
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_result case final result?) ...[
                const SizedBox(height: 20),
                _ScanResultCard(result: result, imageBytes: _imageBytes!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _chooseSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Aparat'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeria zdjęć'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1800,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _mimeType = _mimeFor(file.name);
        _result = null;
        _error = null;
      });
    } on Exception catch (error) {
      if (mounted) {
        setState(() => _error = 'Nie udało się otworzyć zdjęcia: $error');
      }
    }
  }

  Future<void> _analyze() async {
    final image = _imageBytes;
    if (image == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await _service.analyze(image, _mimeType ?? 'image/jpeg');
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Analiza trwała zbyt długo. Sprawdź połączenie i spróbuj ponownie.';
        });
      }
    } on Exception catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = error.toString();
        });
      }
    }
  }

  String _mimeFor(String name) {
    final extension = name.split('.').last.toLowerCase();
    return extension == 'png'
        ? 'image/png'
        : extension == 'webp'
        ? 'image/webp'
        : 'image/jpeg';
  }
}

// ===========================
// PROFIL
// ===========================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PageContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(
              eyebrow: 'TWOJE KONTO',
              title: 'Profil i PRO',
              subtitle: 'Zarządzaj akwarium oraz ustawieniami konta.',
            ),
            const _ProCard(),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Aktywne akwarium'),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.water,
              title: 'Akwarium Roślinne',
              subtitle: '112 litrów · Roślinne',
              onTap: () => _openAquariumManagement(context),
            ),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.add_circle_outline,
              title: 'Dodaj nowe akwarium',
              subtitle: 'Plan Free: do 3 zbiorników',
              onTap: () => _openAquariumManagement(context),
            ),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Ustawienia'),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.notifications_none,
              title: 'Powiadomienia',
              subtitle: 'Przypomnienia o testach i podmianach',
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.cloud_outlined,
              title: 'Synchronizacja danych',
              subtitle: 'Przygotowane pod Firebase lub Supabase',
              onTap: () => _showMessage(
                context,
                'Synchronizacja zostanie podłączona w kolejnym etapie',
              ),
            ),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.logout,
              title: 'Wyloguj się',
              subtitle: 'Zakończ bieżącą sesję na tym urządzeniu',
              onTap: () => _signOut(context),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 28),
            const AppVersionWidget(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _openAquariumManagement(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const AquariumManagementScreen()),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await AuthService().signOut();
      if (context.mounted) {
        await Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (_) => false);
      }
    } on AuthException catch (error) {
      if (context.mounted) _showMessage(context, error.message);
    }
  }
}

// ===========================
// WSPÓLNE KOMPONENTY UI
// ===========================

class _PageContainer extends StatelessWidget {
  const _PageContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth < 600
            ? constraints.maxWidth
            : 600.0;

        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(width: contentWidth, child: child),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.greeting,
    this.action,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String? greeting;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (greeting != null || action != null)
            Row(
              children: [
                if (greeting != null)
                  Expanded(
                    child: Text(
                      greeting!,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                ...?(action == null ? null : <Widget>[action!]),
              ],
            ),
          if (greeting != null || action != null) const SizedBox(height: 12),
          Text(
            eyebrow,
            style: TextStyle(
              color: Colors.teal.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF123D39),
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF123D39),
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }
}

class _AquariumCard extends StatelessWidget {
  const _AquariumCard({required this.aquarium});

  final Aquarium aquarium;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00695C),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2800695C),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(35),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.water, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aquarium.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${aquarium.capacityLiters.toStringAsFixed(0)} litrów · ${aquarium.type}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white70),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 14),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF123D39),
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterStatusCard extends StatelessWidget {
  const _WaterStatusCard({
    required this.daysSinceChange,
    required this.isFresh,
  });

  final int daysSinceChange;
  final bool isFresh;

  @override
  Widget build(BuildContext context) {
    final color = isFresh ? Colors.green.shade700 : Colors.orange.shade800;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        children: [
          Icon(isFresh ? Icons.check_circle : Icons.schedule, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isFresh
                  ? 'Woda jest świeża. Ostatnia podmiana była $daysSinceChange dni temu.'
                  : 'Czas zaplanować kolejną podmianę wody.',
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterParametersCard extends StatelessWidget {
  const _WaterParametersCard({required this.test});

  final models.WaterTest? test;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: test == null
            ? Column(
                children: [
                  Icon(
                    Icons.science_outlined,
                    color: Colors.teal.shade700,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Brak zapisanych pomiarów',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Dodaj pierwszy test, aby śledzić kondycję wody.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WaterTestScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.add_chart_outlined),
                    label: const Text('Dodaj pierwszy pomiar'),
                  ),
                ],
              )
            : Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ParameterChip(label: 'pH', value: test!.ph.toString()),
                  _ParameterChip(label: 'NO3', value: '${test!.no3} mg/l'),
                  _ParameterChip(label: 'PO4', value: '${test!.po4} mg/l'),
                  _ParameterChip(label: 'Fe', value: '${test!.fe} mg/l'),
                  _ParameterChip(label: 'KH', value: '${test!.kh} dKH'),
                  _ParameterChip(label: 'GH', value: '${test!.gh} dGH'),
                  _ParameterChip(label: 'Temp.', value: '${test!.temp}°C'),
                ],
              ),
      ),
    );
  }
}

class _WaterAlertCard extends StatelessWidget {
  const _WaterAlertCard({required this.test, required this.alert});

  final models.WaterTest test;
  final WaterAssessment alert;

  @override
  Widget build(BuildContext context) {
    final isCritical = alert.status == WaterStatus.critical;
    final color = isCritical ? Colors.red.shade700 : Colors.orange.shade800;
    final parameter = WaterParameter.values.firstWhere(
      (item) =>
          assessWaterValue(item, waterValue(test, item)).message ==
          alert.message,
      orElse: () => WaterParameter.ph,
    );
    final value = waterValue(test, parameter);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${alert.label}: ${alert.message} (${value.toStringAsFixed(1)})',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParameterChip extends StatelessWidget {
  const _ParameterChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3F1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label\n',
              style: const TextStyle(
                color: Color(0xFF00796B),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Color(0xFF123D39),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: accent
              ? Colors.teal.shade700
              : const Color(0xFFE1F2EF),
          foregroundColor: accent ? Colors.white : Colors.teal.shade800,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: accent ? const Color(0xFF00695C) : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          accent ? Icons.add_circle_outline : Icons.arrow_forward_ios,
          size: accent ? 26 : 16,
          color: accent ? Colors.teal.shade700 : null,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.item});

  final _JournalItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: item.color.withAlpha(25),
          foregroundColor: item.color,
          child: Icon(item.icon),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(item.description),
        trailing: Text(
          _formatDateTime(item.timestamp),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onTap,
    this.premium = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onTap;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    final showProBadge =
        premium && !context.watch<ProAccessService>().isProUser;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withAlpha(25),
                  foregroundColor: color,
                  child: Icon(icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                if (showProBadge) const _ProBadge(),
              ],
            ),
            const SizedBox(height: 12),
            Text(description),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: onTap, child: Text(buttonLabel)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.teal.shade700),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _ProCard extends StatelessWidget {
  const _ProCard();

  @override
  Widget build(BuildContext context) {
    final isProUser = context.watch<ProAccessService>().isProUser;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isProUser ? const Color(0xFF315B43) : const Color(0xFF123D39),
        border: isProUser
            ? Border.all(color: const Color(0xFFFFD166), width: 1.5)
            : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isProUser ? null : () => ProPaywallDialog.show(context),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Icon(
              isProUser ? Icons.verified : Icons.auto_awesome,
              color: const Color(0xFFFFD166),
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isProUser ? 'Akwarysta PRO (Aktywny)' : 'Akwarysta PRO',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isProUser
                        ? 'Wszystkie funkcje premium są odblokowane'
                        : 'Odblokuj AI, wykresy i nielimitowane akwaria.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            if (!isProUser) const _ProBadge(),
          ],
        ),
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner();

  @override
  Widget build(BuildContext context) {
    return const _ProCard();
  }
}

class _ProBadge extends StatelessWidget {
  const _ProBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD166),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          color: Color(0xFF123D39),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ScanResultCard extends StatelessWidget {
  const _ScanResultCard({required this.result, required this.imageBytes});

  final AiScanResult result;
  final Uint8List imageBytes;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.isMock) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.science_outlined,
                      size: 18,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Wynik demonstracyjny. Endpoint AI nie jest dostępny.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    imageBytes,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rozpoznano: ${result.polishName}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${result.latinName} · ${result.type}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('pH ${result.ph}')),
                Chip(label: Text('${result.temperature}°C')),
                Chip(label: Text(result.difficulty)),
                Chip(label: Text('od ${result.minimumVolume} l')),
              ],
            ),
            const SizedBox(height: 8),
            Text(result.description),
            const SizedBox(height: 10),
            Text(
              'Zgodność z obsadą',
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(result.compatibility),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                final provider = context.read<models.AquariumProvider>();
                final type = result.type.toLowerCase();
                final category =
                    type.contains('roślin') || type.contains('roslin')
                    ? models.CreatureCategory.plant
                    : type.contains('ryb')
                    ? models.CreatureCategory.fish
                    : models.CreatureCategory.other;
                provider.addInhabitant(
                  models.Inhabitant(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    aquariumId: provider.activeAquariumId,
                    name: result.polishName,
                    latinName: result.latinName,
                    category: category,
                    count: 1,
                    addedDate: DateTime.now(),
                    difficulty: result.difficulty,
                    notes:
                        '${result.description}\n\nZgodność: ${result.compatibility}',
                    imagePath:
                        'data:image/jpeg;base64,${base64Encode(imageBytes)}',
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gatunek dodano do obsady')),
                );
              },
              icon: const Icon(Icons.playlist_add),
              label: const Text('Dodaj do mojego akwarium / obsady'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================
// FORMATOWANIE DAT
// ===========================

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

String _formatDateTime(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$day.$month.${date.year}\n$hour:$minute';
}
