import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/aquarium_model.dart';
import '../screens/aquarium_details_screen.dart';
import '../services/firestore_service.dart';
import '../utils/localized_labels.dart';

class FirestoreAquariumsSection extends StatefulWidget {
  const FirestoreAquariumsSection({super.key});

  @override
  State<FirestoreAquariumsSection> createState() =>
      _FirestoreAquariumsSectionState();
}

class _FirestoreAquariumsSectionState extends State<FirestoreAquariumsSection> {
  late final FirestoreService _service;
  late final Stream<List<AquariumModel>> _aquariumsStream;

  @override
  void initState() {
    super.initState();
    _service = FirestoreService();
    _aquariumsStream = _service.getAquariums();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AquariumModel>>(
      stream: _aquariumsStream,
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context)!;
        final aquariums = snapshot.data ?? const <AquariumModel>[];
        if (aquariums.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.read<AquariumProvider>().syncCloudAquariums(aquariums);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _SectionTitle(
                    title: l10n.aquariumsSectionTitle,
                    subtitle: l10n.cloudSyncSubtitle,
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: l10n.addAquariumTooltip,
                  onPressed: () => _openAquariumForm(context),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData)
              const _LoadingState()
            else if (snapshot.hasError && aquariums.isEmpty)
              _ErrorState(message: _errorMessage(context, snapshot.error))
            else if (aquariums.isEmpty)
              _EmptyState(onAdd: () => _openAquariumForm(context))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: aquariums.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _AquariumFirestoreCard(
                  aquarium: aquariums[index],
                  onDetails: () => _openChartScreen(context, aquariums[index]),
                  onEdit: () =>
                      _openAquariumForm(context, initial: aquariums[index]),
                  onDelete: () => _deleteAquarium(context, aquariums[index]),
                ),
              ),
            if (snapshot.hasError && aquariums.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage(context, snapshot.error),
                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              ),
            ],
          ],
        );
      },
    );
  }

  void _openChartScreen(BuildContext context, AquariumModel aquarium) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AquariumDetailsScreen(aquarium: aquarium),
      ),
    );
  }

  Future<void> _openAquariumForm(
    BuildContext context, {
    AquariumModel? initial,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<AquariumModel>(
      context: context,
      builder: (_) => _AquariumFormDialog(initial: initial),
    );
    if (result == null || !context.mounted) return;

    try {
      if (initial == null) {
        await _service.addAquarium(result);
      } else {
        await _service.updateAquarium(result);
      }
      if (context.mounted) {
        _showMessage(
          context,
          initial == null
              ? l10n.aquariumAddedMessage
              : l10n.aquariumUpdatedMessage,
        );
      }
    } on FirestoreServiceException catch (error) {
      if (context.mounted) _showMessage(context, error.message, isError: true);
    }
  }

  Future<void> _deleteAquarium(
    BuildContext context,
    AquariumModel aquarium,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAquariumTitle),
        content: Text(l10n.deleteAquariumPrompt(aquarium.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !context.mounted) return;

    try {
      await _service.deleteAquarium(aquarium.id);
      if (context.mounted) _showMessage(context, l10n.aquariumDeletedMessage);
    } on FirestoreServiceException catch (error) {
      if (context.mounted) _showMessage(context, error.message, isError: true);
    }
  }

  String _errorMessage(BuildContext context, Object? error) {
    if (error is FirestoreServiceException) return error.message;
    return AppLocalizations.of(context)!.aquariumLoadError;
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
      ),
    );
  }
}

class _AquariumFirestoreCard extends StatelessWidget {
  const _AquariumFirestoreCard({
    required this.aquarium,
    required this.onDetails,
    required this.onEdit,
    required this.onDelete,
  });

  final AquariumModel aquarium;
  final VoidCallback onDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDetails,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.water_drop_outlined,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aquarium.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatCapacity(aquarium.capacityLiters)} l · ${aquariumTypeLabel(l10n, aquarium.type)}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      l10n.aquariumEstablishedOn(
                        _formatDate(aquarium.setupDate),
                      ),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: l10n.aquariumOptionsTooltip,
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text(l10n.editAction)),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.deleteAction),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AquariumFormDialog extends StatefulWidget {
  const _AquariumFormDialog({this.initial});

  final AquariumModel? initial;

  @override
  State<_AquariumFormDialog> createState() => _AquariumFormDialogState();
}

class _AquariumFormDialogState extends State<_AquariumFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _capacityController;
  late DateTime _setupDate;
  late String _type;

  @override
  void initState() {
    super.initState();
    final aquarium = widget.initial;
    _nameController = TextEditingController(text: aquarium?.name ?? '');
    _capacityController = TextEditingController(
      text: aquarium == null ? '' : _formatCapacity(aquarium.capacityLiters),
    );
    _setupDate = aquarium?.setupDate ?? DateTime.now();
    _type = aquariumTypeKey(aquarium?.type);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.initial != null;
    return AlertDialog(
      title: Text(isEditing ? l10n.editAquariumTitle : l10n.addAquariumTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.aquariumNameLabel,
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.aquariumNameRequired
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.aquariumCapacityLabel,
                  suffixText: 'l',
                  prefixIcon: Icon(Icons.straighten_outlined),
                ),
                validator: (value) {
                  final capacity = double.tryParse(
                    (value ?? '').trim().replaceAll(',', '.'),
                  );
                  return capacity == null || capacity <= 0
                      ? l10n.aquariumCapacityInvalid
                      : null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: l10n.aquariumTypeLabel,
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'freshwater',
                    child: Text(l10n.freshwaterType),
                  ),
                  DropdownMenuItem(
                    value: 'marine',
                    child: Text(l10n.saltwaterType),
                  ),
                  DropdownMenuItem(
                    value: 'planted',
                    child: Text(l10n.plantedTankType),
                  ),
                  DropdownMenuItem(
                    value: 'biotope',
                    child: Text(l10n.biotopeTankType),
                  ),
                  DropdownMenuItem(
                    value: 'shrimp',
                    child: Text(l10n.shrimpTankType),
                  ),
                ],
                onChanged: (value) => setState(() => _type = value ?? _type),
              ),
              const SizedBox(height: 4),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(l10n.aquariumSetupDateLabel),
                subtitle: Text(_formatDate(_setupDate)),
                onTap: _selectDate,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(isEditing ? l10n.save : l10n.add),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: _setupDate.isAfter(DateTime.now())
          ? DateTime.now()
          : _setupDate,
    );
    if (date != null && mounted) setState(() => _setupDate = date);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final capacity = double.parse(
      _capacityController.text.trim().replaceAll(',', '.'),
    );
    final initial = widget.initial;
    Navigator.pop(
      context,
      AquariumModel(
        id: initial?.id ?? '',
        userId: initial?.userId ?? '',
        name: _nameController.text.trim(),
        capacityLiters: capacity,
        setupDate: _setupDate,
        type: _type,
        createdAt: initial?.createdAt ?? DateTime.now(),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.water_drop_outlined,
            color: Colors.teal.shade300,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(l10n.noAquariumsAdded),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(l10n.addFirstAquariumAction),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: Colors.red.shade700),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

String _formatCapacity(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}
