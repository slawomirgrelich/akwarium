import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/partner_model.dart';
import '../services/partners_service.dart';
import '../utils/app_snackbar.dart';

class PartnersScreen extends StatefulWidget {
  const PartnersScreen({super.key, this.partnersStream});

  final Stream<List<Partner>>? partnersStream;

  @override
  State<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen> {
  PartnerFilter _filter = PartnerFilter.all;
  late Stream<List<Partner>> _partnersStream;

  @override
  void initState() {
    super.initState();
    _resetStream();
  }

  void _resetStream() {
    _partnersStream =
        widget.partnersStream ?? PartnersService().watchActivePartners();
  }

  void _retry() {
    setState(_resetStream);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.partnersTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SegmentedButton<PartnerFilter>(
                  showSelectedIcon: false,
                  selected: {_filter},
                  onSelectionChanged: (selection) {
                    setState(() => _filter = selection.first);
                  },
                  segments: [
                    ButtonSegment(
                      value: PartnerFilter.all,
                      label: Text(l10n.partnersAll),
                    ),
                    ButtonSegment(
                      value: PartnerFilter.creators,
                      label: Text(l10n.partnersCreators),
                    ),
                    ButtonSegment(
                      value: PartnerFilter.shops,
                      label: Text(l10n.partnersShops),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Partner>>(
                  stream: _partnersStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      debugPrint('Partners stream error: ${snapshot.error}');
                      return _PartnersErrorState(onRetry: _retry);
                    }

                    final partners = filterPartners(
                      snapshot.data ?? const <Partner>[],
                      _filter,
                    );
                    if (partners.isEmpty) {
                      return const _PartnersEmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: partners.length,
                      itemBuilder: (context, index) {
                        return _PartnerCard(partner: partners[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({required this.partner});

  final Partner partner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: scheme.primary.withValues(alpha: 0.14),
                  foregroundColor: scheme.primary,
                  child: Icon(_iconFor(partner.category)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _categoryLabel(l10n, partner.category),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (partner.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          partner.subtitle,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(partner.description),
            if (partner.promoCode != null || partner.promoText != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.partnersPromo,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (partner.promoText case final promoText?) ...[
                      const SizedBox(height: 6),
                      Text(promoText),
                    ],
                    if (partner.promoCode case final promoCode?) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              promoCode,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _copyCode(context, promoCode),
                            icon: const Icon(Icons.copy_outlined, size: 18),
                            label: Text(l10n.copyPromoCode),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (partner.tipText case final tipText?) ...[
              const SizedBox(height: 10),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                leading: const Icon(Icons.tips_and_updates_outlined),
                title: Text(
                  l10n.partnersTip,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                children: [Text(tipText)],
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openPartner(context),
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.partnersOpenWebsite),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    context.showAppSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.promoCodeCopied)),
    );
  }

  Future<void> _openPartner(BuildContext context) async {
    final uri = Uri.tryParse(partner.url);
    final l10n = AppLocalizations.of(context)!;
    final isWebLink =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isWebLink) {
      context.showAppSnackBar(
        SnackBar(content: Text(l10n.partnersInvalidLink)),
      );
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      if (!context.mounted) return;
      context.showAppSnackBar(
        SnackBar(content: Text(l10n.partnersInvalidLink)),
      );
    }
  }
}

class _PartnersErrorState extends StatelessWidget {
  const _PartnersErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 52),
            const SizedBox(height: 12),
            Text(l10n.partnersLoadError, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartnersEmptyState extends StatelessWidget {
  const _PartnersEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.handshake_outlined, size: 56),
            const SizedBox(height: 12),
            Text(l10n.partnersEmpty, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

IconData _iconFor(PartnerCategory category) {
  return switch (category) {
    PartnerCategory.creator => Icons.play_circle_outline,
    PartnerCategory.shop => Icons.storefront_outlined,
    PartnerCategory.breeder => Icons.set_meal_outlined,
    PartnerCategory.unknown => Icons.handshake_outlined,
  };
}

String _categoryLabel(AppLocalizations l10n, PartnerCategory category) {
  return switch (category) {
    PartnerCategory.creator => l10n.partnerCreator,
    PartnerCategory.shop => l10n.partnerShop,
    PartnerCategory.breeder => l10n.partnerBreeder,
    PartnerCategory.unknown => l10n.partnersTitle,
  };
}
