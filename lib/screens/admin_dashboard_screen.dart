import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/partner_model.dart';
import '../models/ticket_models.dart';
import '../services/admin_service.dart';

import 'package:akwarium/utils/app_snackbar.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return _AdminRouteGuard(
        title: l10n.adminDashboardTitle,
        message: l10n.adminAccessDenied,
      );
    }

    final service = AdminService();
    return StreamBuilder<bool>(
      stream: service.watchAdminAccess(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.adminDashboardTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return _AdminRouteGuard(
            title: l10n.adminDashboardTitle,
            message: l10n.adminLoadError(snapshot.error.toString()),
          );
        }
        if (snapshot.data != true) {
          return _AdminRouteGuard(
            title: l10n.adminDashboardTitle,
            message: l10n.adminAccessDenied,
          );
        }
        return _AdminDashboardTabs(service: service);
      },
    );
  }
}

class _AdminDashboardTabs extends StatelessWidget {
  const _AdminDashboardTabs({required this.service});

  final AdminService service;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.adminDashboardTitle),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(
                icon: const Icon(Icons.query_stats),
                text: l10n.adminStatsTab,
              ),
              Tab(
                icon: const Icon(Icons.support_agent),
                text: l10n.adminTicketsTab,
              ),
              Tab(
                icon: const Icon(Icons.people_outline),
                text: l10n.adminUsersTab,
              ),
              Tab(
                icon: const Icon(Icons.handshake_outlined),
                text: l10n.adminPartnersTab,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AdminOverviewTab(service: service),
            _AdminTicketsTab(service: service),
            _AdminUsersTab(service: service),
            _AdminPartnersTab(service: service),
          ],
        ),
      ),
    );
  }
}

class _AdminPartnersTab extends StatefulWidget {
  const _AdminPartnersTab({required this.service});

  final AdminService service;

  @override
  State<_AdminPartnersTab> createState() => _AdminPartnersTabState();
}

class _AdminPartnersTabState extends State<_AdminPartnersTab> {
  final Set<String> _updating = {};

  Future<void> _openEditor([Partner? partner]) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => AdminPartnerEditorDialog(
        partner: partner,
        onSave: (draft) =>
            widget.service.savePartner(partnerId: partner?.id, partner: draft),
      ),
    );
  }

  Future<void> _updateVisibility(Partner partner, bool isActive) async {
    if (_updating.contains(partner.id)) return;
    setState(() => _updating.add(partner.id));
    try {
      await widget.service.updatePartnerVisibility(
        partnerId: partner.id,
        isActive: isActive,
      );
      if (!mounted) return;
      context.showAppSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.adminPartnerVisibilitySaved,
          ),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      context.showAppSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.adminLoadError(error.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _updating.remove(partner.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: Text(l10n.adminAddPartner),
      ),
      body: StreamBuilder<List<Partner>>(
        stream: widget.service.watchPartners(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _AdminErrorState(
              message: l10n.adminLoadError(snapshot.error.toString()),
              onRetry: () => setState(() {}),
            );
          }
          final partners = snapshot.data ?? const <Partner>[];
          if (partners.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(l10n.adminNoPartners, textAlign: TextAlign.center),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            itemCount: partners.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final partner = partners[index];
              final updating = _updating.contains(partner.id);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary
                        .withValues(alpha: 0.14),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(_partnerIcon(partner.category)),
                  ),
                  title: Text(
                    partner.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${_partnerCategoryLabel(l10n, partner.category)} · '
                    '${l10n.adminPartnerOrder(partner.order)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (updating)
                        const SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Tooltip(
                          message: l10n.adminPartnerVisibility,
                          child: Switch(
                            value: partner.isActive,
                            onChanged: (value) =>
                                _updateVisibility(partner, value),
                          ),
                        ),
                      IconButton(
                        tooltip: l10n.adminEditPartner,
                        onPressed: updating ? null : () => _openEditor(partner),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminPartnerEditorDialog extends StatefulWidget {
  const AdminPartnerEditorDialog({
    required this.onSave,
    this.partner,
    super.key,
  });

  final Partner? partner;
  final Future<void> Function(PartnerDraft draft) onSave;

  @override
  State<AdminPartnerEditorDialog> createState() =>
      _AdminPartnerEditorDialogState();
}

class _AdminPartnerEditorDialogState extends State<AdminPartnerEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _urlController;
  late final TextEditingController _promoCodeController;
  late final TextEditingController _promoTextController;
  late final TextEditingController _tipController;
  late final TextEditingController _orderController;
  late PartnerCategory _category;
  late bool _isActive;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final partner = widget.partner;
    _nameController = TextEditingController(text: partner?.name);
    _subtitleController = TextEditingController(text: partner?.subtitle);
    _descriptionController = TextEditingController(text: partner?.description);
    _urlController = TextEditingController(text: partner?.url);
    _promoCodeController = TextEditingController(text: partner?.promoCode);
    _promoTextController = TextEditingController(text: partner?.promoText);
    _tipController = TextEditingController(text: partner?.tipText);
    _orderController = TextEditingController(text: '${partner?.order ?? 10}');
    _category = partner?.category == PartnerCategory.unknown
        ? PartnerCategory.creator
        : partner?.category ?? PartnerCategory.creator;
    _isActive = partner?.isActive ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _promoCodeController.dispose();
    _promoTextController.dispose();
    _tipController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty
        ? AppLocalizations.of(context)!.adminPartnerRequired
        : null;
  }

  String? _urlValidator(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;
    final uri = Uri.tryParse(value!.trim());
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return AppLocalizations.of(context)!.adminPartnerInvalidUrl;
    }
    return null;
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(
        PartnerDraft(
          name: _nameController.text,
          category: _category,
          subtitle: _subtitleController.text,
          description: _descriptionController.text,
          url: _urlController.text,
          promoCode: _promoCodeController.text,
          promoText: _promoTextController.text,
          tipText: _tipController.text,
          order: int.parse(_orderController.text.trim()),
          isActive: _isActive,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: math.min(620, screenSize.width - 32),
        height: math.min(760, screenSize.height - 32),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.partner == null
                          ? l10n.adminAddPartner
                          : l10n.adminEditPartner,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(context)
                        .closeButtonTooltip,
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        maxLength: 80,
                        decoration: InputDecoration(
                          labelText: l10n.adminPartnerName,
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<PartnerCategory>(
                        initialValue: _category,
                        decoration: InputDecoration(
                          labelText: l10n.adminPartnerCategory,
                        ),
                        items: [
                          for (final category in [
                            PartnerCategory.creator,
                            PartnerCategory.shop,
                            PartnerCategory.breeder,
                          ])
                            DropdownMenuItem(
                              value: category,
                              child: Text(
                                _partnerCategoryLabel(l10n, category),
                              ),
                            ),
                        ],
                        onChanged: _saving
                            ? null
                            : (value) => setState(
                                () => _category =
                                    value ?? PartnerCategory.creator,
                              ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _subtitleController,
                        maxLength: 100,
                        decoration: InputDecoration(
                          labelText: l10n.adminPartnerSubtitle,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        minLines: 2,
                        maxLines: 4,
                        maxLength: 400,
                        decoration: InputDecoration(
                          labelText: l10n.adminPartnerDescription,
                          alignLabelWithHint: true,
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _urlController,
                        keyboardType: TextInputType.url,
                        maxLength: 500,
                        decoration: InputDecoration(
                          labelText: l10n.adminPartnerUrl,
                        ),
                        validator: _urlValidator,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _promoCodeController,
                        maxLength: 60,
                        decoration: InputDecoration(
                          labelText: l10n.adminPartnerPromoCode,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _promoTextController,
                        maxLength: 160,
                        decoration: InputDecoration(
                          labelText: l10n.adminPartnerPromoText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _tipController,
                        minLines: 2,
                        maxLines: 5,
                        maxLength: 600,
                        decoration: InputDecoration(
                          labelText: l10n.adminPartnerTip,
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _orderController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.adminPartnerOrderLabel,
                        ),
                        validator: (value) =>
                            int.tryParse(value?.trim() ?? '') == null
                            ? l10n.adminPartnerOrderInvalid
                            : null,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.adminPartnerVisibility),
                        subtitle: Text(l10n.adminPartnerVisibilityHint),
                        value: _isActive,
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _isActive = value),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        _InlineError(message: l10n.adminLoadError(_error!)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(l10n.save),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminOverviewTab extends StatefulWidget {
  const _AdminOverviewTab({required this.service});

  final AdminService service;

  @override
  State<_AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<_AdminOverviewTab> {
  late Future<AdminOverview> _overview;

  @override
  void initState() {
    super.initState();
    _overview = widget.service.loadOverview();
  }

  void _reload() => setState(() => _overview = widget.service.loadOverview());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<AdminOverview>(
      future: _overview,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _AdminErrorState(
            message: l10n.adminLoadError(snapshot.error.toString()),
            onRetry: _reload,
          );
        }
        final data = snapshot.data!;
        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 580
                ? 3
                : 2;
            return GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                _AdminStatTile(
                  icon: Icons.people_outline,
                  title: l10n.adminTotalUsers,
                  value: '${data.totalUsers}',
                ),
                _AdminStatTile(
                  icon: Icons.workspace_premium_outlined,
                  title: l10n.adminActivePro,
                  value: '${data.activePro}',
                ),
                _AdminStatTile(
                  icon: Icons.calendar_month_outlined,
                  title: l10n.adminMonthlyPlans,
                  value: '${data.monthlyPlans}',
                ),
                _AdminStatTile(
                  icon: Icons.event_repeat_outlined,
                  title: l10n.adminYearlyPlans,
                  value: '${data.yearlyPlans}',
                ),
                _AdminStatTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: l10n.adminManualGrants,
                  value: '${data.manualGrants}',
                ),
                _AdminStatTile(
                  icon: Icons.forum_outlined,
                  title: l10n.adminTotalTickets,
                  value: '${data.totalTickets}',
                ),
                _AdminStatTile(
                  icon: Icons.mark_email_unread_outlined,
                  title: l10n.adminOpenTickets,
                  value: '${data.openTickets}',
                ),
                _AdminStatTile(
                  icon: Icons.card_giftcard_outlined,
                  title: l10n.adminSuccessfulReferrals,
                  value: '${data.successfulReferrals}',
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AdminStatTile extends StatelessWidget {
  const _AdminStatTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: colors.primary),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

enum _TicketFilter { all, open, inProgress, closed }

class _AdminTicketsTab extends StatefulWidget {
  const _AdminTicketsTab({required this.service});

  final AdminService service;

  @override
  State<_AdminTicketsTab> createState() => _AdminTicketsTabState();
}

class _AdminTicketsTabState extends State<_AdminTicketsTab> {
  _TicketFilter _filter = _TicketFilter.all;

  List<TicketModel> _filtered(List<TicketModel> tickets) => switch (_filter) {
    _TicketFilter.all => tickets,
    _TicketFilter.open =>
      tickets.where((ticket) => ticket.status == TicketStatus.open).toList(),
    _TicketFilter.inProgress =>
      tickets
          .where((ticket) => ticket.status == TicketStatus.inProgress)
          .toList(),
    _TicketFilter.closed =>
      tickets
          .where(
            (ticket) =>
                ticket.status == TicketStatus.closed ||
                ticket.status == TicketStatus.resolved,
          )
          .toList(),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<TicketModel>>(
      stream: widget.service.watchTickets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _AdminErrorState(
            message: l10n.adminLoadError(snapshot.error.toString()),
            onRetry: () => setState(() {}),
          );
        }
        final tickets = _filtered(snapshot.data ?? const <TicketModel>[]);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _filterChip(l10n.adminFilterAll, _TicketFilter.all),
                  _filterChip(l10n.adminFilterOpen, _TicketFilter.open),
                  _filterChip(
                    l10n.adminFilterInProgress,
                    _TicketFilter.inProgress,
                  ),
                  _filterChip(l10n.adminFilterClosed, _TicketFilter.closed),
                ],
              ),
            ),
            Expanded(
              child: tickets.isEmpty
                  ? Center(child: Text(l10n.adminNoTickets))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: tickets.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final ticket = tickets[index];
                        return _AdminTicketTile(
                          ticket: ticket,
                          onTap: () async {
                            await Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => AdminTicketDetailScreen(
                                  service: widget.service,
                                  ticket: ticket,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _filterChip(String label, _TicketFilter filter) => ChoiceChip(
    label: Text(label),
    selected: _filter == filter,
    onSelected: (_) => setState(() => _filter = filter),
  );
}

class _AdminTicketTile extends StatelessWidget {
  const _AdminTicketTile({required this.ticket, required this.onTap});

  final TicketModel ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(
            Icons.mail_outline,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(
          ticket.subject,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${ticket.category.emoji} ${_categoryLabel(l10n, ticket.category)} · ${ticket.userEmail}\n${_dateLabel(context, ticket.createdAt)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: _StatusBadge(status: ticket.status),
      ),
    );
  }
}

class AdminTicketDetailScreen extends StatefulWidget {
  const AdminTicketDetailScreen({
    required this.service,
    required this.ticket,
    super.key,
  });

  final AdminService service;
  final TicketModel ticket;

  @override
  State<AdminTicketDetailScreen> createState() =>
      _AdminTicketDetailScreenState();
}

class _AdminTicketDetailScreenState extends State<AdminTicketDetailScreen> {
  late final TextEditingController _replyController;
  late TicketStatus _status;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController(
      text: widget.ticket.adminResponse ?? '',
    );
    _status = widget.ticket.status;
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.service.updateTicket(
        ticketId: widget.ticket.ticketId,
        status: _status,
        adminResponse: _replyController.text,
      );
      if (!mounted) return;
      context.showAppSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.adminTicketSaved)),
      );
      Navigator.pop(context);
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminTicketDetails)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            widget.ticket.subject,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _InfoLine(
            label: l10n.adminTicketEmail,
            value: widget.ticket.userEmail,
            icon: Icons.alternate_email,
          ),
          _InfoLine(
            label: l10n.adminTicketCategory,
            value:
                '${widget.ticket.category.emoji} ${_categoryLabel(l10n, widget.ticket.category)}',
            icon: Icons.sell_outlined,
          ),
          _InfoLine(
            label: l10n.adminTicketCreated(
              _dateLabel(context, widget.ticket.createdAt),
            ),
            value: '',
            icon: Icons.schedule,
          ),
          const SizedBox(height: 10),
          _AdminTextBlock(
            title: l10n.adminTicketDescription,
            text: widget.ticket.description,
          ),
          if (widget.ticket.imageUrl?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              l10n.adminTicketAttachment,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.ticket.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<TicketStatus>(
            initialValue: _status,
            decoration: InputDecoration(labelText: l10n.adminStatusOpen),
            items: TicketStatus.values
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(_statusLabel(l10n, status)),
                  ),
                )
                .toList(),
            onChanged: _saving
                ? null
                : (value) {
                    if (value != null) setState(() => _status = value);
                  },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _replyController,
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: l10n.adminSupportReply,
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _InlineError(message: l10n.adminLoadError(_error!)),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(l10n.adminSaveTicket),
          ),
        ],
      ),
    );
  }
}

class _AdminUsersTab extends StatefulWidget {
  const _AdminUsersTab({required this.service});

  final AdminService service;

  @override
  State<_AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<_AdminUsersTab> {
  final _searchController = TextEditingController();
  late Future<List<AdminUserRecord>> _users;
  AdminUserSort _sort = AdminUserSort.lastActive;

  @override
  void initState() {
    super.initState();
    _users = widget.service.loadUsers(sort: _sort);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    labelText: l10n.adminSearchUsers,
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: MaterialLocalizations.of(context)
                                .deleteButtonTooltip,
                            onPressed: _searchController.clear,
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<AdminUserSort>(
                  initialValue: _sort,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.adminSortUsers),
                  items: [
                    DropdownMenuItem(
                      value: AdminUserSort.lastActive,
                      child: Text(l10n.adminSortLastActive),
                    ),
                    DropdownMenuItem(
                      value: AdminUserSort.newest,
                      child: Text(l10n.adminSortNewest),
                    ),
                    DropdownMenuItem(
                      value: AdminUserSort.alphabetical,
                      child: Text(l10n.adminSortAlphabetical),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null || value == _sort) return;
                    setState(() {
                      _sort = value;
                      _users = widget.service.loadUsers(sort: value);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<AdminUserRecord>>(
            future: _users,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _AdminErrorState(
                  message: l10n.adminLoadError(snapshot.error.toString()),
                  onRetry: () =>
                      setState(
                        () =>
                            _users = widget.service.loadUsers(sort: _sort),
                      ),
                );
              }
              final query = _searchController.text.trim().toLowerCase();
              final users = (snapshot.data ?? const <AdminUserRecord>[])
                  .where(
                    (user) =>
                        query.isEmpty ||
                        user.email.toLowerCase().contains(query) ||
                        user.displayName.toLowerCase().contains(query),
                  )
                  .toList();
              if (users.isEmpty) return Center(child: Text(l10n.adminNoUsers));
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: users.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _AdminUserTile(
                    user: user,
                    onTap: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => AdminUserDetailScreen(
                            service: widget.service,
                            user: user,
                          ),
                        ),
                      );
                      if (mounted) {
                        setState(
                          () =>
                              _users = widget.service.loadUsers(sort: _sort),
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AdminUserTile extends StatelessWidget {
  const _AdminUserTile({required this.user, required this.onTap});

  final AdminUserRecord user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPro = user.isProActiveAt(DateTime.now());
    final name = user.displayName.trim().isEmpty
        ? user.email
        : user.displayName;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(name.isEmpty ? '?' : name[0].toUpperCase()),
        ),
        title: Text(name.isEmpty ? l10n.adminNameUnavailable : name),
        subtitle: Text(
          '${user.email}\n'
          '${l10n.adminRegisteredAt}: ${_optionalDateLabel(context, user.createdAt, l10n.adminNoData)}\n'
          '${l10n.adminLastActiveAt}: ${_optionalDateLabel(context, user.lastActiveAt, l10n.adminNoData)}',
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: _PlanBadge(isPro: isPro),
      ),
    );
  }
}

class AdminUserDetailScreen extends StatefulWidget {
  const AdminUserDetailScreen({
    required this.service,
    required this.user,
    super.key,
  });

  final AdminService service;
  final AdminUserRecord user;

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  late bool _isPro;
  late DateTime? _expiry;
  late String _plan;
  late Future<List<AdminInvitedUser>> _invitedUsers;
  late Future<List<String>> _authProviders;
  bool _updating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _isPro = widget.user.isProActiveAt(DateTime.now());
    _expiry = widget.user.proExpiryDate;
    _plan = widget.user.subscriptionPlan;
    _invitedUsers = widget.service.loadInvitedUsers(widget.user.id);
    _authProviders = widget.service.loadAuthProviders(widget.user.id);
  }

  DateTime? _expiryFor(_ProGrantPeriod period) {
    final now = DateTime.now();
    return switch (period) {
      _ProGrantPeriod.day1 => now.add(const Duration(hours: 24)),
      _ProGrantPeriod.days7 => now.add(const Duration(days: 7)),
      _ProGrantPeriod.days14 => now.add(const Duration(days: 14)),
      _ProGrantPeriod.month => _addMonths(now, 1),
      _ProGrantPeriod.year => DateTime(
        now.year + 1,
        now.month,
        now.day,
        now.hour,
        now.minute,
        now.second,
      ),
      _ProGrantPeriod.indefinite => null,
    };
  }

  DateTime _addMonths(DateTime date, int months) {
    final monthIndex = date.month - 1 + months;
    final year = date.year + monthIndex ~/ 12;
    final month = monthIndex % 12 + 1;
    final lastDay = DateUtils.getDaysInMonth(year, month);
    return DateTime(
      year,
      month,
      math.min(date.day, lastDay),
      date.hour,
      date.minute,
      date.second,
    );
  }

  Future<void> _grantPro() async {
    final l10n = AppLocalizations.of(context)!;
    final period = await showModalBottomSheet<_ProGrantPeriod>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                l10n.adminGrantDuration,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final period in _ProGrantPeriod.values)
              ListTile(
                leading: const Icon(Icons.schedule_outlined),
                title: Text(_periodLabel(l10n, period)),
                onTap: () => Navigator.pop(context, period),
              ),
          ],
        ),
      ),
    );
    if (period == null || !mounted) return;
    final expiry = _expiryFor(period);
    setState(() {
      _updating = true;
      _error = null;
    });
    try {
      await widget.service.grantPro(userId: widget.user.id, expiresAt: expiry);
      if (!mounted) return;
      setState(() {
        _isPro = true;
        _expiry = expiry;
        _plan = 'manual';
      });
      context.showAppSnackBar(SnackBar(content: Text(l10n.adminGrantSuccess)));
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _revokePro() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminConfirmRevokeTitle),
        content: Text(l10n.adminConfirmRevokeBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.adminCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.adminConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _updating = true;
      _error = null;
    });
    try {
      await widget.service.revokePro(widget.user.id);
      if (!mounted) return;
      setState(() {
        _isPro = false;
        _expiry = null;
        _plan = '';
      });
      context.showAppSnackBar(SnackBar(content: Text(l10n.adminRevokeSuccess)));
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.user.email.trim().isEmpty) {
      setState(() => _error = l10n.adminEmailUnavailable);
      return;
    }
    setState(() {
      _updating = true;
      _error = null;
    });
    try {
      final providers = await _authProviders;
      if (!providers.contains('password')) {
        throw AdminServiceException(l10n.adminPasswordResetGoogleOnly);
      }
      await widget.service.sendPasswordReset(widget.user.email);
      if (mounted) {
        context.showAppSnackBar(
          SnackBar(content: Text(l10n.adminPasswordResetSent)),
        );
      }
    } on AdminServiceException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error = l10n.adminLoadError(error.toString()));
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final firstConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(dialogContext).colorScheme.error,
        ),
        title: Text(l10n.adminDeleteAccountTitle),
        content: Text(l10n.adminDeleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.adminCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.adminDeleteAccount),
          ),
        ],
      ),
    );
    if (firstConfirmed != true || !mounted) return;
    final secondConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.adminDeleteAccountSecondTitle),
        content: Text(
          l10n.adminDeleteAccountSecondBody(
            widget.user.email.isEmpty ? widget.user.id : widget.user.email,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.adminCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.adminConfirm),
          ),
        ],
      ),
    );
    if (secondConfirmed != true || !mounted) return;

    setState(() {
      _updating = true;
      _error = null;
    });
    try {
      await widget.service.deleteUserAccount(widget.user.id);
      if (!mounted) return;
      context.showAppSnackBar(
        SnackBar(content: Text(l10n.adminDeleteAccountSuccess)),
      );
      Navigator.pop(context);
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error = l10n.adminLoadError(error.toString()));
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = widget.user.displayName.trim().isEmpty
        ? l10n.adminNameUnavailable
        : widget.user.displayName;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminUserDetails)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _InfoLine(
                    label: l10n.adminUserEmail,
                    value: widget.user.email,
                    icon: Icons.alternate_email,
                  ),
                  _InfoLine(
                    label: l10n.adminRegisteredAt,
                    value: _optionalDateLabel(
                      context,
                      widget.user.createdAt,
                      l10n.adminNoData,
                    ),
                    icon: Icons.person_add_alt_1_outlined,
                  ),
                  _InfoLine(
                    label: l10n.adminLastActiveAt,
                    value: _optionalDateLabel(
                      context,
                      widget.user.lastActiveAt,
                      l10n.adminNoData,
                    ),
                    icon: Icons.schedule_outlined,
                  ),
                  _InfoLine(
                    label: l10n.adminSubscriptionPlan,
                    value: _plan.isEmpty
                        ? (_isPro ? l10n.adminProPlan : l10n.adminFreePlan)
                        : _plan,
                    icon: Icons.workspace_premium_outlined,
                  ),
                  _InfoLine(
                    label: _expiry == null
                        ? l10n.adminNoExpiry
                        : l10n.adminExpiryDate(_dateLabel(context, _expiry!)),
                    value: '',
                    icon: Icons.event_outlined,
                  ),
                  _InfoLine(
                    label: l10n.adminReferralsCount(
                      widget.user.successfulReferralsCount,
                    ),
                    value: '',
                    icon: Icons.card_giftcard_outlined,
                  ),
                  const SizedBox(height: 12),
                  if (_updating)
                    const Center(child: CircularProgressIndicator())
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: _grantPro,
                          icon: const Icon(Icons.workspace_premium_outlined),
                          label: Text(l10n.adminGrantPro),
                        ),
                        if (_isPro)
                          OutlinedButton.icon(
                            onPressed: _revokePro,
                            icon: const Icon(Icons.remove_circle_outline),
                            label: Text(l10n.adminRevokePro),
                          ),
                        OutlinedButton.icon(
                          onPressed: _sendPasswordReset,
                          icon: const Icon(Icons.lock_reset_outlined),
                          label: Text(l10n.adminSendPasswordReset),
                        ),
                        OutlinedButton.icon(
                          onPressed: _deleteAccount,
                          icon: Icon(
                            Icons.delete_forever_outlined,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          label: Text(
                            l10n.adminDeleteAccount,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  FutureBuilder<List<String>>(
                    future: _authProviders,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          !snapshot.hasError) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _InlineError(
                          message: l10n.adminAccountProvidersLoadError,
                        ),
                      );
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    _InlineError(message: l10n.adminLoadError(_error!)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.adminInvitedUsers,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<AdminInvitedUser>>(
            future: _invitedUsers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return _InlineError(
                  message: l10n.adminLoadError(snapshot.error.toString()),
                );
              }
              final invited = snapshot.data ?? const <AdminInvitedUser>[];
              if (invited.isEmpty) return Text(l10n.adminNoInvitedUsers);
              return Column(
                children: [
                  for (final person in invited)
                    Card(
                      child: ListTile(
                        leading: Icon(
                          person.isCompleted
                              ? Icons.check_circle_outline
                              : Icons.hourglass_empty,
                        ),
                        title: Text(
                          person.displayName.trim().isEmpty
                              ? (person.email.isEmpty
                                    ? l10n.adminNameUnavailable
                                    : person.email)
                              : person.displayName,
                        ),
                        subtitle: Text(person.email),
                        trailing: Text(
                          person.isCompleted
                              ? l10n.adminReferralCompleted
                              : l10n.adminReferralPending,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

enum _ProGrantPeriod { day1, days7, days14, month, year, indefinite }

String _periodLabel(AppLocalizations l10n, _ProGrantPeriod period) =>
    switch (period) {
      _ProGrantPeriod.day1 => l10n.adminDuration1Day,
      _ProGrantPeriod.days7 => l10n.adminDuration7Days,
      _ProGrantPeriod.days14 => l10n.adminDuration14Days,
      _ProGrantPeriod.month => l10n.adminDuration1Month,
      _ProGrantPeriod.year => l10n.adminDuration1Year,
      _ProGrantPeriod.indefinite => l10n.adminDurationIndefinite,
    };

class _AdminRouteGuard extends StatefulWidget {
  const _AdminRouteGuard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  State<_AdminRouteGuard> createState() => _AdminRouteGuardState();
}

class _AdminRouteGuardState extends State<_AdminRouteGuard> {
  var _redirectStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  void _redirect() {
    if (!mounted || _redirectStarted) return;
    _redirectStarted = true;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
      return;
    }
    final destination = FirebaseAuth.instance.currentUser == null
        ? '/login'
        : '/dashboard';
    navigator.pushNamedAndRemoveUntil(destination, (_) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 32),
            const SizedBox(height: 12),
            Text(widget.message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    ),
  );
}

class _AdminErrorState extends StatelessWidget {
  const _AdminErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 36),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context)!.adminRetry),
          ),
        ],
      ),
    ),
  );
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Text(
    message,
    style: TextStyle(color: Theme.of(context).colorScheme.error),
  );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value.isEmpty ? label : '$label: $value',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );
}

class _AdminTextBlock extends StatelessWidget {
  const _AdminTextBlock({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SelectableText(text),
        ],
      ),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TicketStatus.open => Colors.orange,
      TicketStatus.inProgress => Colors.blue,
      TicketStatus.resolved => Colors.green,
      TicketStatus.closed => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(AppLocalizations.of(context)!, status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.isPro});

  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(
        isPro ? Icons.workspace_premium : Icons.person_outline,
        size: 16,
      ),
      label: Text(
        isPro
            ? AppLocalizations.of(context)!.adminProPlan
            : AppLocalizations.of(context)!.adminFreePlan,
      ),
      backgroundColor: isPro
          ? colors.tertiaryContainer
          : colors.surfaceContainerHighest,
      side: BorderSide.none,
    );
  }
}

String _statusLabel(AppLocalizations l10n, TicketStatus status) =>
    switch (status) {
      TicketStatus.open => l10n.adminStatusOpen,
      TicketStatus.inProgress => l10n.adminStatusInProgress,
      TicketStatus.resolved => l10n.adminStatusResolved,
      TicketStatus.closed => l10n.adminStatusClosed,
    };

IconData _partnerIcon(PartnerCategory category) => switch (category) {
  PartnerCategory.creator => Icons.play_circle_outline,
  PartnerCategory.shop => Icons.storefront_outlined,
  PartnerCategory.breeder => Icons.set_meal_outlined,
  PartnerCategory.unknown => Icons.handshake_outlined,
};

String _partnerCategoryLabel(AppLocalizations l10n, PartnerCategory category) =>
    switch (category) {
      PartnerCategory.creator => l10n.partnerCreator,
      PartnerCategory.shop => l10n.partnerShop,
      PartnerCategory.breeder => l10n.partnerBreeder,
      PartnerCategory.unknown => l10n.partnersTitle,
    };

String _categoryLabel(AppLocalizations l10n, TicketCategory category) =>
    switch (category) {
      TicketCategory.bug => l10n.ticketBugCategory.replaceFirst('🐛 ', ''),
      TicketCategory.feature => l10n.ticketFeatureCategory.replaceFirst(
        '💡 ',
        '',
      ),
      TicketCategory.subscription =>
        l10n.ticketSubscriptionCategory.replaceFirst('💳 ', ''),
      TicketCategory.business => l10n.ticketBusinessCategory.replaceFirst(
        '🤝 ',
        '',
      ),
      TicketCategory.other => l10n.ticketOtherCategory.replaceFirst('❓ ', ''),
    };

String _dateLabel(BuildContext context, DateTime date) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag())
        .add_jm()
        .format(date.toLocal());

String _optionalDateLabel(
  BuildContext context,
  DateTime? date,
  String fallback,
) => date == null ? fallback : _dateLabel(context, date);
