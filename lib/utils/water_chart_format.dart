import 'package:flutter/material.dart';

String formatWaterTooltipDateTime(BuildContext context, DateTime dateTime) {
  final localizations = MaterialLocalizations.of(context);
  return '${localizations.formatFullDate(dateTime)} · '
      '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(dateTime))}';
}

String formatWaterTooltipValue(double value, String unit) =>
    '${value.toString()}${unit.isEmpty ? '' : ' $unit'}';
