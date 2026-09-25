import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/pro_access_service.dart';

class ProBadge extends StatelessWidget {
  const ProBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (context.watch<ProAccessService>().isProUser) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.shade700,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'PRO',
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class ProPaywallDialog extends StatelessWidget {
  const ProPaywallDialog({this.headline, super.key});

  final String? headline;

  static Future<void> show(BuildContext context, {String? headline}) {
    return showDialog<void>(
      context: context,
      builder: (_) => ProPaywallDialog(headline: headline),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(headline ?? 'Odblokuj Pełny Potencjał Akwarysta PRO'),
          ),
          const SizedBox(width: 8),
          const ProBadge(),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spokojniejsza opieka nad akwarium dzięki funkcjom dla wymagających zbiorników.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 18),
            const _Benefit(
              icon: Icons.show_chart,
              text: 'Nielimitowane wykresy i historia parametrów',
            ),
            const _Benefit(
              icon: Icons.eco_outlined,
              text: 'Kalkulator nawożenia i receptury soli',
            ),
            const _Benefit(
              icon: Icons.notifications_active_outlined,
              text: 'Przypomnienia SMS i Push',
            ),
            const _Benefit(
              icon: Icons.picture_as_pdf_outlined,
              text: 'Eksport raportów do PDF',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Później'),
        ),
        FilledButton.icon(
          onPressed: () {
            context.read<ProAccessService>().enableProForDevelopment();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tryb PRO został odblokowany testowo.'),
              ),
            );
          },
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Wypróbuj PRO przez 7 dni za darmo'),
        ),
      ],
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal.shade700, size: 21),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
