import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
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

class ProPaywallDialog extends StatefulWidget {
  const ProPaywallDialog({this.headline, super.key});

  final String? headline;

  static Future<void> show(BuildContext context, {String? headline}) {
    return showDialog<void>(
      context: context,
      builder: (_) => ProPaywallDialog(headline: headline),
    );
  }

  @override
  State<ProPaywallDialog> createState() => _ProPaywallDialogState();
}

class _ProPaywallDialogState extends State<ProPaywallDialog> {
  bool _yearlyPlanSelected = true;
  bool _activating = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(widget.headline ?? l10n.unlockProHeadline)),
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
              l10n.proPaywallSubtitle,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 18),
            _Benefit(icon: Icons.show_chart, text: l10n.featureUnlimitedCharts),
            _Benefit(
              icon: Icons.water_drop_outlined,
              text: l10n.proBenefitUnlimitedAquariums,
            ),
            _Benefit(
              icon: Icons.auto_awesome,
              text: l10n.proBenefitAiScannerDiagnostics,
            ),
            _Benefit(
              icon: Icons.eco_outlined,
              text: l10n.featureFertilizerCalc,
            ),
            _Benefit(
              icon: Icons.notifications_active_outlined,
              text: l10n.featureReminders,
            ),
            _Benefit(
              icon: Icons.picture_as_pdf_outlined,
              text: l10n.featureExportPdf,
            ),
            _Benefit(
              icon: Icons.photo_library_outlined,
              text: l10n.proBenefitFullPhotoHistory,
            ),
            _Benefit(icon: Icons.block, text: l10n.proBenefitNoAds),
            const SizedBox(height: 8),
            _PlanTile(
              title: l10n.monthlyPlan,
              price: '9,99 zł / miesiąc',
              selected: !_yearlyPlanSelected,
              onTap: () => setState(() => _yearlyPlanSelected = false),
            ),
            const SizedBox(height: 8),
            _PlanTile(
              title: l10n.yearlyPlan,
              price: '69,99 zł / rok',
              badge: l10n.mostPopularBadge,
              selected: _yearlyPlanSelected,
              onTap: () => setState(() => _yearlyPlanSelected = true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.maybeLater),
        ),
        FilledButton.icon(
          onPressed: _activating ? null : _activatePro,
          icon: _activating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(_activating ? l10n.activatingEllipsis : l10n.tryPro),
        ),
      ],
    );
  }

  Future<void> _activatePro() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _activating = true);
    try {
      await context.read<ProAccessService>().setProUser(
        true,
        plan: _yearlyPlanSelected ? 'yearly' : 'monthly',
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.proActivatedMessage)),
      );
    } on Object catch (error) {
      if (mounted) {
        setState(() => _activating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.proActivationFailed(error.toString()))),
        );
      }
    }
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.title,
    required this.price,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String price;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(price),
                ],
              ),
            ),
            if (badge != null)
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
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
