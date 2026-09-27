import 'package:flutter/material.dart';

String formatCurrency(num value) {
  final negative = value < 0;
  final digits = value.abs().round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '${negative ? '-' : ''}¥$buffer';
}

String formatDate(DateTime date) =>
    '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

String formatMonth(DateTime date) => '${date.year}/${date.month.toString().padLeft(2, '0')}';

DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);
DateTime startOfNextMonth(DateTime date) => DateTime(date.year, date.month + 1);

Future<DateTime?> pickBusinessDate(BuildContext context, DateTime initial) =>
    showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
