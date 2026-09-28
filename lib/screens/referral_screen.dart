import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../models/referral_models.dart';
import '../services/referral_service.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  static const _shareUrl = 'https://akwarysta-pro.web.app/register';

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ReferralService>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.referralTitle)),
      body: RefreshIndicator(
        onRefresh: service.retry,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
          children: [
            const _ReferralHero(),
            const SizedBox(height: 16),
            if (service.isLoading && service.referralCode.isEmpty)
              const _ReferralLoadingState()
            else if (service.errorMessage != null && service.referralCode.isEmpty)
              _ReferralErrorState(onRetry: service.retry)
            else ...[
              _CodeCard(
                code: service.referralCode,
                shareUrl: _shareUrl,
                onCopied: () => _showMessage(context, AppLocalizations.of(context)!.codeCopied),
              ),
              const SizedBox(height: 16),
              _ProgressCard(completed: service.successfulReferralsCount),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.invitedUsers,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (service.referrals.isEmpty)
                const _EmptyReferralsState()
              else
                ...service.referrals.map((referral) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ReferralTile(referral: referral),
                    )),
              if (service.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextButton.icon(
                    onPressed: service.retry,
                    icon: const Icon(Icons.refresh),
                    label: Text(AppLocalizations.of(context)!.refreshReferrals),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ReferralHero extends StatelessWidget {
  const _ReferralHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF0B2630), Color(0xFF073B4C)]
              : [scheme.primaryContainer, scheme.secondaryContainer],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.card_giftcard_outlined, color: isDark ? const Color(0xFF67E8F9) : scheme.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.referralHeroTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : scheme.onPrimaryContainer,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.referralHeroDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? const Color(0xFFD2EEF2) : scheme.onSecondaryContainer,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.code, required this.shareUrl, required this.onCopied});

  final String code;
  final String shareUrl;
  final VoidCallback onCopied;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shareText = '${AppLocalizations.of(context)!.referralShareText(code)} $shareUrl?ref=$code';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context)!.referralCodeSection, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.primary.withValues(alpha: 0.5), width: 1.5),
              ),
              child: code.isEmpty
                  ? const Center(child: SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                  : SelectableText(
                      code,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: code.isEmpty
                        ? null
                        : () async {
                            await Clipboard.setData(ClipboardData(text: code));
                            onCopied();
                          },
                    icon: const Icon(Icons.copy_outlined),
                    label: Text(AppLocalizations.of(context)!.copyCode),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: code.isEmpty
                        ? null
                        : () => SharePlus.instance.share(ShareParams(text: shareText)),
                    icon: const Icon(Icons.ios_share_outlined),
                    label: Text(AppLocalizations.of(context)!.shareLink),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.completed});

  final int completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final value = (completed / 3).clamp(0.0, 1.0).toDouble();
    final reached = completed >= 3;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.referralProgress(completed),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                Icon(
                  reached ? Icons.workspace_premium : Icons.emoji_events_outlined,
                  color: reached ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                builder: (context, animatedValue, _) => LinearProgressIndicator(
                  value: animatedValue,
                  minHeight: 12,
                  backgroundColor: scheme.surfaceContainerHighest,
                  color: reached ? scheme.primary : scheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              reached ? AppLocalizations.of(context)!.referralGoalReached : AppLocalizations.of(context)!.referralProgressHint,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferralTile extends StatelessWidget {
  const _ReferralTile({required this.referral});

  final ReferralModel referral;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final completed = referral.status == ReferralStatus.completed;
    final color = completed ? Colors.green : Colors.orange;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.13),
          child: Icon(completed ? Icons.check : Icons.schedule, color: color),
        ),
        title: Text(
          completed ? AppLocalizations.of(context)!.activePro : AppLocalizations.of(context)!.referralAccepted,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          completed ? AppLocalizations.of(context)!.referralCompleted : AppLocalizations.of(context)!.awaitingProActivation,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        trailing: Text(_dateLabel(referral.createdAt), style: theme.textTheme.bodySmall),
      ),
    );
  }
}

class _EmptyReferralsState extends StatelessWidget {
  const _EmptyReferralsState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
        child: Column(
          children: [
            Icon(Icons.group_outlined, size: 48, color: scheme.primary.withValues(alpha: 0.75)),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.invitedUsers, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.noReferrals,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferralLoadingState extends StatelessWidget {
  const _ReferralLoadingState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          height: index == 0 ? 150 : 82,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
          ),
          child: index == 1 ? const Center(child: CircularProgressIndicator(strokeWidth: 2)) : null,
        ),
      ),
    );
  }
}

class _ReferralErrorState extends StatelessWidget {
  const _ReferralErrorState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.cloud_off_outlined, size: 44, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.referralLoadErrorTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(AppLocalizations.of(context)!.connectionRetry, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => onRetry(),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}

String _dateLabel(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}
