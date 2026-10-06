import 'firebase_options.dart';

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'aquarium_calculators_service.dart';
import 'aquarium_management_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'local_reminder_service.dart';
import 'models/aquarium_model.dart' as models;
import 'models/aquarium_firestore_model.dart' show AquariumModel;
import 'models/water_standards.dart';
import 'utils/water_assessment_localization.dart';
import 'utils/localized_labels.dart';
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
import 'services/experience_mode_controller.dart';
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

import 'package:akwarium/utils/app_snackbar.dart';

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
          child: ChangeNotifierProvider<ExperienceModeController>(
            create: (_) =>
                ExperienceModeController(preferences: proPreferences)..init(),
            child: firebaseReady
                ? ChangeNotifierProvider<ReferralService>(
                    create: (_) => ReferralService()..init(),
                    child: ChangeNotifierProvider<TicketService>(
                      create: (_) => TicketService(),
                      child: ChangeNotifierProvider<models.AquariumProvider>(
                        create: (_) => models.AquariumProvider()..initialize(),
                        child: Builder(
                          builder: (context) =>
                              _buildApp(context, firebaseReady),
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
    final experienceMode = context.watch<ExperienceModeController>();
    final isBeginner = experienceMode.isBeginner;
    final showBeginnerGuide =
        experienceMode.isInitialized &&
        isBeginner &&
        !experienceMode.beginnerGuideCompleted;
    final activeAquarium = provider.selectedAquarium;
    if (activeAquarium == null || activeAquarium.id.trim().isEmpty) {
      return _PageContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                eyebrow: 'AKWARYSTA PRO',
                title: l10n.yourDashboard,
                subtitle: l10n.dashboardSubtitle,
              ),
              const SizedBox(height: 24),
              if (showBeginnerGuide) ...[
                _BeginnerGuideCard(
                  aquariumExists: false,
                  onDimensions: () => showCreateAquariumDialog(context),
                  onWater: () => _showMessage(context, l10n.addAquariumToStart),
                  onLighting: () =>
                      _showMessage(context, l10n.addAquariumToStart),
                  onPlants: () =>
                      _showMessage(context, l10n.addAquariumToStart),
                ),
                const SizedBox(height: 16),
              ],
              Text(l10n.dashboardNoAquarium, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => showCreateAquariumDialog(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.addNewAquarium),
              ),
            ],
          ),
        ),
      );
    }
    final isArchived = activeAquarium.isArchived;
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
            if (isArchived) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.history),
                      const SizedBox(width: 10),
                      Expanded(child: Text(l10n.archivedHistoryNotice)),
                    ],
                  ),
                ),
              ),
            ],
            if (showBeginnerGuide && !isArchived) ...[
              const SizedBox(height: 16),
              _BeginnerGuideCard(
                aquariumExists: true,
                onDimensions: () => showDialog<void>(
                  context: context,
                  builder: (_) => AddAquariumModal(initial: activeAquarium),
                ),
                onWater: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const WaterTestScreen(),
                  ),
                ),
                onLighting: () => showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    scrollable: true,
                    title: Text(l10n.beginnerStepLighting),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.beginnerStepLightingDescription),
                        const SizedBox(height: 12),
                        Text(l10n.plantLightingPowerNote),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(l10n.closeAction),
                      ),
                    ],
                  ),
                ),
                onPlants: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => SpeciesAtlasScreen(
                      tankId: activeAquarium.id,
                      onCreateAquarium: () => showCreateAquariumDialog(context),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (context.watch<ProAccessService>().isProUser && !isArchived) ...[
              const FirestoreRemindersWidget(compact: true),
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
                        : l10n.parametersCount(
                            latestTest.measuredParametersCount,
                          ),
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
            if (provider.waterChangesSyncFailed) ...[
              Text(
                l10n.waterChangesSyncFailed,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 8),
            ],
            if (isBeginner)
              _BeginnerWaterSummary(
                test: latestTest,
                syncFailed: provider.waterTestsSyncFailed,
              )
            else ...[
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
              if (provider.waterTestsSyncFailed) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.waterTestsSyncFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              const WaterParametersChart(),
            ],
            if (!isArchived) ...[
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
          ],
        ),
      ),
    );
  }

  Future<void> _showWaterChangeDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<models.AquariumProvider>();
    final aquarium = provider.selectedAquarium;
    if (aquarium == null || aquarium.isArchived) {
      context.showAppSnackBar(SnackBar(content: Text(l10n.addAquariumToStart)));
      return;
    }
    final defaultLiters = suggestedWaterChangeLiters(aquarium.volumeNetLiters);
    final amountController = TextEditingController(
      text: defaultLiters.toStringAsFixed(1),
    );
    final notesController = TextEditingController();
    var asPercent = false;

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final enteredAmount = double.tryParse(
              amountController.text.trim().replaceAll(',', '.'),
            );
            final convertedLiters =
                enteredAmount == null ||
                    !enteredAmount.isFinite ||
                    enteredAmount <= 0 ||
                    (asPercent && enteredAmount > 100) ||
                    (!asPercent && enteredAmount > aquarium.volumeNetLiters)
                ? null
                : waterChangeVolumeLiters(
                    amount: enteredAmount,
                    netVolumeLiters: aquarium.volumeNetLiters,
                    isPercent: asPercent,
                  );
            return AlertDialog(
              title: Text(l10n.addWaterChange),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: false,
                        label: Text(l10n.waterChangeLiters),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text(l10n.waterChangePercent),
                      ),
                    ],
                    selected: {asPercent},
                    onSelectionChanged: (selection) =>
                        setDialogState(() => asPercent = selection.single),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: l10n.volume,
                      suffixText: asPercent ? '%' : l10n.liters,
                    ),
                  ),
                  if (asPercent && convertedLiters != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.waterChangeEquivalent(
                            convertedLiters.toStringAsFixed(1),
                          ),
                        ),
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
                    final amount = double.tryParse(
                      amountController.text.trim().replaceAll(',', '.'),
                    );
                    if (amount == null ||
                        !amount.isFinite ||
                        amount <= 0 ||
                        (asPercent && amount > 100) ||
                        (!asPercent && amount > aquarium.volumeNetLiters)) {
                      context.showAppSnackBar(
                        SnackBar(content: Text(l10n.invalidWaterChangeAmount)),
                      );
                      return;
                    }

                    provider.addWaterChange(
                      models.WaterChange(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        aquariumId: aquarium.id,
                        date: DateTime.now(),
                        volumeLiters: waterChangeVolumeLiters(
                          amount: amount,
                          netVolumeLiters: aquarium.volumeNetLiters,
                          isPercent: asPercent,
                        ),
                        notes: notesController.text.trim(),
                      ),
                    );
                    Navigator.pop(dialogContext);
                    context.showAppSnackBar(
                      SnackBar(content: Text(l10n.saveTankParameters)),
                    );
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        ),
      );
    } finally {
      amountController.dispose();
      notesController.dispose();
    }
  }

  void _showMessage(BuildContext context, String message) {
    context.showAppSnackBar(SnackBar(content: Text(message)));
  }
}

class _BeginnerGuideCard extends StatefulWidget {
  const _BeginnerGuideCard({
    required this.aquariumExists,
    required this.onDimensions,
    required this.onWater,
    required this.onLighting,
    required this.onPlants,
  });

  final bool aquariumExists;
  final VoidCallback onDimensions;
  final VoidCallback onWater;
  final VoidCallback onLighting;
  final VoidCallback onPlants;

  @override
  State<_BeginnerGuideCard> createState() => _BeginnerGuideCardState();
}

class _BeginnerGuideCardState extends State<_BeginnerGuideCard> {
  int _stepIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = [
      (
        l10n.beginnerStepDimensions,
        l10n.beginnerStepDimensionsDescription,
        widget.aquariumExists
            ? l10n.beginnerDimensionsAction
            : l10n.addNewAquarium,
        Icons.straighten,
        widget.onDimensions,
      ),
      (
        l10n.beginnerStepWater,
        l10n.beginnerStepWaterDescription,
        l10n.enterWaterTest,
        Icons.water_drop_outlined,
        widget.onWater,
      ),
      (
        l10n.beginnerStepLighting,
        l10n.beginnerStepLightingDescription,
        l10n.beginnerLightingAction,
        Icons.light_mode_outlined,
        widget.onLighting,
      ),
      (
        l10n.beginnerStepPlants,
        l10n.beginnerStepPlantsDescription,
        l10n.speciesAtlasTitle,
        Icons.eco_outlined,
        widget.onPlants,
      ),
    ];
    final step = steps[_stepIndex];
    final isLastStep = _stepIndex == steps.length - 1;
    final canAdvance = widget.aquariumExists && !isLastStep;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.beginnerGuideTitle,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.beginnerGuideIntro),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_stepIndex + 1) / steps.length,
                  ),
                ),
                const SizedBox(width: 12),
                Text('${_stepIndex + 1} / ${steps.length}'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              step.$1,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(step.$2),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: !widget.aquariumExists && _stepIndex > 0
                    ? null
                    : () async {
                        if (isLastStep) await _completeGuide();
                        step.$5();
                      },
                icon: Icon(step.$4),
                label: Text(step.$3),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _stepIndex == 0
                      ? null
                      : () => setState(() => _stepIndex--),
                  icon: const Icon(Icons.chevron_left),
                  label: Text(l10n.beginnerPreviousStep),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: canAdvance
                      ? () => setState(() => _stepIndex++)
                      : isLastStep && widget.aquariumExists
                      ? _completeGuide
                      : null,
                  icon: Icon(isLastStep ? Icons.check : Icons.chevron_right),
                  label: Text(
                    isLastStep
                        ? l10n.beginnerFinishGuide
                        : l10n.beginnerNextStep,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeGuide() async {
    try {
      await context.read<ExperienceModeController>().completeBeginnerGuide();
    } on Object catch (error, stackTrace) {
      debugPrint('Beginner guide completion could not be saved: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        context.showAppSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.beginnerGuideSaveFailed,
            ),
          ),
        );
      }
    }
  }
}

class _BeginnerWaterSummary extends StatelessWidget {
  const _BeginnerWaterSummary({required this.test, required this.syncFailed});

  final models.WaterTest? test;
  final bool syncFailed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final alert = latestWaterAlert(test);
    final message = test == null
        ? l10n.beginnerWaterStatusNoData
        : alert == null
        ? l10n.beginnerWaterStatusGood
        : l10n.beginnerWaterStatusNeedsAttention;
    final color = alert == null
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.tertiary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              alert == null ? Icons.water_drop_outlined : Icons.info_outline,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.aquariumStatus,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(message),
                  if (test?.co2 case final value?) ...[
                    const SizedBox(height: 8),
                    Text('${l10n.co2Label}: ${value.toStringAsFixed(1)} mg/L'),
                  ],
                  if (syncFailed) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.waterTestsSyncFailed,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        .map((entry) => _toJournalItem(entry, l10n))
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
                context.showAppSnackBar(
                  SnackBar(content: Text(l10n.showOlderEntries)),
                );
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

  _JournalItem _toJournalItem(
    models.JournalEntry entry,
    AppLocalizations l10n,
  ) {
    final isWaterChange = entry.type == 'waterChange';
    return _JournalItem(
      icon: isWaterChange ? Icons.water_drop_outlined : Icons.science_outlined,
      color: isWaterChange ? Colors.blue : Colors.teal,
      title: entry.type == 'waterTest' ? l10n.waterTestTitle : entry.title,
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
    final isBeginner = context.watch<ExperienceModeController>().isBeginner;
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
                          .resolveAquariumId(),
                      onCreateAquarium: () => showCreateAquariumDialog(context),
                    ),
                  ),
                );
              },
            ),
            if (!isBeginner) ...[
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
            ],
            const SizedBox(height: 12),
            _ToolCard(
              icon: Icons.auto_awesome,
              color: Colors.deepPurple,
              title: l10n.aiScannerTitle,
              description: l10n.aiScannerDesc,
              buttonLabel: l10n.startDiagnosis,
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
  final _co2 = TextEditingController();
  final _lightHours = TextEditingController(text: '8');
  final _picker = ImagePicker();
  final _editedWaterFields = <String>{};
  String _selectedAlgae = _algaeValues.first;
  String _substrate = 'gravel';
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
    final aquariumId = provider.resolveAquariumId();
    final latest = provider.waterTests.firstOrNull;
    _no3.text = _formatMeasurement(latest?.no3);
    _po4.text = _formatMeasurement(latest?.po4);
    _fe.text = _formatMeasurement(latest?.fe);
    _ph.text = _formatMeasurement(latest?.ph);
    _kh.text = _formatMeasurement(latest?.kh);
    _co2.text = _formatMeasurement(latest?.co2);
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
        if (!_editedWaterFields.contains('CO2')) {
          _co2.text = _formatMeasurement(latest.co2);
        }
      });
    } on Object catch (error) {
      debugPrint('Nie udało się pobrać ostatnich parametrów wody: $error');
    }
  }

  @override
  void dispose() {
    for (final controller in [_no3, _po4, _fe, _ph, _kh, _co2, _lightHours]) {
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
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          32 + MediaQuery.viewInsetsOf(context).bottom,
        ),
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
                    : l10n.changeAlgaePhoto,
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
                    items: const ['gravel', 'activeSoil', 'mineral', 'other']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(switch (value) {
                              'activeSoil' => l10n.substrateActiveSoil,
                              'mineral' => l10n.substrateMineral,
                              'other' => l10n.substrateOther,
                              _ => l10n.gravelSand,
                            }),
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
                _loading ? l10n.analyzingConditions : l10n.diagnoseProblem,
              ),
            ),
            if (_loading)
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(width: 14),
                        Expanded(child: Text(l10n.analyzingAlgaeAndParameters)),
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
        _numberField(_co2, AppLocalizations.of(context)!.co2Label, 'mg/L'),
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
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.cameraAction),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.galleryAction),
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
      co2MgPerLiter: _optionalNumber(_co2),
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
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<models.AquariumProvider>();
    final aquariumId = provider.resolveAquariumId();
    if (aquariumId.isEmpty) {
      context.showAppSnackBar(SnackBar(content: Text(l10n.addAquariumToStart)));
      return;
    }

    provider.addJournalEntry(
      models.JournalEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        aquariumId: aquariumId,
        date: DateTime.now(),
        title: l10n.algaeDiagnosisTitle(result.algaeName),
        description:
            '${result.cause}\n\n${l10n.actionPlanTitle}:\n${result.actions.asMap().entries.map((entry) => '${entry.key + 1}. ${entry.value}').join('\n')}',
        type: 'algaeDiagnosis',
        category: models.JournalCategory.algae,
        tags: [l10n.knowledgeCategoryAlgae, l10n.smartDiagnosis],
        attachedWaterParameters: {
          'NO3': _number(_no3),
          'PO4': _number(_po4),
          'Fe': _number(_fe),
          'pH': _number(_ph),
          'KH': _number(_kh),
          ...?_co2WaterParameter(),
        },
        imagePaths: _imageBytes == null
            ? const []
            : ['data:${_imageMimeType ?? 'image/jpeg'};base64,${base64Encode(_imageBytes!)}'],
      ),
    );
    context.showAppSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.diagnosisSaved)),
    );
  }

  double _number(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.')) ?? 0;

  double? _optionalNumber(TextEditingController controller) {
    final text = controller.text.trim().replaceAll(',', '.');
    return text.isEmpty ? null : double.tryParse(text);
  }

  Map<String, double>? _co2WaterParameter() {
    final value = _optionalNumber(_co2);
    return value == null ? null : {'CO2': value};
  }

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
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.isMock)
              Chip(
                avatar: const Icon(Icons.science_outlined, size: 18),
                label: Text(l10n.mockAiUnavailable),
              ),
            Text(
              l10n.algaeDiagnosisTitle(result.algaeName),
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(result.cause),
            const SizedBox(height: 18),
            Text(
              l10n.actionPlanTitle,
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

enum _AiScannerState { locked, idle, selectingImage, loading, success, error }

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
  AiDiagnosisResult? _result;
  AiDiagnosisException? _failure;
  _AiScannerState _state = _AiScannerState.idle;

  bool get _isBusy =>
      _state == _AiScannerState.selectingImage ||
      _state == _AiScannerState.loading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPro = context.watch<ProAccessService>().isProUser;
    final state = isPro ? _state : _AiScannerState.locked;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiScannerTitle)),
      body: _PageContainer(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: state == _AiScannerState.locked
              ? _buildLocked(context, l10n)
              : _buildScanner(context, l10n, state),
        ),
      ),
    );
  }

  Widget _buildLocked(BuildContext context, AppLocalizations l10n) {
    return Center(
      key: const ValueKey('locked'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48),
                const SizedBox(height: 16),
                Text(
                  l10n.scannerLockedTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.scannerLockedDescription,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _openPaywall,
                  icon: const Icon(Icons.workspace_premium_outlined),
                  label: Text(l10n.scannerUnlockPro),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanner(
    BuildContext context,
    AppLocalizations l10n,
    _AiScannerState state,
  ) {
    final theme = Theme.of(context);
    final isLoading = state == _AiScannerState.loading;
    final isSelecting = state == _AiScannerState.selectingImage;
    return SingleChildScrollView(
      key: const ValueKey('scanner'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _PremiumBanner(),
              const SizedBox(height: 12),
              Text(l10n.scannerIntro),
              const SizedBox(height: 16),
              Card(
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 280,
                  child: _imageBytes == null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 52,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.scannerNoPhotoSelected,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Image.memory(
                          _imageBytes!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) =>
                              Center(child: Text(l10n.scannerInvalidImage)),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isBusy
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(l10n.scannerTakePhoto),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isBusy
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.scannerChoosePhoto),
                  ),
                ],
              ),
              if (_imageBytes != null) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _isBusy ? null : _analyze,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(l10n.scannerAnalyzeAction),
                ),
              ],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: isSelecting || isLoading
                    ? _ScannerLoadingCard(
                        key: ValueKey(state),
                        title: isSelecting
                            ? l10n.scannerSelectingPhoto
                            : l10n.scannerLoadingTitle,
                        description: l10n.scannerLoadingDescription,
                      )
                    : state == _AiScannerState.error && _failure != null
                    ? _ScannerErrorCard(
                        key: const ValueKey('error'),
                        message: _failureMessage(l10n, _failure!),
                        retryLabel: l10n.scannerTryAgain,
                        onRetry: _imageBytes == null
                            ? () => _pickImage(ImageSource.gallery)
                            : _analyze,
                      )
                    : state == _AiScannerState.success && _result != null
                    ? _DiagnosisResultCard(
                        key: const ValueKey('result'),
                        result: _result!,
                      )
                    : const SizedBox.shrink(key: ValueKey('idle')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _ensurePro() async {
    if (context.read<ProAccessService>().isProUser) return true;
    if (!mounted) return false;

    setState(() => _state = _AiScannerState.locked);
    try {
      await ProPaywallDialog.show(
        context,
        headline: AppLocalizations.of(context)!.scannerLockedTitle,
      );
    } on Object catch (error, stackTrace) {
      debugPrint('AI scanner paywall failed to open: $error\n$stackTrace');
      if (mounted) {
        context.showAppSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.scannerUnexpectedFailure,
            ),
          ),
        );
      }
      return false;
    }
    if (!mounted) return false;
    final isPro = context.read<ProAccessService>().isProUser;
    setState(
      () => _state = isPro ? _AiScannerState.idle : _AiScannerState.locked,
    );
    return isPro;
  }

  Future<void> _openPaywall() async {
    await _ensurePro();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!await _ensurePro() || !mounted) return;
    final previousState = _result == null
        ? _AiScannerState.idle
        : _AiScannerState.success;
    setState(() {
      _state = _AiScannerState.selectingImage;
      _failure = null;
    });
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 1800,
      );
      if (!mounted) return;
      if (file == null) {
        setState(() => _state = previousState);
        return;
      }
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (bytes.isEmpty) {
        setState(() {
          _failure = const AiDiagnosisException(
            AiDiagnosisFailure.invalidImage,
          );
          _state = _AiScannerState.error;
        });
        return;
      }
      setState(() {
        _imageBytes = bytes;
        _mimeType = _mimeFor(file.name);
        _result = null;
        _failure = null;
        _state = _AiScannerState.idle;
      });
    } on PlatformException catch (error, stackTrace) {
      debugPrint('AI scanner image picker failed: $error\n$stackTrace');
      if (!mounted) return;
      final failure =
          source == ImageSource.camera &&
              (error.code.toLowerCase().contains('denied') ||
                  error.code.toLowerCase().contains('permission'))
          ? AiDiagnosisFailure.cameraPermissionDenied
          : source == ImageSource.camera &&
                (error.code.toLowerCase().contains('camera') ||
                    error.code.toLowerCase().contains('available'))
          ? AiDiagnosisFailure.cameraUnavailable
          : AiDiagnosisFailure.imagePicker;
      setState(() {
        _failure = AiDiagnosisException(failure);
        _state = _AiScannerState.error;
      });
    } on Object catch (error, stackTrace) {
      debugPrint('AI scanner image read failed: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _failure = const AiDiagnosisException(AiDiagnosisFailure.imagePicker);
        _state = _AiScannerState.error;
      });
    }
  }

  Future<void> _analyze() async {
    if (!await _ensurePro() || !mounted) return;
    final image = _imageBytes;
    if (image == null || image.isEmpty) {
      setState(() {
        _failure = const AiDiagnosisException(AiDiagnosisFailure.invalidImage);
        _state = _AiScannerState.error;
      });
      return;
    }

    setState(() {
      _state = _AiScannerState.loading;
      _failure = null;
      _result = null;
    });
    try {
      final diagnosis = await _service.diagnose(
        imageBytes: image,
        mimeType: _mimeType ?? 'image/jpeg',
        languageCode: Localizations.localeOf(context).languageCode,
      );
      if (!mounted) return;
      setState(() {
        _result = diagnosis;
        _state = _AiScannerState.success;
      });
    } on AiDiagnosisException catch (error) {
      if (!mounted) return;
      setState(() {
        _failure = error;
        _state = _AiScannerState.error;
      });
    } on Object catch (error, stackTrace) {
      debugPrint('AI diagnosis failed unexpectedly: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _failure = const AiDiagnosisException(AiDiagnosisFailure.unavailable);
        _state = _AiScannerState.error;
      });
    }
  }

  String _failureMessage(AppLocalizations l10n, AiDiagnosisException failure) =>
      _localizedAiScannerFailure(l10n, failure.failure);

  String _mimeFor(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
  }
}

String _localizedAiScannerFailure(
  AppLocalizations l10n,
  AiDiagnosisFailure failure,
) => switch (failure) {
  AiDiagnosisFailure.missingApiKey => l10n.scannerApiKeyMissing,
  AiDiagnosisFailure.invalidApiKey => l10n.scannerApiKeyInvalid,
  AiDiagnosisFailure.network => l10n.scannerNetworkFailure,
  AiDiagnosisFailure.timeout => l10n.scannerAnalysisTimeout,
  AiDiagnosisFailure.overloaded => l10n.scannerServiceBusy,
  AiDiagnosisFailure.invalidResponse => l10n.scannerInvalidResponse,
  AiDiagnosisFailure.requestFailed => l10n.scannerRequestFailure,
  AiDiagnosisFailure.invalidImage => l10n.scannerInvalidImage,
  AiDiagnosisFailure.cameraPermissionDenied =>
    l10n.scannerCameraPermissionDenied,
  AiDiagnosisFailure.cameraUnavailable => l10n.scannerCameraUnavailable,
  AiDiagnosisFailure.imagePicker => l10n.scannerPhotoPickerFailure,
  AiDiagnosisFailure.unavailable => l10n.scannerUnexpectedFailure,
};

class _ScannerLoadingCard extends StatelessWidget {
  const _ScannerLoadingCard({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ScannerErrorCard extends StatelessWidget {
  const _ScannerErrorCard({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    super.key,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.scannerErrorTitle,
              style: TextStyle(
                color: colors.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(message, style: TextStyle(color: colors.onErrorContainer)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagnosisResultCard extends StatelessWidget {
  const _DiagnosisResultCard({required this.result, super.key});

  final AiDiagnosisResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final category = switch (result.category) {
      AiDiagnosisCategory.fishDisease => l10n.scannerCategoryFishDisease,
      AiDiagnosisCategory.plantIssue => l10n.scannerCategoryPlantIssue,
      AiDiagnosisCategory.algae => l10n.scannerCategoryAlgae,
      AiDiagnosisCategory.other => l10n.scannerCategoryOther,
    };
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.health_and_safety_outlined),
                  label: Text(category),
                ),
                Text(
                  l10n.scannerConfidence(result.confidence),
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              result.problemName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: result.confidence / 100,
              minHeight: 7,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 16),
            Text(result.summary),
            const SizedBox(height: 18),
            Text(
              l10n.actionPlanTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...result.actions.indexed.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 12, child: Text('${entry.$1 + 1}')),
                    const SizedBox(width: 10),
                    Expanded(child: Text(entry.$2)),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),
            Text(
              l10n.scannerCareNotice,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
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
    final theme = Theme.of(context);
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileTitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.profileSubtitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _SignedInAccountCard(),
            const _ProCard(),
            const SizedBox(height: 16),
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
            const _ExperienceModeTile(),
            const SizedBox(height: 10),
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
    context.showAppSnackBar(SnackBar(content: Text(message)));
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
                      } on AiDiagnosisException catch (error) {
                        if (!dialogContext.mounted) return;
                        setDialogState(() {
                          keyTestSucceeded = false;
                          keyTestMessage = _localizedAiScannerFailure(
                            AppLocalizations.of(dialogContext)!,
                            error.failure,
                          );
                        });
                      } on Object catch (error, stackTrace) {
                        debugPrint(
                          'Gemini API key verification failed: '
                          '$error\n$stackTrace',
                        );
                        if (!dialogContext.mounted) return;
                        setDialogState(() {
                          keyTestSucceeded = false;
                          keyTestMessage = AppLocalizations.of(dialogContext)!
                              .scannerUnexpectedFailure;
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
          const SizedBox(height: 20),
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
                  '${l10n.litersCount(aquarium.volumeNetLiters.round())} · ${tankTypeLabel(l10n, aquarium.type)}',
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
                  if (test!.ph case final value?)
                    _ParameterChip(label: 'pH', value: '$value'),
                  if (test!.no3 case final value?)
                    _ParameterChip(label: 'NO3', value: '$value mg/l'),
                  if (test!.no2 case final value?)
                    _ParameterChip(label: 'NO2', value: '$value mg/l'),
                  if (test!.po4 case final value?)
                    _ParameterChip(label: 'PO4', value: '$value mg/l'),
                  if (test!.co2 case final value?)
                    _ParameterChip(label: l10n.co2Label, value: '$value mg/L'),
                  if (test!.nh3Nh4 case final value?)
                    _ParameterChip(
                      label: l10n.ammoniaParameterLabel,
                      value: '$value mg/L',
                    ),
                  if (test!.tds case final value?)
                    _ParameterChip(label: 'TDS', value: '$value ppm'),
                  if (test!.fe case final value?)
                    _ParameterChip(label: 'Fe', value: '$value mg/l'),
                  if (test!.kh case final value?)
                    _ParameterChip(label: 'KH', value: '$value dKH'),
                  if (test!.gh case final value?)
                    _ParameterChip(label: 'GH', value: '$value dGH'),
                  if (test!.temp case final value?)
                    _ParameterChip(label: l10n.temperature, value: '$value°C'),
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
    final l10n = AppLocalizations.of(context)!;
    final isCritical = alert.status == WaterStatus.critical;
    final color = isCritical ? Colors.red.shade700 : Colors.orange.shade800;
    final parameter = alert.parameter;
    final value = parameter == null ? null : waterValue(test, parameter);
    final valuePrecision = switch (parameter) {
      WaterParameter.nh3Nh4 => 3,
      WaterParameter.no2 => 2,
      WaterParameter.tds => 0,
      _ => 1,
    };
    final unit = parameter == null ? '' : waterStandards[parameter]!.unit;
    final valueDescription = value == null
        ? ''
        : ' (${value.toStringAsFixed(valuePrecision)}${unit.isEmpty ? '' : ' $unit'})';

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
              '${waterAssessmentLabel(l10n, alert)}: '
              '${waterAssessmentMessage(l10n, alert)}$valueDescription',
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
                  context.showAppSnackBar(
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

class _SignedInAccountCard extends StatelessWidget {
  const _SignedInAccountCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) return const SizedBox.shrink();
        final displayName = user.displayName?.trim();
        final email = user.email?.trim();
        return Card(
          child: ListTile(
            leading: SizedBox(
              width: 48,
              height: 48,
              child: ClipOval(
                child: user.photoURL == null || user.photoURL!.isEmpty
                    ? CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          (displayName?.isNotEmpty ?? false)
                              ? displayName![0].toUpperCase()
                              : (email?.isNotEmpty ?? false)
                              ? email![0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Image.network(
                        user.photoURL!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          child: const Icon(Icons.person_outline),
                        ),
                      ),
              ),
            ),
            title: Text(
              (displayName?.isNotEmpty ?? false)
                  ? displayName!
                  : email ?? l10n.signedInAccount,
            ),
            subtitle: Text(email ?? l10n.signedInAccount),
          ),
        );
      },
    );
  }
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
      context.showAppSnackBar(
        SnackBar(content: Text(l10n.profileNameSaved(name))),
      );
    }
  } on Object catch (error) {
    if (context.mounted) {
      context.showAppSnackBar(
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

class _ExperienceModeTile extends StatelessWidget {
  const _ExperienceModeTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mode = context.watch<ExperienceModeController>().mode;
    final isBeginner = mode == ExperienceMode.beginner;
    return Card(
      child: ListTile(
        onTap: () => _showExperienceModePicker(
          context,
          context.read<ExperienceModeController>(),
        ),
        leading: Icon(
          Icons.school_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          l10n.experienceMode,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${isBeginner ? l10n.beginnerMode : l10n.advancedMode} · '
          '${isBeginner ? l10n.beginnerModeDescription : l10n.advancedModeDescription}',
        ),
        trailing: const Icon(Icons.expand_more),
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

Future<void> _showExperienceModePicker(
  BuildContext context,
  ExperienceModeController controller,
) async {
  final l10n = AppLocalizations.of(context)!;
  final selected = await showDialog<ExperienceMode>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.experienceMode),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ExperienceModeOption(
            title: l10n.beginnerMode,
            subtitle: l10n.beginnerModeDescription,
            selected: controller.mode == ExperienceMode.beginner,
            onTap: () => Navigator.pop(dialogContext, ExperienceMode.beginner),
          ),
          _ExperienceModeOption(
            title: l10n.advancedMode,
            subtitle: l10n.advancedModeDescription,
            selected: controller.mode == ExperienceMode.advanced,
            onTap: () => Navigator.pop(dialogContext, ExperienceMode.advanced),
          ),
        ],
      ),
    ),
  );
  if (selected == null) return;
  try {
    await controller.setMode(selected);
  } on Object catch (error, stackTrace) {
    debugPrint('Experience mode could not be saved: $error\n$stackTrace');
    if (context.mounted) {
      context.showAppSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class _ExperienceModeOption extends StatelessWidget {
  const _ExperienceModeOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: selected
        ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
        : const Icon(Icons.circle_outlined),
    onTap: onTap,
  );
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

class AiSpeciesIdentificationCard extends StatelessWidget {
  const AiSpeciesIdentificationCard({
    required this.result,
    required this.imageBytes,
    super.key,
  });

  final AiScanResult result;
  final Uint8List imageBytes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                child: Row(
                  children: [
                    const Icon(
                      Icons.science_outlined,
                      size: 18,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l10n.mockAiUnavailable)),
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
                        l10n.recognizedSpecies(result.polishName),
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
                Chip(
                  label: Text(
                    l10n.speciesMinimumVolumeFrom(result.minimumVolume),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(result.description),
            const SizedBox(height: 10),
            Text(
              l10n.livestockCompatibilityTitle,
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
              label: Text(l10n.addSpeciesToStock),
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
  final l10n = AppLocalizations.of(context)!;
  if (FirebaseAuth.instance.currentUser == null) {
    context.showAppSnackBar(SnackBar(content: Text(l10n.loginToAddSpecies)));
    return;
  }

  final aquarium = await showModalBottomSheet<AquariumModel>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _AquariumPickerSheet(),
  );
  if (aquarium == null || !context.mounted) return;

  context.read<models.AquariumProvider>().selectAquarium(aquarium.id);

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
      careNotes: result.description,
      photoUrl: 'data:image/jpeg;base64,${base64Encode(imageBytes)}',
    );
    if (!context.mounted) return;
    context.showAppSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: Text(
          l10n.addedSpeciesToAquarium(result.polishName, aquarium.name),
        ),
        action: SnackBarAction(
          label: l10n.viewLivestock,
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
      context.showAppSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

Future<int?> _showLivestockQuantityDialog(
  BuildContext context,
  AiScanResult result,
) {
  final l10n = AppLocalizations.of(context)!;
  var count = 1;
  return showDialog<int>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: Text(l10n.addSpeciesDialogTitle(result.polishName)),
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
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, count),
            child: Text(l10n.add),
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
    final l10n = AppLocalizations.of(context)!;
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
              return Text(l10n.aquariumPickerLoadError('${snapshot.error}'));
            }
            final aquariums = snapshot.data ?? const <AquariumModel>[];
            if (aquariums.isEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.noAquariumYet),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.closeAction),
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
                  l10n.chooseAquarium,
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
