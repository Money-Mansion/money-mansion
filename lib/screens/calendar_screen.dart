import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_localizations_provider.dart';
import '../models/calendar_day_data.dart';
import '../services/goal_database_service.dart';
import '../services/financial_database_service.dart';

class CalendarScreen extends StatefulWidget {
  final double date;

  const CalendarScreen({
    super.key,
    required this.date,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime currentDate;
  late DateTime displayedMonth;
  Map<DateTime, CalendarDayData> _monthData = {};

  // App colour palette
  static const _purple      = Color(0xFF6B5B8C);
  static const _purpleLight = Color(0xFFB8A8D8);
  static const _purpleBg    = Color(0xFFE8D4F0);
  static const _cream       = Color(0xFFFFFBF5);

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    displayedMonth = DateTime(currentDate.year, currentDate.month, 1);
    _fetchMonthData();
  }

  /// Fetch goals and transactions for the displayed month and index by date
  Future<void> _fetchMonthData() async {
    try {
      // Fetch goals and transactions in parallel
      final goals = await GoalDatabaseService.getAllGoals();
      final transactions = await FinancialDatabaseService.getAll();

      // Index by date (normalize to year/month/day only)
      final Map<DateTime, CalendarDayData> newData = {};

      // Add goals due within this month
      for (final goal in goals) {
        if (goal.dueDate.year == displayedMonth.year &&
            goal.dueDate.month == displayedMonth.month) {
          final dateKey = DateTime(goal.dueDate.year, goal.dueDate.month, goal.dueDate.day);
          if (!newData.containsKey(dateKey)) {
            newData[dateKey] = CalendarDayData(goalsToday: [], transactionsToday: []);
          }
          newData[dateKey]!.goalsToday.add(goal);
        }
      }

      // Add transactions within this month
      for (final transaction in transactions) {
        if (transaction.date.year == displayedMonth.year &&
            transaction.date.month == displayedMonth.month) {
          final dateKey = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
          if (!newData.containsKey(dateKey)) {
            newData[dateKey] = CalendarDayData(goalsToday: [], transactionsToday: []);
          }
          newData[dateKey]!.transactionsToday.add(transaction);
        }
      }

      if (mounted) {
        setState(() {
          _monthData = newData;
        });
      }
    } catch (e) {
      print('Error fetching calendar data: $e');
    }
  }

  void _previousMonth() {
    setState(() {
      displayedMonth = DateTime(displayedMonth.year, displayedMonth.month - 1, 1);
    });
    _fetchMonthData();
  }

  void _nextMonth() {
    setState(() {
      displayedMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 1);
    });
    _fetchMonthData();
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = firstDay.weekday;

    List<DateTime> days = [];
    for (int i = firstWeekday - 1; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }
    final remaining = 42 - days.length;
    for (int i = 1; i <= remaining; i++) {
      days.add(DateTime(month.year, month.month + 1, i));
    }
    return days;
  }

  String _getMonthName(int month, AppLocalizationsProvider l10n) {
    const keys = [
      'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december',
    ];
    return l10n.translate(keys[month - 1]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();
    final days = _getDaysInMonth(displayedMonth);
    final weekDays = [
      l10n.translate('monday'),
      l10n.translate('tuesday'),
      l10n.translate('wednesday'),
      l10n.translate('thursday'),
      l10n.translate('friday'),
      l10n.translate('saturday'),
      l10n.translate('sunday'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.translate('calendar'),
          style: const TextStyle(
            color: _purple,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _purpleBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: _purple),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ── Today banner ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _purpleBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _purpleLight, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.today_rounded, color: _purple, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    '${l10n.translate('todayLabel')}: '
                    '${_getMonthName(currentDate.month, l10n)} '
                    '${currentDate.day}, ${currentDate.year}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _purple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Calendar card ────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: _cream,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _purpleLight, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _purpleLight.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Month navigation header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 14),
                    decoration: const BoxDecoration(
                      color: _purpleBg,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _NavArrow(
                            icon: Icons.chevron_left,
                            onTap: _previousMonth),
                        Text(
                          '${_getMonthName(displayedMonth.month, l10n)} ${displayedMonth.year}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _purple,
                          ),
                        ),
                        _NavArrow(
                            icon: Icons.chevron_right,
                            onTap: _nextMonth),
                      ],
                    ),
                  ),

                  // Legend
                  _CalendarLegend(l10n: l10n),

                  const Divider(color: _purpleLight, thickness: 1, height: 1),

                  // Weekday headers
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                    child: GridView.count(
                      crossAxisCount: 7,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: weekDays
                          .map((d) => Center(
                                child: Text(
                                  d,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _purpleLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  const Divider(color: _purpleLight, thickness: 1, height: 1),

                  // Day grid
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: GridView.count(
                      crossAxisCount: 7,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.1,
                      children: days.map((day) {
                        final isCurrentMonth =
                            day.month == displayedMonth.month;
                        final isToday =
                            day.year == currentDate.year &&
                            day.month == currentDate.month &&
                            day.day == currentDate.day;
                        final dateKey = DateTime(day.year, day.month, day.day);
                        final dayData = _monthData[dateKey];

                        return _buildDateCell(
                          day: day,
                          isCurrentMonth: isCurrentMonth,
                          isToday: isToday,
                          dayData: dayData,
                          l10n: l10n,
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Builds an enhanced date cell with goal indicators and transaction summary
  Widget _buildDateCell({
    required DateTime day,
    required bool isCurrentMonth,
    required bool isToday,
    required CalendarDayData? dayData,
    required AppLocalizationsProvider l10n,
  }) {
    return GestureDetector(
      onTap: isCurrentMonth && dayData != null ? () => _showDayDetail(day, dayData, l10n) : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isToday ? _purple : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isToday
              ? null
              : (isCurrentMonth
                  ? Border.all(color: _purpleLight.withOpacity(0.3), width: 1)
                  : null),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top row: Date number + Goal indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date number
                  Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                      color: isToday
                          ? Colors.white
                          : isCurrentMonth
                              ? _purple
                              : _purpleLight.withOpacity(0.5),
                    ),
                  ),
                  // Goal indicators (compact, on the right)
                  if (dayData != null && dayData.goalsToday.isNotEmpty)
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...dayData.goalsToday.take(2).map((goal) {
                            final Color iconColor;
                            final IconData iconData;
                            if (goal.isCompleted) {
                              iconColor = Colors.green;
                              iconData = Icons.check_circle;
                            } else if (goal.dueDate.isBefore(DateTime.now())) {
                              iconColor = Colors.red;
                              iconData = Icons.cancel;
                            } else {
                              iconColor = Colors.orange;
                              iconData = Icons.radio_button_checked;
                            }
                            return Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Icon(iconData, color: iconColor, size: 8),
                            );
                          }).toList(),
                          if (dayData.goalsToday.length > 2)
                            Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Text(
                                '+${dayData.goalsToday.length - 2}',
                                style: const TextStyle(fontSize: 7, color: _purple),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              // Transaction summary - uses icons for mobile compatibility
              if (dayData != null && dayData.transactionsToday.isNotEmpty)
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (dayData.dailyIncome > 0) ...[
                        Icon(Icons.add_circle, color: Colors.green, size: 8),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            dayData.dailyIncome.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 6,
                              color: isToday ? Colors.white70 : Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      if (dayData.dailyIncome > 0 && dayData.dailyExpense > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Text(
                            '|',
                            style: TextStyle(
                              fontSize: 6,
                              color: isToday ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                        ),
                      if (dayData.dailyExpense > 0) ...[
                        Icon(Icons.remove_circle, color: Colors.red, size: 8),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            dayData.dailyExpense.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 6,
                              color: isToday ? Colors.white70 : Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows detailed modal for a single day
  void _showDayDetail(DateTime day, CalendarDayData dayData, AppLocalizationsProvider l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _DayDetailSheet(
        day: day,
        dayData: dayData,
        l10n: l10n,
      ),
    );
  }
}

// Small rounded arrow button
class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFB8A8D8).withOpacity(0.25),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color(0xFFB8A8D8), width: 1.5),
        ),
        child: Icon(icon, color: const Color(0xFF6B5B8C), size: 22),
      ),
    );
  }
}

// Legend showing goal status and transaction indicators
class _CalendarLegend extends StatelessWidget {
  static const _purple = Color(0xFF6B5B8C);
  final AppLocalizationsProvider l10n;

  const _CalendarLegend({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('legend'),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _purple),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _LegendItem(
                icon: Icons.check_circle,
                color: Colors.green,
                label: l10n.translate('completed'),
              ),
              _LegendItem(
                icon: Icons.cancel,
                color: Colors.red,
                label: l10n.translate('overdue'),
              ),
              _LegendItem(
                icon: Icons.radio_button_checked,
                color: Colors.orange,
                label: l10n.translate('upcoming'),
              ),
              _LegendItem(
                icon: Icons.attach_money,
                color: Colors.green,
                label: l10n.translate('income'),
              ),
              _LegendItem(
                icon: Icons.money_off,
                color: Colors.red,
                label: l10n.translate('expense'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _LegendItem({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

// Modal showing all goals and transactions for a selected day
class _DayDetailSheet extends StatelessWidget {
  final DateTime day;
  final CalendarDayData dayData;
  final AppLocalizationsProvider l10n;

  static const _purple = Color(0xFF6B5B8C);
  static const _purpleLight = Color(0xFFB8A8D8);
  static const _cream = Color(0xFFFFFBF5);

  const _DayDetailSheet({
    required this.day,
    required this.dayData,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _cream,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.translate('calendar')}: ${day.day}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _purple,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: _purple),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: _purpleLight, height: 1),

            // Goals section
            if (dayData.goalsToday.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${l10n.translate('goals')} (${dayData.goalsToday.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _purple,
                    ),
                  ),
                ),
              ),
              ...dayData.goalsToday.map((goal) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      goal.isCompleted
                          ? Icons.check_circle
                          : goal.dueDate.isBefore(DateTime.now())
                              ? Icons.cancel
                              : Icons.radio_button_checked,
                      color: goal.isCompleted
                          ? Colors.green
                          : goal.dueDate.isBefore(DateTime.now())
                              ? Colors.red
                              : Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            goal.isCompleted ? l10n.translate('completed') : l10n.translate('dueToday'),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              const Divider(color: _purpleLight, height: 12),
            ],

            // Transactions section
            if (dayData.transactionsToday.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${l10n.translate('transactions')} (${dayData.transactionsToday.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _purple,
                    ),
                  ),
                ),
              ),
              ...dayData.transactionsToday.map((tx) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      (tx.type ?? '') == '+' ? Icons.add_circle : Icons.remove_circle,
                      color: (tx.type ?? '') == '+' ? Colors.green : Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.note ?? 'Transaction',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${tx.type ?? ''}\$${(tx.amount ?? 0.0).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: (tx.type ?? '') == '+' ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              )),
              const Divider(color: _purpleLight, height: 12),
            ],

            // Summary
            if (dayData.transactionsToday.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _purpleLight),
                  ),
                  child: Column(
                    children: [
                      if (dayData.dailyIncome > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${l10n.translate('income')}:', style: const TextStyle(fontWeight: FontWeight.w500)),
                              Text(
                                '+\$${dayData.dailyIncome.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (dayData.dailyExpense > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${l10n.translate('expense')}:', style: const TextStyle(fontWeight: FontWeight.w500)),
                              Text(
                                '-\$${dayData.dailyExpense.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (dayData.dailyIncome > 0 || dayData.dailyExpense > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.translate('net'), style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '${dayData.dailyNet >= 0 ? '+' : ''}\$${dayData.dailyNet.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: dayData.dailyNet >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}