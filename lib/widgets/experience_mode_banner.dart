import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/experience_mode_controller.dart';

class ExperienceModeBanner extends StatelessWidget {
  const ExperienceModeBanner({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ExperienceModeController>();
    if (!controller.isBeginner) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.school_outlined, color: colors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.beginnerModeActiveTitle,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(l10n.beginnerModeActiveDescription),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _switchMode(context, controller),
              icon: const Icon(Icons.bolt_outlined),
              label: Text(l10n.switchToAdvancedMode),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _switchMode(
    BuildContext context,
    ExperienceModeController controller,
  ) async {
    try {
      await controller.setMode(ExperienceMode.advanced);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.experienceModeChanged),
          ),
        );
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.experienceModeSaveFailed,
            ),
          ),
        );
      }
    }
  }
}

class ExperienceModeOnboardingCard extends StatelessWidget {
  const ExperienceModeOnboardingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ExperienceModeController>();
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.modeOnboardingTitle,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(l10n.modeOnboardingDescription),
            const SizedBox(height: 12),
            _OnboardingOption(
              icon: Icons.school_outlined,
              title: l10n.beginnerMode,
              description: l10n.beginnerModeDescription,
              selected: controller.isBeginner,
              onTap: () => controller.setMode(ExperienceMode.beginner),
            ),
            const SizedBox(height: 8),
            _OnboardingOption(
              icon: Icons.tune_outlined,
              title: l10n.advancedMode,
              description: l10n.advancedModeDescription,
              selected: !controller.isBeginner,
              onTap: () => controller.setMode(ExperienceMode.advanced),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                try {
                  await controller.completeModeOnboarding();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.experienceModeChanged)),
                    );
                  }
                } on Object {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.experienceModeSaveFailed)),
                    );
                  }
                }
              },
              icon: const Icon(Icons.arrow_forward),
              label: Text(l10n.modeOnboardingContinue),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.modeChangeAnytimeHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingOption extends StatelessWidget {
  const _OnboardingOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(description),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
