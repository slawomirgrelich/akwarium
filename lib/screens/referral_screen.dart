import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/referral_models.dart';
import '../services/referral_service.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ReferralService>();
    final completed = service.successfulReferralsCount;
    final progress = (completed / 3).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(title: const Text('Program poleceń')),
      body: RefreshIndicator(
        onRefresh: () => service.init(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Poleć 3 znajomym',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Oni dostają 50% zniżki na pierwszy miesiąc, a Ty zgarniasz darmowy miesiąc PRO.',
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Twój kod', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    SelectableText(
                      service.referralCode.isEmpty ? 'Ładowanie...' : service.referralCode,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: service.referralCode.isEmpty
                                ? null
                                : () async {
                                    await Clipboard.setData(ClipboardData(text: service.referralCode));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Kod skopiowany.')),
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.copy_outlined),
                            label: const Text('Kopiuj'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: service.referralCode.isEmpty
                                ? null
                                : () => SharePlus.instance.share(
                                      ShareParams(
                                        text: 'Dołącz do Akwarysta PRO z moim kodem ${service.referralCode}.',
                                      ),
                                    ),
                            icon: const Icon(Icons.share_outlined),
                            label: const Text('Udostępnij'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('$completed / 3 zaliczonych poleceń', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress, minHeight: 10),
            const SizedBox(height: 24),
            if (service.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(service.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            Text('Zaproszone osoby', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (service.referrals.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Nie masz jeszcze żadnych poleceń.'),
              )
            else
              ...service.referrals.map((referral) => _ReferralTile(referral: referral)),
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
    final completed = referral.status == ReferralStatus.completed;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        completed ? Icons.check_circle : Icons.schedule,
        color: completed ? Colors.green : Colors.orange,
      ),
      title: Text(completed ? 'Zaliczone' : 'Oczekuje na aktywację'),
      subtitle: Text(completed ? 'Polecenie aktywne' : 'Znajomy musi zweryfikować konto lub aktywować PRO'),
    );
  }
}
