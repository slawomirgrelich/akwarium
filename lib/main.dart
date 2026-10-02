import 'firebase_options.dart';

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';

import 'algae_assistant_service.dart';
import 'ai_scanner_service.dart';
import 'app_version_widget.dart';
import 'aquarium_management_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'local_reminder_service.dart';
import 'models/aquarium_model.dart' as models;
import 'models/aquarium_firestore_model.dart' show AquariumModel;
import 'models/water_standards.dart';
import 'models/tank_firestore_models.dart' show Tank;
import 'screens/aquarium_details_screen.dart';
import 'screens/auth_wrapper.dart';
import 'screens/calculators_screen.dart';
import 'screens/help_center_screen.dart';
import 'screens/journal_and_reminders_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/referral_screen.dart';
import 'screens/species_atlas_screen.dart';
import 'services/auth_service.dart';
import 'services/admin_service.dart';
import 'services/database_service.dart';
import 'services/firestore_service.dart';
import 'services/firestore_sync_status.dart';
import 'services/pro_access_service.dart';
import 'services/referral_service.dart';
import 'services/theme_controller.dart';
import 'services/locale_controller.dart';
import 'services/ticket_service.dart';
import 'theme/app_theme.dart';
import 'water_parameters_chart.dart';
import 'water_test_screen.dart';
import 'widgets/pro_paywall_dialog.dart';
import 'widgets/firestore_reminders_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
    firebaseReady = true;
  } catch (error) {
    debugPrint('Firebase initialization failed: $error');
  }

  final preferences = await SharedPreferences.getInstance();
  await initializeDateFormatting('en_US', null);
  await initializeDateFormatting('pl_PL', null);
  await LocalReminderService.instance.initialize();
  runApp(
    AkwarystaProApp(firebaseReady: firebaseReady, proPreferences: preferences),
  );
}

// ===========================
// MODELE DANYCH
// ===========================

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
    return ChangeNotifierProvider<ProAccessService>(
      create: (_) => ProAccessService(preferences: proPreferences)..init(),
      child: ChangeNotifierProvider<ThemeController>(
        create: (_) => ThemeController(preferences: proPreferences)..init(),
        child: ChangeNotifierProvider<LocaleController>(
          create: (_) => LocaleController(preferences: proPreferences)..init(),
          child: firebaseReady
              ? ChangeNotifierProvider<ReferralService>(
                  create: (_) => ReferralService()..init(),
                  child: ChangeNotifierProvider<TicketService>(
                    create: (_) => TicketService(),
                    child: ChangeNotifierProvider<models.AquariumProvider>(
                      create: (_) => models.AquariumProvider()..initialize(),
                      child: Builder(
                        builder: (context) => _buildApp(context, firebaseReady),
                      ),
                    ),
                  ),
                )
              : ChangeNotifierProvider<models.AquariumProvider>(
                  create: (_) => models.AquariumProvider()..initialize(),
                  child: Builder(
                    builder: (context) => _buildApp(context, firebaseReady),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildApp(BuildContext context, bool firebaseReady) {
    return MaterialApp(
      title: 'Akwarysta PRO',
      debugShowCheckedModeBanner: false,
      locale: context.watch<LocaleController>().locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: context.watch<ThemeController>().themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: firebaseReady
          ? const AuthWrapper(authenticatedScreen: MainShell())
          : const LoginScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/dashboard': (_) => const MainShell(),
      },
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      const DashboardPage(),
      const JournalAndRemindersScreen(),
      const ToolsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SizedBox.expand(
          child: IndexedStack(index: _currentIndex, children: pages),
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
              Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.18),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Theme.of(context)
              .bottomNavigationBarTheme
              .selectedItemColor,
          unselectedItemColor: Theme.of(context)
              .bottomNavigationBarTheme
              .unselectedItemColor,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: l10n.navDashboard,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: l10n.navJournal,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build_outlined),
              activeIcon: Icon(Icons.build),
              label: l10n.navTools,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: l10n.navProfile,
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
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<models.AquariumProvider>();
    final activeAquarium = provider.selectedAquarium;
    if (activeAquarium == null || activeAquarium.id.trim().isEmpty) {
      return _PageContainer(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                eyebrow: 'AKWARYSTA PRO',
                title: l10n.yourDashboard,
                subtitle: l10n.dashboardSubtitle,
              ),
              const SizedBox(height: 24),
              Text(l10n.dashboardNoAquarium, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AquariumManagementScreen(),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: Text(l10n.addNewAquarium),
              ),
            ],
          ),
        ),
      );
    }
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
    return _PageContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.userChanges(),
              initialData: FirebaseAuth.instance.currentUser,
              builder: (context, userSnapshot) => _Header(
                eyebrow: 'AKWARYSTA PRO',
                title: l10n.yourDashboard,
                subtitle: l10n.dashboardSubtitle,
                greeting: _dashboardGreeting(
                  userSnapshot.data ?? FirebaseAuth.instance.currentUser,
                  Localizations.localeOf(context).languageCode,
                ),
                action: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TankSwitcher(),
                    IconButton(
                      tooltip: l10n.notifications,
                      onPressed: context.read<ProAccessService>().isProUser
                          ? () => Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RemindersScreen(),
                              ),
                            )
                          : () =>
                                _showMessage(context, l10n.noNewNotifications),
                      icon: const Icon(Icons.notifications_none),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const AquariumManagementScreen(),
                ),
              ),
              child: _DashboardTankCard(aquarium: activeAquarium),
            ),
            const SizedBox(height: 20),
            if (context.watch<ProAccessService>().isProUser) ...[
              const FirestoreRemindersWidget(),
              const SizedBox(height: 20),
            ],
            _SectionHeader(title: l10n.aquariumStatus),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.water_drop_outlined,
                    label: l10n.lastTest,
                    value: latestTest == null
                        ? l10n.noData
                        : _formatDate(latestTest.date),
                    subtitle: latestTest == null
                        ? l10n.addFirstTest
                        : l10n.parametersCount,
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.sync,
                    label: l10n.waterChange,
                    value: l10n.daysCount(daysSinceChange),
                    subtitle: isWaterFresh
                        ? l10n.freshWater
                        : l10n.timeForWaterChange,
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
            _SectionHeader(title: l10n.recentParameters),
            const SizedBox(height: 12),
            _WaterParametersCard(test: latestTest),
            const SizedBox(height: 24),
            _SectionHeader(title: l10n.quickActions),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.science_outlined,
              title: l10n.enterWaterTest,
              subtitle: l10n.saveTankParameters,
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
              title: l10n.addWaterChange,
              subtitle: l10n.saveVolumeAndNote,
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
    final l10n = AppLocalizations.of(context)!;
    final volumeController = TextEditingController(text: '30');
    final notesController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.addWaterChange),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: volumeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.volume,
                  suffixText: l10n.liters,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: l10n.note),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
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
                  SnackBar(content: Text(l10n.saveTankParameters)),
                );
              },
              child: Text(l10n.save),
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
    final l10n = AppLocalizations.of(context)!;
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
            _Header(
              eyebrow: l10n.historyOfTank,
              title: l10n.journal,
              subtitle: l10n.journalSubtitle,
            ),
            const WaterParametersChart(),
            const SizedBox(height: 24),
            _SectionHeader(title: l10n.recentEntries),
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.showOlderEntries)));
              },
              icon: const Icon(Icons.history),
              label: Text(l10n.showOlderEntries),
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
    final l10n = AppLocalizations.of(context)!;
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
            Text(
              l10n.journalEmpty,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(l10n.addFirstWaterEntry),
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
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _PageContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              eyebrow: l10n.toolsCenter,
              title: l10n.tools,
              subtitle: l10n.toolsSubtitle,
            ),
            _ToolCard(
              icon: Icons.water_drop_outlined,
              color: Colors.cyan,
              title: l10n.tanksAndStock,
              description: l10n.tanksAndStockDescription,
              buttonLabel: l10n.openManagement,
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
              title: l10n.waterTests,
              description: l10n.waterTestsDescription,
              buttonLabel: l10n.openTests,
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
              title: l10n.knowledgeBaseTitle,
              description: l10n.knowledgeBaseDesc,
              buttonLabel: l10n.openAtlas,
              premium: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpeciesAtlasScreen(
                      tankId: context
                          .read<models.AquariumProvider>()
                          .activeAquariumId,
                      onCreateAquarium: () => showCreateAquariumDialog(context),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _ToolCard(
              icon: Icons.calculate_outlined,
              color: Colors.indigo,
              title: l10n.fertilizerCalcTitle,
              description: l10n.fertilizerCalcDesc,
              buttonLabel: l10n.openCalculator,
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
              title: l10n.aiScannerTitle,
              description: l10n.aiScannerDesc,
              buttonLabel: l10n.tryPro,
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
              title: l10n.algaeAssistantTitle,
              description: l10n.algaeAssistantDesc,
              buttonLabel: l10n.startDiagnosis,
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
  const _AlgaeTypeOption(this.value, this.label, this.icon, this.color);

  final String value;
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
  static const _algaeValues = [
    'Krasnorosty / BBA',
    'Zielenice',
    'Sinice / cyjanobakterie',
    'Okrzemki',
    'Pył na szybie',
    'Nitkowate',
  ];

  final _service = AlgaeAssistantService();
  final _no3 = TextEditingController();
  final _po4 = TextEditingController();
  final _fe = TextEditingController();
  final _ph = TextEditingController();
  final _kh = TextEditingController();
  final _lightHours = TextEditingController(text: '8');
  final _picker = ImagePicker();
  final _editedWaterFields = <String>{};
  String _selectedAlgae = _algaeValues.first;
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
    final provider = context.read<models.AquariumProvider>();
    final aquariumId = provider.activeAquariumId;
    final latest = provider.waterTests.firstOrNull;
    _no3.text = _formatMeasurement(latest?.no3);
    _po4.text = _formatMeasurement(latest?.po4);
    _fe.text = _formatMeasurement(latest?.fe);
    _ph.text = _formatMeasurement(latest?.ph);
    _kh.text = _formatMeasurement(latest?.kh);
    unawaited(_prefillLatestFirestoreMeasurement(aquariumId));
  }

  Future<void> _prefillLatestFirestoreMeasurement(String aquariumId) async {
    if (aquariumId.trim().isEmpty) return;
    try {
      final measurements = await FirestoreService()
          .getWaterParameters(aquariumId)
          .first;
      if (!mounted || measurements.isEmpty) return;
      final latest = measurements.first;
      setState(() {
        if (!_editedWaterFields.contains('NO3')) {
          _no3.text = _formatMeasurement(latest.no3);
        }
        if (!_editedWaterFields.contains('PO4')) {
          _po4.text = _formatMeasurement(latest.po4);
        }
        if (!_editedWaterFields.contains('Fe')) {
          _fe.text = _formatMeasurement(latest.fe);
        }
        if (!_editedWaterFields.contains('pH')) {
          _ph.text = _formatMeasurement(latest.ph);
        }
        if (!_editedWaterFields.contains('KH')) {
          _kh.text = _formatMeasurement(latest.kh);
        }
      });
    } on Object catch (error) {
      debugPrint('Nie udało się pobrać ostatnich parametrów wody: $error');
    }
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final algaeTypes = [
      _AlgaeTypeOption(
        _algaeValues[0],
        l10n.algaeBba,
        Icons.grass,
        Colors.deepOrange,
      ),
      _AlgaeTypeOption(
        _algaeValues[1],
        l10n.algaeGreen,
        Icons.brightness_5,
        Colors.green,
      ),
      _AlgaeTypeOption(
        _algaeValues[2],
        l10n.algaeCyanobacteria,
        Icons.water,
        Colors.blue,
      ),
      _AlgaeTypeOption(
        _algaeValues[3],
        l10n.algaeDiatoms,
        Icons.blur_on,
        Colors.brown,
      ),
      _AlgaeTypeOption(
        _algaeValues[4],
        l10n.algaeDust,
        Icons.blur_circular,
        Colors.amber,
      ),
      _AlgaeTypeOption(
        _algaeValues[5],
        l10n.algaeThread,
        Icons.linear_scale,
        Colors.lightGreen,
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.algaeAssistantTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.algaeQuestion,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: algaeTypes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 88,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final option = algaeTypes[index];
                final selected = option.value == _selectedAlgae;
                return InkWell(
                  onTap: () => setState(() => _selectedAlgae = option.value),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected
                          ? option.color.withAlpha(25)
                          : theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? option.color
                            : theme.colorScheme.outline,
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
                    ? l10n.addAlgaePhotoOptional
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
              l10n.recentWaterParams,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.paramsLoadedInfo,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            _measurementFields(),
            const SizedBox(height: 18),
            Text(
              l10n.tankConditions,
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
                    decoration: InputDecoration(
                      labelText: l10n.lightHours,
                      suffixText: 'h',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _substrate,
                    dropdownColor: Theme.of(context).cardColor,
                    decoration: InputDecoration(
                      labelText: l10n.substrateType,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
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
                                child: Text(
                                  value == 'Żwirek / piasek'
                                      ? l10n.gravelSand
                                      : value,
                                ),
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
              title: Text(l10n.co2Dosing),
              subtitle: Text(l10n.includeCo2InDiagnosis),
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
                _loading ? 'Analizuję warunki...' : l10n.diagnoseProblem,
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
        onChanged: (_) => _editedWaterFields.add(label),
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
      SnackBar(content: Text(AppLocalizations.of(context)!.diagnosisSaved)),
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
              label: Text(AppLocalizations.of(context)!.saveToJournal),
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
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
                    color: theme.cardColor,
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
                            Text(
                              l10n.addFishOrPlantPhoto,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.tapToSelectCameraOrGallery,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
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
                  _isLoading ? 'Analizuję zdjęcie...' : l10n.runRecognition,
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
    final l10n = AppLocalizations.of(context)!;
    final proService = context.watch<ProAccessService>();
    final activeAquarium = context
        .watch<models.AquariumProvider>()
        .selectedAquarium;
    if (proService.trialExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted || !proService.consumeTrialExpired()) return;
        ProPaywallDialog.show(context);
      });
    }

    return _PageContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              eyebrow: l10n.account,
              title: l10n.profileTitle,
              subtitle: l10n.profileSubtitle,
            ),
            const _ProCard(),
            const SizedBox(height: 10),
            const _ProfileDisplayNameTile(),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.card_giftcard_outlined,
              title: l10n.referralTitle,
              subtitle: l10n.referralSubtitle,
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const ReferralScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.support_agent_outlined,
              title: l10n.helpCenterTitle,
              subtitle: l10n.helpCenterSubtitle,
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: l10n.activeAquariumSection),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.water,
              title: activeAquarium?.name ?? l10n.noActiveAquarium,
              subtitle: activeAquarium == null
                  ? l10n.addAquariumToStart
                  : '${activeAquarium.volumeNetLiters.round()} L · ${_localizedTankType(l10n, activeAquarium.type)}',
              onTap: () => _openAquariumManagement(context),
            ),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.add_circle_outline,
              title: l10n.addNewAquarium,
              subtitle: context.watch<ProAccessService>().isProUser
                  ? l10n.proPlanUnlimitedAquariums
                  : l10n.freePlan,
              onTap: () => _openAquariumManagement(context),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: l10n.settings),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.notifications_none,
              title: l10n.notifications,
              subtitle: l10n.notificationsSubtitle,
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.key_outlined,
              title: l10n.geminiApiKeyLabel,
              subtitle: l10n.aiScannerConfig,
              onTap: () => _showGeminiKeyDialog(context),
            ),
            const SizedBox(height: 10),
            const _ThemeModeTile(),
            const SizedBox(height: 10),
            const _LocaleTile(),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.cloud_sync_outlined,
              title: l10n.cloudBackupSyncTitle,
              subtitle: l10n.cloudBackupSyncSubtitle,
              onTap: () => _showCloudSyncDialog(context),
            ),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.logout,
              title: l10n.logOut,
              subtitle: l10n.logOutSubtitle,
              onTap: () => _signOut(context),
            ),
            if (FirebaseAuth.instance.currentUser
                case final adminCandidate?) ...[
              const SizedBox(height: 10),
              _AdminPanelTile(userId: adminCandidate.uid),
            ],
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

  void _showCloudSyncDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.cloud_done_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 36,
        ),
        title: Text(l10n.cloudBackupSyncTitle),
        content: FutureBuilder<DateTime?>(
          future: FirestoreSyncStatus.getLastSuccessfulSync(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final syncedAt = snapshot.data;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.cloudSyncDescription, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  '${l10n.lastSyncLabel} ${syncedAt == null ? l10n.lastSyncNone : _formatSyncDateTime(syncedAt)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          },
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  Future<void> _showGeminiKeyDialog(BuildContext context) async {
    final preferences = await SharedPreferences.getInstance();
    if (!context.mounted) return;
    final controller = TextEditingController(
      text: preferences.getString('gemini_api_key') ?? '',
    );
    var isTestingKey = false;
    String? keyTestMessage;
    bool keyTestSucceeded = false;
    final key = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.geminiApiKeyLabel),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                obscureText: true,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.apiKeyLabel,
                  hintText: AiScannerService.defaultApiKey.trim().isEmpty
                      ? AppLocalizations.of(context)!.geminiApiKeyManualHint
                      : AppLocalizations.of(context)!.apiKeyHint,
                ),
              ),
              if (keyTestMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  keyTestMessage!,
                  style: TextStyle(
                    color: keyTestSucceeded
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isTestingKey
                  ? null
                  : () async {
                      setDialogState(() {
                        isTestingKey = true;
                        keyTestMessage = null;
                      });
                      try {
                        await AiScannerService().testApiKey(controller.text);
                        if (!dialogContext.mounted) return;
                        setDialogState(() {
                          keyTestSucceeded = true;
                          keyTestMessage = AppLocalizations.of(dialogContext)!
                              .geminiConnectionSucceeded;
                        });
                      } on Object catch (error) {
                        if (!dialogContext.mounted) return;
                        setDialogState(() {
                          keyTestSucceeded = false;
                          keyTestMessage = error.toString();
                        });
                      } finally {
                        if (dialogContext.mounted) {
                          setDialogState(() => isTestingKey = false);
                        }
                      }
                    },
              child: isTestingKey
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppLocalizations.of(dialogContext)!.testApiKey),
            ),
            if (AiScannerService.defaultApiKey.trim().isNotEmpty)
              TextButton(
                onPressed: isTestingKey
                    ? null
                    : () => Navigator.pop(dialogContext, ''),
                child: Text(AppLocalizations.of(dialogContext)!.useDefaultKey),
              ),
            TextButton(
              onPressed: isTestingKey
                  ? null
                  : () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(dialogContext)!.cancel),
            ),
            FilledButton(
              onPressed: isTestingKey
                  ? null
                  : () => Navigator.pop(dialogContext, controller.text.trim()),
              child: Text(AppLocalizations.of(dialogContext)!.save),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (key == null) return;
    if (key.isEmpty) {
      await preferences.remove('gemini_api_key');
    } else {
      await preferences.setString('gemini_api_key', key);
    }
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
    final theme = Theme.of(context);
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
                        color: theme.colorScheme.onSurfaceVariant,
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
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 15,
            ),
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
  const _AquariumCard({required this.aquarium, this.imageUrl});

  final models.AquariumProfile aquarium;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: imageUrl == null || imageUrl!.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(13),
                    color: theme.colorScheme.primary.withAlpha(35),
                    child: Icon(
                      Icons.water,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  )
                : Image.network(
                    imageUrl!,
                    width: 66,
                    height: 66,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aquarium.name,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${l10n.litersCount(aquarium.volumeNetLiters.round())} · ${_localizedAquariumType(l10n, aquarium.type.label)}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.daysCount(aquarium.ageInDays),
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _DashboardTankCard extends StatelessWidget {
  const _DashboardTankCard({required this.aquarium});

  final models.AquariumProfile aquarium;

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || userId.trim().isEmpty) {
      return _AquariumCard(aquarium: aquarium);
    }
    return StreamBuilder<List<Tank>>(
      stream: DatabaseService().getTanksStream(userId),
      builder: (context, snapshot) {
        final tank = snapshot.data
            ?.where((item) => item.id == aquarium.id)
            .firstOrNull;
        return _AquariumCard(
          aquarium: aquarium,
          imageUrl: tank?.effectiveCoverPhotoUrl,
        );
      },
    );
  }
}

String _localizedAquariumType(AppLocalizations l10n, String type) {
  final normalized = type.toLowerCase();
  if (normalized.contains('słod') || normalized.contains('fresh')) {
    return l10n.freshwater;
  }
  if (normalized.contains('morsk') || normalized.contains('salt')) {
    return l10n.saltwater;
  }
  if (normalized.contains('brack')) return l10n.brackish;
  return type;
}

String _dashboardGreeting(User? user, String languageCode) {
  final displayName = user?.displayName?.trim();
  final emailName = user?.email?.split('@').first.trim();
  final name = displayName != null && displayName.isNotEmpty
      ? displayName
      : emailName != null && emailName.isNotEmpty
      ? emailName
      : null;
  if (name == null) return languageCode == 'pl' ? 'Cześć! 👋' : 'Hello! 👋';
  return languageCode == 'pl' ? 'Cześć, $name! 👋' : 'Hello, $name! 👋';
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
    final theme = Theme.of(context);
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
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
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
    final l10n = AppLocalizations.of(context)!;
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
                  ? l10n.freshWaterLastChange(daysSinceChange)
                  : l10n.scheduleNextChange,
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
    final l10n = AppLocalizations.of(context)!;
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
                  Text(
                    l10n.noSavedMeasurements,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(l10n.addFirstTestTrack, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WaterTestScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.add_chart_outlined),
                    label: Text(l10n.addFirstMeasurement),
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
    final isProUser = context.watch<ProAccessService>().isProUser;
    final showProBadge = premium && !isProUser;
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
              child: OutlinedButton(
                onPressed: premium && !isProUser
                    ? () => ProPaywallDialog.show(context, headline: title)
                    : onTap,
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _localizedTankType(AppLocalizations l10n, models.TankType type) =>
    switch (type) {
      models.TankType.freshwater => l10n.freshwaterType,
      models.TankType.marine => l10n.saltwaterType,
      models.TankType.planted => l10n.plantedTankType,
      models.TankType.biotope => l10n.biotopeTankType,
      models.TankType.shrimp => l10n.shrimpTankType,
    };

class _AdminPanelTile extends StatelessWidget {
  const _AdminPanelTile({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
    stream: AdminService().watchAdminAccess(userId),
    builder: (context, snapshot) {
      final user = (id: userId, isAdmin: snapshot.data == true);
      final l10n = AppLocalizations.of(context)!;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (user.isAdmin)
            _SettingsTile(
              icon: Icons.admin_panel_settings,
              title: l10n.adminDashboardTitle,
              subtitle: l10n.adminDashboardSubtitle,
              onTap: () async {
                final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                final hasAccess =
                    currentUserId == user.id &&
                    await AdminService().isCurrentUserAdmin();
                if (!context.mounted) return;
                if (!hasAccess ||
                    FirebaseAuth.instance.currentUser?.uid != user.id) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.adminAccessDenied)),
                  );
                  return;
                }
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AdminDashboardScreen(),
                  ),
                );
              },
            ),
        ],
      );
    },
  );
}

class _ProfileDisplayNameTile extends StatelessWidget {
  const _ProfileDisplayNameTile();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final displayName = snapshot.data?.displayName?.trim();
        return _SettingsTile(
          icon: Icons.person_outline,
          title: displayName == null || displayName.isEmpty
              ? AppLocalizations.of(context)!.setProfileName
              : displayName,
          subtitle: AppLocalizations.of(context)!.nameDisplayedOnDashboard,
          onTap: () => _editProfileDisplayName(context, displayName ?? ''),
        );
      },
    );
  }
}

Future<void> _editProfileDisplayName(
  BuildContext context,
  String currentName,
) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController(text: currentName);
  final name = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.editProfileName),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: l10n.profileNameLabel),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
          child: Text(l10n.save),
        ),
      ],
    ),
  );
  controller.dispose();
  if (name == null || name.isEmpty) return;

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError(l10n.signInToChangeProfileName);
    }
    await user.updateDisplayName(name);
    await user.reload();
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.profileNameSaved(name))));
    }
  } on Object catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileNameSaveFailed(error.toString()))),
      );
    }
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

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<ThemeController>();
    final modeLabel = switch (controller.themeMode) {
      ThemeMode.system => l10n.system,
      ThemeMode.light => l10n.light,
      ThemeMode.dark => l10n.dark,
    };
    return Card(
      child: ListTile(
        onTap: () => _showThemeModePicker(context, controller),
        leading: Icon(
          Icons.palette_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(l10n.theme, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${l10n.system}, ${l10n.light}, ${l10n.dark}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(modeLabel),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more),
          ],
        ),
      ),
    );
  }
}

class _LocaleTile extends StatelessWidget {
  const _LocaleTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<LocaleController>();
    final selected = controller.locale?.languageCode == 'en' ? 'en' : 'pl';
    final languageLabel = selected == 'en' ? l10n.english : l10n.polish;
    return Card(
      child: ListTile(
        onTap: () => _showLocalePicker(context, controller, selected),
        leading: Icon(
          Icons.language,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          l10n.language,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(languageLabel),
        trailing: const Icon(Icons.expand_more),
      ),
    );
  }
}

Future<void> _showThemeModePicker(
  BuildContext context,
  ThemeController controller,
) async {
  final l10n = AppLocalizations.of(context)!;
  final selected = await showDialog<ThemeMode>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.theme),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeOption(
            title: l10n.system,
            selected: controller.themeMode == ThemeMode.system,
            onTap: () => Navigator.pop(dialogContext, ThemeMode.system),
          ),
          _ModeOption(
            title: l10n.light,
            selected: controller.themeMode == ThemeMode.light,
            onTap: () => Navigator.pop(dialogContext, ThemeMode.light),
          ),
          _ModeOption(
            title: l10n.dark,
            selected: controller.themeMode == ThemeMode.dark,
            onTap: () => Navigator.pop(dialogContext, ThemeMode.dark),
          ),
        ],
      ),
    ),
  );
  if (selected != null) controller.setThemeMode(selected);
}

Future<void> _showLocalePicker(
  BuildContext context,
  LocaleController controller,
  String currentLanguageCode,
) async {
  final l10n = AppLocalizations.of(context)!;
  final selected = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.language),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeOption(
            title: l10n.polish,
            selected: currentLanguageCode == 'pl',
            onTap: () => Navigator.pop(dialogContext, 'pl'),
          ),
          _ModeOption(
            title: l10n.english,
            selected: currentLanguageCode == 'en',
            onTap: () => Navigator.pop(dialogContext, 'en'),
          ),
        ],
      ),
    ),
  );
  if (selected != null) controller.setLocale(Locale(selected));
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(title),
    trailing: selected
        ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
        : null,
    onTap: onTap,
  );
}

String _formatSyncDateTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day.$month.${value.year}, $hour:$minute';
}

class _ProCard extends StatelessWidget {
  const _ProCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isProUser = context.watch<ProAccessService>().isProUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : const Color(0xFFFFF7D6),
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
                    isProUser ? l10n.aquaristProActive : l10n.freePlan,
                    style: TextStyle(
                      color: isDark
                          ? theme.colorScheme.onSurface
                          : const Color(0xFF064E3B),
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isProUser ? l10n.allFeaturesUnlocked : l10n.unlockPremium,
                    style: TextStyle(
                      color: isDark
                          ? theme.colorScheme.onSurfaceVariant
                          : const Color(0xFF365314),
                    ),
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
              onPressed: () =>
                  _showAddToAquariumSheet(context, result, imageBytes),
              icon: const Icon(Icons.playlist_add),
              label: const Text('Dodaj do mojego akwarium / obsady'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showAddToAquariumSheet(
  BuildContext context,
  AiScanResult result,
  Uint8List imageBytes,
) async {
  if (FirebaseAuth.instance.currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Zaloguj się, aby dodać do obsady.')),
    );
    return;
  }

  final aquarium = await showModalBottomSheet<AquariumModel>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _AquariumPickerSheet(),
  );
  if (aquarium == null || !context.mounted) return;

  final count = await _showLivestockQuantityDialog(context, result);
  if (count == null || !context.mounted) return;

  try {
    await FirestoreService().addLivestockItem(
      aquarium.id,
      namePl: result.polishName,
      nameLatin: result.latinName,
      category: result.type,
      count: count,
      phRange: result.ph,
      tempRange: result.temperature,
      minTankVolume: result.minimumVolume,
      photoUrl: 'data:image/jpeg;base64,${base64Encode(imageBytes)}',
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Dodano ${result.polishName} do obsady ${aquarium.name}!',
        ),
        action: SnackBarAction(
          label: 'Zobacz',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AquariumDetailsScreen(aquarium: aquarium),
            ),
          ),
        ),
      ),
    );
  } on FirestoreServiceException catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

Future<int?> _showLivestockQuantityDialog(
  BuildContext context,
  AiScanResult result,
) {
  var count = 1;
  return showDialog<int>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: Text('Dodaj ${result.polishName}'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: count > 1 ? () => setState(() => count--) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$count', style: Theme.of(context).textTheme.titleLarge),
            IconButton(
              onPressed: () => setState(() => count++),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, count),
            child: const Text('Dodaj'),
          ),
        ],
      ),
    ),
  );
}

class _AquariumPickerSheet extends StatefulWidget {
  const _AquariumPickerSheet();

  @override
  State<_AquariumPickerSheet> createState() => _AquariumPickerSheetState();
}

class _AquariumPickerSheetState extends State<_AquariumPickerSheet> {
  late final Future<List<AquariumModel>> _future = FirestoreService()
      .getAquariums()
      .first;
  bool _autoSelected = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<AquariumModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Text('Nie udało się wczytać akwariów: ${snapshot.error}');
            }
            final aquariums = snapshot.data ?? const <AquariumModel>[];
            if (aquariums.isEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Brak akwariów. Dodaj akwarium, aby kontynuować.'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Zamknij'),
                  ),
                ],
              );
            }
            // Skip the list and use the only aquarium automatically.
            if (aquariums.length == 1 && !_autoSelected) {
              _autoSelected = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) Navigator.pop(context, aquariums.first);
              });
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Wybierz akwarium',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...aquariums.map(
                  (aquarium) => ListTile(
                    leading: const Icon(Icons.water_drop_outlined),
                    title: Text(aquarium.name),
                    subtitle: Text(
                      '${aquarium.capacityLiters.toStringAsFixed(0)} l',
                    ),
                    onTap: () => Navigator.pop(context, aquarium),
                  ),
                ),
              ],
            );
          },
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
