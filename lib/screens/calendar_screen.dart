import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_localizations_provider.dart';

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
  }

  void _previousMonth() => setState(() {
        displayedMonth =
            DateTime(displayedMonth.year, displayedMonth.month - 1, 1);
      });

  void _nextMonth() => setState(() {
        displayedMonth =
            DateTime(displayedMonth.year, displayedMonth.month + 1, 1);
      });

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

                        return Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isToday ? _purple : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: isToday
                                ? null
                                : (isCurrentMonth
                                    ? Border.all(
                                        color: _purpleLight.withOpacity(0.3),
                                        width: 1)
                                    : null),
                          ),
                          child: Center(
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isToday
                                    ? Colors.white
                                    : isCurrentMonth
                                        ? _purple
                                        : _purpleLight.withOpacity(0.5),
                              ),
                            ),
                          ),
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