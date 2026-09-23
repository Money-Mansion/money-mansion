import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_mansion/models/transaction.dart';
import 'package:money_mansion/screens/financial_management_screen.dart';

void main() {
  group('subtractChartMonths', () {
    test('clamps month-end dates and handles leap years', () {
      expect(
        subtractChartMonths(DateTime(2024, 3, 31), 1),
        DateTime(2024, 2, 29),
      );
      expect(
        subtractChartMonths(DateTime(2025, 3, 31), 1),
        DateTime(2025, 2, 28),
      );
      expect(
        subtractChartMonths(DateTime(2025, 1, 31), 3),
        DateTime(2024, 10, 31),
      );
    });
  });

  group('buildFinancialChartDailyData', () {
    test('returns no points without transactions', () {
      final values = buildFinancialChartDailyData(
        transactions: const [],
        range: DateTimeRange(
          start: DateTime(2025, 2, 1),
          end: DateTime(2025, 2, 28),
        ),
      );

      expect(values, isEmpty);
    });

    test('carries older balances into an inclusive selected range', () {
      final values = buildFinancialChartDailyData(
        transactions: [
          _transaction('opening', '+', 100, DateTime(2025, 1, 5)),
          _transaction('expense', '-', 20, DateTime(2025, 2, 15, 18)),
          _transaction('income', '+', 50, DateTime(2025, 3, 1, 9)),
          _transaction('later', '+', 999, DateTime(2025, 3, 3)),
        ],
        range: DateTimeRange(
          start: DateTime(2025, 2, 1),
          end: DateTime(2025, 3, 2),
        ),
      );

      expect(values, hasLength(30));
      expect(values.first, 100);
      expect(values[14], 80);
      expect(values[28], 130);
      expect(values.last, 130);
    });

    test('keeps a flat carried balance when the range has no activity', () {
      final values = buildFinancialChartDailyData(
        transactions: [
          _transaction('opening', '+', 25, DateTime(2025, 1, 1)),
        ],
        range: DateTimeRange(
          start: DateTime(2025, 2, 10),
          end: DateTime(2025, 2, 10),
        ),
      );

      expect(values, [25]);
    });

    test('supports negative and zero running balances', () {
      final values = buildFinancialChartDailyData(
        transactions: [
          _transaction('expense', '-', 10, DateTime(2025, 2, 1)),
          _transaction('income', '+', 10, DateTime(2025, 2, 2)),
        ],
        range: DateTimeRange(
          start: DateTime(2025, 2, 1),
          end: DateTime(2025, 2, 3),
        ),
      );

      expect(values, [-10, 0, 0]);
    });
  });
}

TransactionModel _transaction(
  String id,
  String type,
  double amount,
  DateTime date,
) {
  return TransactionModel(
    id: id,
    type: type,
    amount: amount,
    note: '',
    date: date,
  );
}
