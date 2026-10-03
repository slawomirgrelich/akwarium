import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'models/aquarium_model.dart' as models;
import 'models/water_standards.dart';
import 'utils/water_assessment_localization.dart';

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
                            if (double.tryParse(
                                  value.trim().replaceAll(',', '.'),
                                ) ==
                                null) {
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.waterAtLeastOneParameter)));
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
    final parameter = _parameterFor(key);
    final rawValue = double.tryParse(
      _controllers[key]!.text.trim().replaceAll(',', '.'),
    );
    final assessment = rawValue == null
        ? null
        : assessWaterValue(parameter, rawValue);
    final l10n = AppLocalizations.of(context)!;
    final color = assessment == null
        ? null
        : assessment.status == WaterStatus.good
        ? Colors.green.shade700
        : assessment.status == WaterStatus.critical
        ? Colors.red.shade700
        : Colors.orange.shade800;

    return InputDecoration(
      labelText: key == 'Temperatura'
          ? AppLocalizations.of(context)!.temperature
          : key,
      prefixIcon: Icon(Icons.science_outlined, color: color),
      suffixIcon: assessment == null
          ? null
          : Tooltip(
              message: waterAssessmentMessage(l10n, assessment),
              child: Icon(
                assessment.status == WaterStatus.good
                    ? Icons.check_circle
                    : Icons.warning_amber_rounded,
                color: color,
              ),
            ),
      suffixText: key == 'Temperatura' ? '°C' : null,
      focusedBorder: color == null
          ? null
          : OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: color, width: 2),
            ),
    );
  }

  WaterParameter _parameterFor(String key) {
    switch (key) {
      case 'pH':
        return WaterParameter.ph;
      case 'NO3':
        return WaterParameter.no3;
      case 'PO4':
        return WaterParameter.po4;
      case 'Fe':
        return WaterParameter.fe;
      case 'KH':
        return WaterParameter.kh;
      case 'GH':
        return WaterParameter.gh;
      case 'Temperatura':
        return WaterParameter.temp;
      default:
        return WaterParameter.ph;
    }
  }
}
