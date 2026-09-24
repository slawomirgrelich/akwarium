import 'package:flutter/material.dart';

/// Ekran obliczający rekomendowaną dzienną dawkę nawozu.
class FertilizerScreen extends StatefulWidget {
  const FertilizerScreen({super.key});

  @override
  State<FertilizerScreen> createState() => _FertilizerScreenState();
}

class _FertilizerScreenState extends State<FertilizerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pojemnoscController = TextEditingController(text: '100');

  String _wybranyNawoz = 'Nawóz Mikro';
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
      return 'Wpisz pojemność akwarium';
    }

    final pojemnosc = double.tryParse(wartosc.trim().replaceAll(',', '.'));
    if (pojemnosc == null || pojemnosc <= 0) {
      return 'Wpisz liczbę większą od zera';
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
    return Scaffold(
      appBar: AppBar(
        // Przycisk powrotu prowadzi do poprzedniego ekranu.
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Wróć',
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Kalkulator nawożenia'),
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
                      'Oblicz dawkę nawozu',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Podaj pojemność akwarium i wybierz rodzaj nawozu.',
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
                      decoration: const InputDecoration(
                        labelText: 'Pojemność akwarium',
                        hintText: 'np. 100',
                        suffixText: 'litrów',
                        prefixIcon: Icon(Icons.water_drop_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Menu pozwala wskazać rodzaj używanego nawozu.
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Rodzaj nawozu',
                        prefixIcon: Icon(Icons.eco_outlined),
                        border: OutlineInputBorder(),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _wybranyNawoz,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'Nawóz Mikro',
                              child: Text('Nawóz Mikro'),
                            ),
                            DropdownMenuItem(
                              value: 'Nawóz Makro (NPK)',
                              child: Text('Nawóz Makro (NPK)'),
                            ),
                            DropdownMenuItem(
                              value: 'Potas (K)',
                              child: Text('Potas (K)'),
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
                      label: const Text('Oblicz dawkę'),
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
                                      'Rekomendowana dawka dzienna:',
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
                                    Text(_wybranyNawoz),
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
