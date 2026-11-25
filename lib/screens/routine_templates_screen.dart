import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/aquarium_routine_templates.dart';
import '../l10n/app_localizations.dart';
import '../models/aquarium_model.dart';
import '../models/aquarium_routine.dart';
import '../services/routine_integration_service.dart';
import '../services/routine_progress_service.dart';
import '../utils/app_snackbar.dart';

class RoutineTemplatesScreen extends StatelessWidget {
  const RoutineTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final templates = aquariumRoutineTemplates(l10n);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.templatesTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                l10n.templatesSubtitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ...templates.map(
                (template) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _TemplateCard(template: template),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template});

  final AquariumRoutineTemplate template;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth >= 600;
        final details = _TemplateCardDetails(
          template: template,
          onOpen: () => Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => RoutineTemplateDetailsScreen(template: template),
            ),
          ),
        );
        final illustration = _TemplateIllustration(
          template: template,
          height: horizontal ? 190 : 156,
        );
        return Card(
          clipBehavior: Clip.antiAlias,
          child: horizontal
              ? Row(
                  children: [
                    SizedBox(width: 220, height: 190, child: illustration),
                    Expanded(child: details),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [illustration, details],
                ),
        );
      },
    );
  }
}

class _TemplateIllustration extends StatelessWidget {
  const _TemplateIllustration({required this.template, required this.height});

  final AquariumRoutineTemplate template;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark
            ? colors.surfaceContainerHigh.withValues(alpha: 0.72)
            : colors.surfaceContainerHighest.withValues(alpha: 0.42),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: dark ? 0.28 : 0.18),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ColorFiltered(
          colorFilter: dark
              ? const ColorFilter.matrix(<double>[
                  0.76,
                  0,
                  0,
                  0,
                  8,
                  0,
                  0.82,
                  0,
                  0,
                  12,
                  0,
                  0,
                  0.86,
                  0,
                  14,
                  0,
                  0,
                  0,
                  1,
                  0,
                ])
              : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
          child: Image.asset(template.assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _TemplateCardDetails extends StatelessWidget {
  const _TemplateCardDetails({required this.template, required this.onOpen});

  final AquariumRoutineTemplate template;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(template.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(template.description),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.schedule_outlined, size: 18),
                label: Text(template.duration),
              ),
              Chip(
                avatar: const Icon(Icons.checklist_outlined, size: 18),
                label: Text(l10n.templatesStepsCount(template.steps.length)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.route_outlined),
              label: Text(l10n.templatesOpen),
            ),
          ),
        ],
      ),
    );
  }
}

class RoutineTemplateDetailsScreen extends StatefulWidget {
  const RoutineTemplateDetailsScreen({required this.template, super.key});

  final AquariumRoutineTemplate template;

  @override
  State<RoutineTemplateDetailsScreen> createState() =>
      _RoutineTemplateDetailsScreenState();
}

class _RoutineTemplateDetailsScreenState
    extends State<RoutineTemplateDetailsScreen> {
  final _progressService = RoutineProgressService();
  RoutineIntegrationService? _integrationService;
  Set<String> _completed = const {};
  bool _loading = true;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) {
      _loadProgress();
    }
  }

  String? get _aquariumId {
    final id = context.read<AquariumProvider>().resolveAquariumId();
    return id.trim().isEmpty ? null : id;
  }

  RoutineIntegrationService get _integration =>
      _integrationService ??= RoutineIntegrationService();

  Future<void> _loadProgress() async {
    final aquariumId = _aquariumId;
    if (aquariumId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final completed = await _progressService.load(
      aquariumId,
      widget.template.id,
    );
    if (mounted) {
      setState(() {
        _completed = completed;
        _loading = false;
      });
    }
  }

  Future<void> _toggleStep(AquariumRoutineStep step) async {
    final aquariumId = _aquariumId;
    if (aquariumId == null) return;
    final previous = _completed;
    final completed = {..._completed};
    if (!completed.remove(step.id)) completed.add(step.id);
    setState(() => _completed = completed);
    try {
      await _progressService.save(aquariumId, widget.template.id, completed);
    } on Object {
      if (!mounted) return;
      setState(() => _completed = previous);
      context.showAppSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.routineProgressSaveError),
        ),
      );
    }
  }

  Future<void> _addAll() async {
    final l10n = AppLocalizations.of(context)!;
    final aquariumId = _aquariumId;
    if (aquariumId == null) {
      context.showAppSnackBar(SnackBar(content: Text(l10n.routineNoAquarium)));
      return;
    }
    setState(() => _saving = true);
    try {
      await _integration.addTemplate(
        aquariumId: aquariumId,
        template: widget.template,
      );
      if (!mounted) return;
      context.showAppSnackBar(SnackBar(content: Text(l10n.routineAddedAll)));
    } on Object catch (error) {
      debugPrint('Routine template export failed: $error');
      if (mounted) {
        context.showAppSnackBar(SnackBar(content: Text(l10n.routineAddError)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addStepReminder(AquariumRoutineStep step) async {
    final l10n = AppLocalizations.of(context)!;
    final aquariumId = _aquariumId;
    if (aquariumId == null) {
      context.showAppSnackBar(SnackBar(content: Text(l10n.routineNoAquarium)));
      return;
    }
    try {
      await _integration.addStepReminder(
        aquariumId: aquariumId,
        template: widget.template,
        step: step,
      );
      if (mounted) {
        context.showAppSnackBar(
          SnackBar(content: Text(l10n.routineAddedReminder)),
        );
      }
    } on Object {
      if (mounted) {
        context.showAppSnackBar(SnackBar(content: Text(l10n.routineAddError)));
      }
    }
  }

  Future<void> _addStepJournal(AquariumRoutineStep step) async {
    final l10n = AppLocalizations.of(context)!;
    final aquariumId = _aquariumId;
    if (aquariumId == null) {
      context.showAppSnackBar(SnackBar(content: Text(l10n.routineNoAquarium)));
      return;
    }
    try {
      await _integration.addStepJournalEntry(
        aquariumId: aquariumId,
        template: widget.template,
        step: step,
      );
      if (mounted) {
        context.showAppSnackBar(
          SnackBar(content: Text(l10n.routineAddedJournal)),
        );
      }
    } on Object {
      if (mounted) {
        context.showAppSnackBar(SnackBar(content: Text(l10n.routineAddError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final completedCount = _completed.length;
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(widget.template.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final imageHeight = constraints.maxWidth >= 600
                            ? 184.0
                            : 152.0;
                        return Container(
                          height: imageHeight,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: dark
                                ? colors.surfaceContainerHigh.withValues(
                                    alpha: 0.72,
                                  )
                                : colors.surfaceContainerHighest.withValues(
                                    alpha: 0.42,
                                  ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: colors.outlineVariant.withValues(
                                alpha: dark ? 0.28 : 0.18,
                              ),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: ColorFiltered(
                              colorFilter: dark
                                  ? const ColorFilter.matrix(<double>[
                                      0.76,
                                      0,
                                      0,
                                      0,
                                      8,
                                      0,
                                      0.82,
                                      0,
                                      0,
                                      12,
                                      0,
                                      0,
                                      0.86,
                                      0,
                                      14,
                                      0,
                                      0,
                                      0,
                                      1,
                                      0,
                                    ])
                                  : const ColorFilter.mode(
                                      Colors.transparent,
                                      BlendMode.dst,
                                    ),
                              child: Image.asset(
                                widget.template.assetPath,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.template.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: widget.template.steps.isEmpty
                          ? 0
                          : completedCount / widget.template.steps.length,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.routineProgress(
                        completedCount,
                        widget.template.steps.length,
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _saving ? null : _addAll,
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.playlist_add_check_outlined),
                      label: Text(l10n.routineAddAll),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.routineScheduleTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    ...widget.template.steps.map(
                      (step) => _RoutineStepCard(
                        step: step,
                        completed: _completed.contains(step.id),
                        onToggle: () => _toggleStep(step),
                        onReminder: () => _addStepReminder(step),
                        onJournal: () => _addStepJournal(step),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _RoutineStepCard extends StatelessWidget {
  const _RoutineStepCard({
    required this.step,
    required this.completed,
    required this.onToggle,
    required this.onReminder,
    required this.onJournal,
  });

  final AquariumRoutineStep step;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback onReminder;
  final VoidCallback onJournal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(value: completed, onChanged: (_) => onToggle()),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              decoration: completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        step.dayOffset == 0
                            ? l10n.routineDayToday
                            : l10n.routineDayNumber(step.dayOffset),
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (completed)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(l10n.routineCompleted),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 52),
              child: Text(step.description),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onJournal,
                  icon: const Icon(Icons.menu_book_outlined),
                  label: Text(l10n.routineAddStepJournal),
                ),
                FilledButton.tonalIcon(
                  onPressed: onReminder,
                  icon: const Icon(Icons.notification_add_outlined),
                  label: Text(l10n.routineAddStepReminder),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
