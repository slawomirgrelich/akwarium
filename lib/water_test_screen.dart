import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'models/aquarium_model.dart' as models;

import 'package:akwarium/utils/app_snackbar.dart';

/// Formularz zapisu parametrów wody z dokładnym znacznikiem czasu.
class WaterTestScreen extends StatefulWidget {
  const WaterTestScreen({super.key});

  @override
  State<WaterTestScreen> createState() => _WaterTestScreenState();
}

class _WaterTestScreenState extends State<WaterTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{
    'pH': TextEditingController(),
    'NO3': TextEditingController(),
    'PO4': TextEditingController(),
    'Fe': TextEditingController(),
    'KH': TextEditingController(),
    'GH': TextEditingController(),
    'Temperatura': TextEditingController(),
  };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.waterTestTitle),
        leading: IconButton(
          tooltip: 'Wróć',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.waterParameters,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: const Color(0xFF123D39),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.waterTestInfo),
                    const SizedBox(height: 20),
                    ..._controllers.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: TextFormField(
                          controller: entry.value,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null;
                            }
                            final parsed = double.tryParse(
                              value.trim().replaceAll(',', '.'),
                            );
                            if (parsed == null || !parsed.isFinite) {
                              return l10n.chartInvalidNumber;
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                          decoration: _decoration(context, entry.key),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _saveTest,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(l10n.saveMeasurement),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveTest() {
    final l10n = AppLocalizations.of(context)!;
    if (_controllers.values.every(
      (controller) => controller.text.trim().isEmpty,
    )) {
      context.showAppSnackBar(
        SnackBar(content: Text(l10n.waterAtLeastOneParameter)),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final test = models.WaterTest(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      aquariumId: context.read<models.AquariumProvider>().activeAquariumId,
      date: DateTime.now(),
      ph: _optionalNumber('pH'),
      no3: _optionalNumber('NO3'),
      po4: _optionalNumber('PO4'),
      fe: _optionalNumber('Fe'),
      kh: _optionalNumber('KH'),
      gh: _optionalNumber('GH'),
      temp: _optionalNumber('Temperatura'),
    );

    context.read<models.AquariumProvider>().addWaterTest(test);
    Navigator.of(context).pop();
  }

  double? _optionalNumber(String key) {
    final value = _controllers[key]!.text.trim().replaceAll(',', '.');
    return value.isEmpty ? null : double.parse(value);
  }

  InputDecoration _decoration(BuildContext context, String key) {
    return InputDecoration(
      labelText: key == 'Temperatura'
          ? AppLocalizations.of(context)!.temperature
          : key,
      prefixIcon: const Icon(Icons.science_outlined),
      suffixText: key == 'Temperatura' ? '°C' : null,
    );
  }
}
