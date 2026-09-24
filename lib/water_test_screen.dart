import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/aquarium_model.dart' as models;
import 'models/water_standards.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test wody'),
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
                      'Parametry wody',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: const Color(0xFF123D39),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pomiar zostanie zapisany z aktualną datą i godziną.',
                    ),
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
                              return 'Wpisz wartość';
                            }
                            if (double.tryParse(
                                  value.trim().replaceAll(',', '.'),
                                ) ==
                                null) {
                              return 'Wpisz poprawną liczbę';
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
                      label: const Text('Zapisz pomiar'),
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final test = models.WaterTest(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: DateTime.now(),
      ph: _number('pH'),
      no3: _number('NO3'),
      po4: _number('PO4'),
      fe: _number('Fe'),
      kh: _number('KH'),
      gh: _number('GH'),
      temp: _number('Temperatura'),
    );

    context.read<models.AquariumProvider>().addWaterTest(test);
    Navigator.of(context).pop();
  }

  double _number(String key) {
    return double.parse(_controllers[key]!.text.trim().replaceAll(',', '.'));
  }

  InputDecoration _decoration(BuildContext context, String key) {
    final parameter = _parameterFor(key);
    final rawValue = double.tryParse(
      _controllers[key]!.text.trim().replaceAll(',', '.'),
    );
    final assessment = rawValue == null
        ? null
        : assessWaterValue(parameter, rawValue);
    final color = assessment == null
        ? null
        : assessment.status == WaterStatus.good
        ? Colors.green.shade700
        : assessment.status == WaterStatus.critical
        ? Colors.red.shade700
        : Colors.orange.shade800;

    return InputDecoration(
      labelText: key,
      prefixIcon: Icon(Icons.science_outlined, color: color),
      suffixIcon: assessment == null
          ? null
          : Tooltip(
              message: assessment.message,
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
