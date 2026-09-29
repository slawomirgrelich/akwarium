import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/ticket_models.dart';
import '../services/ticket_service.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TicketService>();
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpCenterTitle)),
      body: RefreshIndicator(
        onRefresh: service.refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const _HelpHero(),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const NewTicketScreen()),
              ),
              icon: const Icon(Icons.add_comment_outlined),
              label: Text(l10n.createTicket),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const MyTicketsScreen()),
              ),
              icon: const Icon(Icons.inbox_outlined),
              label: Text(
                service.tickets.isEmpty
                    ? l10n.myTicketsTitle
                    : l10n.myTicketsCount(service.tickets.length),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.quickAnswers,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const _FaqSection(),
            if (service.errorCode != null) ...[
              const SizedBox(height: 16),
              Text(
                _ticketErrorMessage(l10n, service.errorCode!),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HelpHero extends StatelessWidget {
  const _HelpHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF051923)
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.support_agent, size: 42),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.helpHeroTitle,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(l10n.helpHeroDescription, style: TextStyle(height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        ExpansionTile(
          leading: Icon(Icons.science_outlined),
          title: Text(l10n.faqAiTitle),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(l10n.faqAiAnswer),
            ),
          ],
        ),
        ExpansionTile(
          leading: Icon(Icons.water_drop_outlined),
          title: Text(l10n.faqNo3Title),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(l10n.faqNo3Answer),
            ),
          ],
        ),
        ExpansionTile(
          leading: Icon(Icons.notifications_active_outlined),
          title: Text(l10n.faqRemindersTitle),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(l10n.faqRemindersAnswer),
            ),
          ],
        ),
        ExpansionTile(
          leading: Icon(Icons.devices_other_outlined),
          title: Text(l10n.faqTransferTitle),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(l10n.faqTransferAnswer),
            ),
          ],
        ),
        ExpansionTile(
          leading: Icon(Icons.credit_card_outlined),
          title: Text(l10n.faqSubscriptionTitle),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(l10n.faqSubscriptionAnswer),
            ),
          ],
        ),
        ExpansionTile(
          leading: Icon(Icons.water_outlined),
          title: Text(l10n.faqMultipleAquariumsTitle),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(l10n.faqMultipleAquariumsAnswer),
            ),
          ],
        ),
      ],
    );
  }
}

class NewTicketScreen extends StatefulWidget {
  const NewTicketScreen({super.key});

  @override
  State<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  TicketCategory _category = TicketCategory.bug;
  Uint8List? _imageBytes;
  String? _imageName;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TicketService>();
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newTicketTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            DropdownButtonFormField<TicketCategory>(
              initialValue: _category,
              decoration: InputDecoration(
                labelText: l10n.ticketCategory,
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: TicketCategory.values
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(_categoryLabel(l10n, category)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subjectController,
              maxLength: 100,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.ticketSubject,
                hintText: l10n.ticketSubjectHint,
                prefixIcon: Icon(Icons.title_outlined),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? l10n.ticketSubjectRequired
                  : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              minLines: 7,
              maxLines: 12,
              maxLength: 4000,
              decoration: InputDecoration(
                labelText: l10n.ticketDescription,
                hintText: l10n.ticketDescriptionHint,
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 106),
                  child: Icon(Icons.notes_outlined),
                ),
              ),
              validator: (value) {
                if ((value?.trim().length ?? 0) < 15) {
                  return l10n.ticketDescriptionMin;
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: service.isSubmitting ? null : _pickImage,
              icon: const Icon(Icons.attach_file_outlined),
              label: Text(
                _imageName == null
                    ? l10n.attachImage
                    : l10n.changeAttachment(_imageName!),
              ),
            ),
            if (_imageBytes != null) ...[
              const SizedBox(height: 10),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _imageBytes!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filledTonal(
                      tooltip: l10n.removeAttachment,
                      onPressed: () => setState(() {
                        _imageBytes = null;
                        _imageName = null;
                      }),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            if (service.errorCode != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _ticketErrorMessage(l10n, service.errorCode!),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            FilledButton.icon(
              onPressed: service.isSubmitting ? null : _submit,
              icon: service.isSubmitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(
                service.isSubmitting ? l10n.sendingTicket : l10n.sendTicket,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      await context.read<TicketService>().submitTicket(
        category: _category,
        subject: _subjectController.text,
        description: _descriptionController.text,
        imageBytes: _imageBytes,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.ticketSent)));
    } on TicketServiceException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _ticketErrorMessage(AppLocalizations.of(context)!, error.code),
          ),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 2200,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageName = picked.name;
      });
    } on Object catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ticketPhotoReadError(error.toString()))),
      );
    }
  }
}

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TicketService>();
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myTicketsTitle)),
      body: RefreshIndicator(
        onRefresh: service.refresh,
        child: service.isLoading && service.tickets.isEmpty
            ? ListView(
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(48),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              )
            : service.tickets.isEmpty
            ? ListView(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Text(l10n.noTickets),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: service.tickets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final ticket = service.tickets[index];
                  return _TicketCard(
                    ticket: ticket,
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TicketDetailScreen(ticket: ticket),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.onTap});

  final TicketModel ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(ticket.status);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.subject,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _StatusBadge(status: ticket.status, color: statusColor),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${ticket.category.emoji}  ${_categoryShortLabel(l10n, ticket.category)}',
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('dd.MM.yyyy, HH:mm').format(ticket.updatedAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (ticket.adminResponse?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.reply_outlined, size: 17, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      l10n.ticketSupportReply,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});

  final TicketStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(AppLocalizations.of(context)!, status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({required this.ticket, super.key});

  final TicketModel ticket;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.ticketDetails)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ticket.subject,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              _StatusBadge(
                status: ticket.status,
                color: _statusColor(ticket.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_categoryLabel(l10n, ticket.category)),
          const SizedBox(height: 6),
          Text(
            l10n.ticketCreatedAt(
              DateFormat('dd.MM.yyyy, HH:mm').format(ticket.createdAt),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          _DetailBlock(
            title: l10n.ticketDescriptionSection,
            text: ticket.description,
          ),
          const SizedBox(height: 12),
          _DetailBlock(
            title: l10n.ticketTechnicalInfo,
            text: ticket.deviceInfo.entries
                .map((entry) => '${entry.key}: ${entry.value}')
                .join('\n'),
          ),
          if (ticket.imageUrl?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                ticket.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(l10n.ticketAttachmentError),
                ),
              ),
            ),
          ],
          if (ticket.adminResponse?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 12),
            _DetailBlock(
              title: l10n.ticketSupportReply,
              text: ticket.adminResponse!,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            SelectableText(text),
          ],
        ),
      ),
    );
  }
}

Color _statusColor(TicketStatus status) {
  switch (status) {
    case TicketStatus.open:
      return const Color(0xFF0284C7);
    case TicketStatus.inProgress:
      return const Color(0xFFD97706);
    case TicketStatus.resolved:
      return const Color(0xFF16A34A);
    case TicketStatus.closed:
      return const Color(0xFF64748B);
  }
}

String _categoryLabel(AppLocalizations l10n, TicketCategory category) {
  switch (category) {
    case TicketCategory.bug:
      return l10n.ticketBugCategory;
    case TicketCategory.feature:
      return l10n.ticketFeatureCategory;
    case TicketCategory.subscription:
      return l10n.ticketSubscriptionCategory;
    case TicketCategory.business:
      return l10n.ticketBusinessCategory;
    case TicketCategory.other:
      return l10n.ticketOtherCategory;
  }
}

String _categoryShortLabel(AppLocalizations l10n, TicketCategory category) {
  switch (category) {
    case TicketCategory.bug:
      return l10n.ticketBugCategory.replaceFirst('🐛 ', '');
    case TicketCategory.feature:
      return l10n.ticketFeatureCategory.replaceFirst('💡 ', '');
    case TicketCategory.subscription:
      return l10n.ticketSubscriptionCategory.replaceFirst('💳 ', '');
    case TicketCategory.business:
      return l10n.ticketBusinessCategory.replaceFirst('🤝 ', '');
    case TicketCategory.other:
      return l10n.ticketOtherCategory.replaceFirst('❓ ', '');
  }
}

String _statusLabel(AppLocalizations l10n, TicketStatus status) {
  switch (status) {
    case TicketStatus.open:
      return l10n.ticketStatusOpen;
    case TicketStatus.inProgress:
      return l10n.ticketStatusInProgress;
    case TicketStatus.resolved:
      return l10n.ticketStatusResolved;
    case TicketStatus.closed:
      return l10n.ticketStatusClosed;
  }
}

String _ticketErrorMessage(AppLocalizations l10n, TicketServiceErrorCode code) {
  switch (code) {
    case TicketServiceErrorCode.authRequired:
      return l10n.ticketAuthRequired;
    case TicketServiceErrorCode.subjectRequired:
      return l10n.ticketSubjectRequired;
    case TicketServiceErrorCode.descriptionTooShort:
      return l10n.ticketDescriptionMin;
    case TicketServiceErrorCode.permission:
      return l10n.ticketPermissionError;
    case TicketServiceErrorCode.offline:
      return l10n.ticketOfflineError;
    case TicketServiceErrorCode.missingIndex:
      return l10n.ticketIndexError;
    case TicketServiceErrorCode.generic:
      return l10n.ticketGenericError;
  }
}
