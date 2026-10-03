import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';

/// Ekran obliczający rekomendowaną dzienną dawkę nawozu.
class FertilizerScreen extends StatefulWidget {
  const FertilizerScreen({super.key});

  @override
  State<FertilizerScreen> createState() => _FertilizerScreenState();
}

class _FertilizerScreenState extends State<FertilizerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pojemnoscController = TextEditingController(text: '100');

  String _wybranyNawoz = 'micro';
  double? _rekomendowanaDawka;

  @override
  void dispose() {
    _pojemnoscController.dispose();
    super.dispose();
  }

  void _obliczDawke() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Zamiana przecinka pozwala wpisać litraż także w polskim formacie.
    final pojemnosc = double.parse(
      _pojemnoscController.text.trim().replaceAll(',', '.'),
    );

    setState(() {
      _rekomendowanaDawka = pojemnosc * 0.1;
    });
  }

  String? _sprawdzPojemnosc(String? wartosc) {
    if (wartosc == null || wartosc.trim().isEmpty) {
      return AppLocalizations.of(context)!.enterAquariumVolume;
    }

    final pojemnosc = double.tryParse(wartosc.trim().replaceAll(',', '.'));
    if (pojemnosc == null || pojemnosc <= 0) {
      return AppLocalizations.of(context)!.enterPositiveNumber;
    }

    return null;
  }

  String _formatujDawke(double dawka) {
    if (dawka == dawka.roundToDouble()) {
      return dawka.toStringAsFixed(0);
    }
    return dawka.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        // Przycisk powrotu prowadzi do poprzedniego ekranu.
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: l10n.back,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(l10n.fertilizerCalculatorTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.calculateDoseAction,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.fertilizerDoseInstructions,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    // Pole z domyślną pojemnością akwarium.
                    TextFormField(
                      controller: _pojemnoscController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      validator: _sprawdzPojemnosc,
                      decoration: InputDecoration(
                        labelText: l10n.aquariumCapacityLabel,
                        hintText: l10n.fertilizerVolumeExample,
                        suffixText: l10n.litersUnit,
                        prefixIcon: Icon(Icons.water_drop_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Menu pozwala wskazać rodzaj używanego nawozu.
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.fertilizerTypeLabel,
                        prefixIcon: Icon(Icons.eco_outlined),
                        border: OutlineInputBorder(),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _wybranyNawoz,
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(
                              value: 'micro',
                              child: Text(l10n.fertilizerMicro),
                            ),
                            DropdownMenuItem(
                              value: 'npk',
                              child: Text(l10n.fertilizerMacroNpk),
                            ),
                            DropdownMenuItem(
                              value: 'potassium',
                              child: Text(l10n.fertilizerPotassium),
                            ),
                          ],
                          onChanged: (wartosc) {
                            if (wartosc == null) {
                              return;
                            }
                            setState(() {
                              _wybranyNawoz = wartosc;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Przycisk uruchamia obliczenia dla podanego litrażu.
                    FilledButton.icon(
                      onPressed: _obliczDawke,
                      icon: const Icon(Icons.calculate_outlined),
                      label: Text(l10n.calculateDoseAction),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    if (_rekomendowanaDawka != null) ...[
                      const SizedBox(height: 24),
                      // Karta wyniku jest widoczna dopiero po obliczeniu dawki.
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.teal.shade700,
                                size: 30,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${l10n.dailyDose}:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${_formatujDawke(_rekomendowanaDawka!)} ml',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Colors.teal.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(switch (_wybranyNawoz) {
                                      'npk' => l10n.fertilizerMacroNpk,
                                      'potassium' => l10n.fertilizerPotassium,
                                      _ => l10n.fertilizerMicro,
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
