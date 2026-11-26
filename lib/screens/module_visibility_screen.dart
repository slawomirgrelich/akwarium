import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/module_visibility_controller.dart';

class ModuleVisibilityScreen extends StatelessWidget {
  const ModuleVisibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<ModuleVisibilityController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.moduleVisibilityTitle),
        actions: [
          TextButton(
            onPressed: controller.showAll,
            child: Text(l10n.moduleVisibilityShowAll),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                child: Text(l10n.moduleVisibilityDescription),
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < ModuleVisibilityController.optionalModules.length;
                      index++
                    ) ...[
                      if (index > 0) const Divider(height: 1),
                      _ModuleSwitchTile(
                        module:
                            ModuleVisibilityController.optionalModules[index],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleSwitchTile extends StatelessWidget {
  const _ModuleSwitchTile({required this.module});

  final AppModule module;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<ModuleVisibilityController>();
    return SwitchListTile(
      value: controller.isVisible(module),
      onChanged: (value) => controller.setVisible(module, value),
      secondary: Icon(_moduleIcon(module)),
      title: Text(_moduleLabel(l10n, module)),
    );
  }
}

IconData _moduleIcon(AppModule module) => switch (module) {
  AppModule.waterTests => Icons.science_outlined,
  AppModule.partners => Icons.handshake_outlined,
  AppModule.community => Icons.forum_outlined,
  AppModule.templates => Icons.auto_stories_outlined,
  AppModule.calculators => Icons.calculate_outlined,
  AppModule.speciesAtlas => Icons.menu_book_outlined,
  AppModule.aiScanner => Icons.auto_awesome,
  AppModule.algaeAssistant => Icons.eco_outlined,
};

String _moduleLabel(AppLocalizations l10n, AppModule module) =>
    switch (module) {
      AppModule.waterTests => l10n.waterTests,
      AppModule.partners => l10n.partnersTitle,
      AppModule.community => l10n.communityTitle,
      AppModule.templates => l10n.templatesTitle,
      AppModule.calculators => l10n.fertilizerCalcTitle,
      AppModule.speciesAtlas => l10n.knowledgeBaseTitle,
      AppModule.aiScanner => l10n.aiScannerTitle,
      AppModule.algaeAssistant => l10n.algaeAssistantTitle,
    };
