import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/ticket_models.dart';
import '../services/ticket_service.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TicketService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Centrum pomocy')),
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
              label: const Text('Utwórz nowe zgłoszenie'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const MyTicketsScreen()),
              ),
              icon: const Icon(Icons.inbox_outlined),
              label: Text('Moje zgłoszenia${service.tickets.isEmpty ? '' : ' (${service.tickets.length})'}'),
            ),
            const SizedBox(height: 28),
            Text('Szybkie odpowiedzi', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const _FaqSection(),
            if (service.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                service.errorMessage!,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF051923),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.support_agent, color: Color(0xFF00A8E8), size: 42),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jesteśmy tu, żeby pomóc',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  'Opisz problem, a zespół Akwarysta PRO wróci do Ciebie z odpowiedzią.',
                  style: TextStyle(color: Color(0xFFB9D3DE), height: 1.35),
                ),
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
    return const Column(
      children: [
        ExpansionTile(
          leading: Icon(Icons.science_outlined),
          title: Text('Jak działa weryfikacja parametrów?'),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text('Wybierz akwarium i dodaj wynik testu wody. Aplikacja porówna temperaturę, pH i twardość z zapisanymi normami.'),
            ),
          ],
        ),
        ExpansionTile(
          leading: Icon(Icons.credit_card_outlined),
          title: Text('Jak anulować subskrypcję PRO?'),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text('Subskrypcję zarządza się w ustawieniach sklepu Google Play lub App Store, z którego została kupiona.'),
            ),
          ],
        ),
        ExpansionTile(
          leading: Icon(Icons.mark_email_read_outlined),
          title: Text('Nie dostałem wiadomości weryfikacyjnej'),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text('Sprawdź folder spam i upewnij się, że adres e-mail na koncie jest poprawny. W razie problemu wyślij zgłoszenie.'),
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
  TicketCategory _category = TicketCategory.bug;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TicketService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Nowe zgłoszenie')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            DropdownButtonFormField<TicketCategory>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Kategoria',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: TicketCategory.values
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text('${category.emoji}  ${category.label}'),
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
              decoration: const InputDecoration(
                labelText: 'Tytuł',
                hintText: 'Krótko opisz problem',
                prefixIcon: Icon(Icons.title_outlined),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Wpisz tytuł zgłoszenia.'
                  : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              minLines: 7,
              maxLines: 12,
              maxLength: 4000,
              decoration: const InputDecoration(
                labelText: 'Szczegółowy opis',
                hintText: 'Co się wydarzyło? Jak można odtworzyć problem?',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 106),
                  child: Icon(Icons.notes_outlined),
                ),
              ),
              validator: (value) {
                if ((value?.trim().length ?? 0) < 15) {
                  return 'Opis musi mieć co najmniej 15 znaków.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (service.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  service.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            FilledButton.icon(
              onPressed: service.isSubmitting ? null : _submit,
              icon: service.isSubmitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(service.isSubmitting ? 'Wysyłanie...' : 'Wyślij zgłoszenie'),
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
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zgłoszenie zostało wysłane.')),
      );
    } on TicketServiceException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }
}

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TicketService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Moje zgłoszenia')),
      body: RefreshIndicator(
        onRefresh: service.refresh,
        child: service.isLoading && service.tickets.isEmpty
            ? ListView(children: const [Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()))])
            : service.tickets.isEmpty
            ? ListView(children: const [Center(child: Padding(padding: EdgeInsets.all(48), child: Text('Nie masz jeszcze żadnych zgłoszeń.')))])
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
                      MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: ticket)),
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
              Text('${ticket.category.emoji}  ${ticket.category.shortLabel}'),
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
                    Text('Odpowiedź od wsparcia', style: TextStyle(color: statusColor, fontWeight: FontWeight.w700)),
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
      child: Text(status.label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
    );
  }
}

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({required this.ticket, super.key});

  final TicketModel ticket;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szczegóły zgłoszenia')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              Expanded(child: Text(ticket.subject, style: Theme.of(context).textTheme.headlineSmall)),
              _StatusBadge(status: ticket.status, color: _statusColor(ticket.status)),
            ],
          ),
          const SizedBox(height: 12),
          Text('${ticket.category.emoji}  ${ticket.category.label}'),
          const SizedBox(height: 6),
          Text('Utworzono: ${DateFormat('dd.MM.yyyy, HH:mm').format(ticket.createdAt)}', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          _DetailBlock(title: 'Opis zgłoszenia', text: ticket.description),
          const SizedBox(height: 12),
          _DetailBlock(
            title: 'Informacje techniczne',
            text: ticket.deviceInfo.entries.map((entry) => '${entry.key}: ${entry.value}').join('\n'),
          ),
          if (ticket.adminResponse?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 12),
            _DetailBlock(title: 'Odpowiedź wsparcia', text: ticket.adminResponse!),
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
