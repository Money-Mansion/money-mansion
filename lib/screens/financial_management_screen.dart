import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/game_state.dart';
import '../models/transaction.dart';
import '../services/financial_database_service.dart';
import '../services/goal_allocation_service.dart';
import '../services/goal_database_service.dart';
import '../services/app_localizations_provider.dart';
import '../services/tutorial_provider.dart';
import '../widgets/tutorial_target.dart';

enum ChartPeriod { oneMonth, threeMonths, sixMonths, oneYear, custom }

@visibleForTesting
DateTime subtractChartMonths(DateTime date, int months) {
  final targetMonth = DateTime(date.year, date.month - months, 1);
  final lastDay = DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
  final day = date.day > lastDay ? lastDay : date.day;
  return DateTime(targetMonth.year, targetMonth.month, day);
}

@visibleForTesting
List<double> buildFinancialChartDailyData({
  required List<TransactionModel> transactions,
  required DateTimeRange range,
}) {
  if (transactions.isEmpty) return const [];

  final dailyChanges = List<double>.filled(
    range.end.difference(range.start).inDays + 1,
    0,
  );
  var balanceBeforeRange = 0.0;

  for (final transaction in transactions) {
    final transactionDate = DateTime(
      transaction.date.year,
      transaction.date.month,
      transaction.date.day,
    );
    final amount =
        transaction.type == '+' ? transaction.amount : -transaction.amount;
    if (transactionDate.isBefore(range.start)) {
      balanceBeforeRange += amount;
    } else if (!transactionDate.isAfter(range.end)) {
      final dayIndex = transactionDate.difference(range.start).inDays;
      dailyChanges[dayIndex] += amount;
    }
  }

  var runningBalance = balanceBeforeRange;
  for (var i = 0; i < dailyChanges.length; i++) {
    runningBalance += dailyChanges[i];
    dailyChanges[i] = runningBalance;
  }

  return dailyChanges;
}

class FinancialManagementScreen extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onBack;

  const FinancialManagementScreen({
    super.key,
    required this.gameState,
    required this.onBack,
  });

  @override
  State<FinancialManagementScreen> createState() =>
      _FinancialManagementScreenState();
}

class _FinancialManagementScreenState extends State<FinancialManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  late DateTime _selectedMonth;
  ChartPeriod _selectedChartPeriod = ChartPeriod.oneMonth;
  DateTimeRange? _customChartRange;
  final ValueNotifier<int?> _touchedChartIndex = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    final transactions = await FinancialDatabaseService.getAll();
    final goals = await GoalDatabaseService.getAllGoals();

    if (!mounted) return;
    setState(() {
      _transactions
        ..clear()
        ..addAll(transactions);
      widget.gameState.goals
        ..clear()
        ..addAll(goals);
      _isLoading = false;
    });

    await _recalculateMoneyAndAllocations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _touchedChartIndex.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  String _formatAmount(double amount) {
    final rounded = (amount * 100).round() / 100;
    return rounded % 1 == 0
        ? "${rounded.toInt()} €"
        : "${rounded.toStringAsFixed(2)} €";
  }

  Future<void> _recalculateMoneyAndAllocations() async {
    await GoalAllocationService.recalculate(widget.gameState);
    setState(() {});
  }

  // ===== MONEY LOGIC =====

  void _applyTransaction(TransactionModel t) {
    // All transactions now directly affect balance (no goalId)
    final double amount = t.amount;
    t.type == '+'
        ? widget.gameState.addMoney(amount)
        : widget.gameState.spendMoney(amount);
  }

  void _revertTransaction(TransactionModel t) {
    // All transactions now directly affect balance (no goalId)
    final double amount = t.amount;
    t.type == '+'
        ? widget.gameState.spendMoney(amount)
        : widget.gameState.addMoney(amount);
  }

  Future<void> _removeTransaction(TransactionModel t) async {
    // Prevent deletion of goal-completion transactions
    if (t.note.startsWith('Completed goal:')) {
      final l10n = context.read<AppLocalizationsProvider>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('cannotDeleteGoalTransaction')),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    _revertTransaction(t);
    await FinancialDatabaseService.delete(t.id);
    setState(() => _transactions.remove(t));
    await _recalculateMoneyAndAllocations();
  }

  void _addTransaction() {
    context.read<TutorialProvider>().registerAction('add_transaction');
    _showTransactionDialog();
  }

  void _editTransaction(TransactionModel t) {
    _showTransactionDialog(transaction: t);
  }

  void _showTransactionDialog({TransactionModel? transaction}) {
    String type = transaction?.type ?? '+';
    final amountController =
        TextEditingController(text: transaction?.amount.toString() ?? '');
    final noteController = TextEditingController(text: transaction?.note ?? '');

    showDialog(
      context: context,
      builder: (context) {
        final l10n = Provider.of<AppLocalizationsProvider>(context);
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: Text(
                transaction == null
                    ? l10n.translate('addGainOrPurchase')
                    : l10n.translate('editTransaction'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: type,
                    items: [
                      DropdownMenuItem(
                        value: '+',
                        child: Text('${l10n.translate('gain')} (+)'),
                      ),
                      DropdownMenuItem(
                        value: '-',
                        child: Text('${l10n.translate('purchase')} (-)'),
                      ),
                    ],
                    onChanged: (value) => dialogSetState(() {
                      type = value!;
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    decoration:
                        InputDecoration(labelText: l10n.translate('amount')),
                  ),
                  TextField(
                    controller: noteController,
                    maxLength: 150,
                    maxLines: 2,
                    decoration:
                        InputDecoration(labelText: l10n.translate('note')),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.translate('cancel')),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final double amount =
                        double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0) return;

                    // Calculate free balance (balance - allocated amounts)
                    final totalAllocated = widget.gameState.goals
                        .fold<double>(0, (sum, g) => sum + g.allocatedMoney);
                    final freeBalance = widget.gameState.money - totalAllocated;

                    // For expenses, check if user has enough free balance
                    if (type == '-' && freeBalance < amount) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.translate('notEnoughMoney')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                      return;
                    }

                    // 🔥 revert old transaction if editing
                    if (transaction != null) {
                      _revertTransaction(transaction);
                    }

                    final newTransaction = TransactionModel(
                      id: transaction?.id ?? const Uuid().v4(),
                      type: type,
                      amount: amount,
                      note: noteController.text,
                      date: DateTime.now(),
                    );

                    // 🔥 apply new transaction
                    _applyTransaction(newTransaction);

                    if (transaction == null) {
                      await FinancialDatabaseService.insert(newTransaction);
                      setState(() => _transactions.insert(0, newTransaction));
                    } else {
                      await FinancialDatabaseService.update(newTransaction);
                      setState(() {
                        final index = _transactions.indexOf(transaction);
                        _transactions[index] = newTransaction;
                      });
                    }

                    await _recalculateMoneyAndAllocations();
                    Navigator.pop(context);
                  },
                  child: Text(transaction == null
                      ? l10n.translate('add')
                      : l10n.translate('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('financial')),
        backgroundColor: Colors.green[600],
        leading: TutorialTarget(
          id: 'close_financial',
          child: IconButton(
            icon: const Icon(Icons.close),
            color: Colors.black,
            onPressed: widget.onBack,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.translate('refresh'),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.translate('total')),
              Tab(text: l10n.translate('income')),
              Tab(text: l10n.translate('expense')),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFinancialTab(l10n),
                _buildIncomeTab(l10n),
                _buildExpenseTab(l10n),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: TutorialTarget(
        id: 'add_transaction',
        child: FloatingActionButton(
          heroTag: null,
          onPressed: _addTransaction,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildIncomeTab(AppLocalizationsProvider l10n) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final incomeTransactions = _getTransactionsForMonth('+');
    final totalIncome =
        incomeTransactions.fold<double>(0, (sum, t) => sum + t.amount);

    return Column(
      children: [
        _buildMonthSelector(l10n),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    '${l10n.translate('total')}: ${_formatAmount(totalIncome)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                ..._buildTransactionList(incomeTransactions, l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseTab(AppLocalizationsProvider l10n) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final expenseTransactions = _getTransactionsForMonth('-');
    final totalExpense =
        expenseTransactions.fold<double>(0, (sum, t) => sum + t.amount);

    return Column(
      children: [
        _buildMonthSelector(l10n),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    '${l10n.translate('total')}: ${_formatAmount(totalExpense)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ),
                ..._buildTransactionList(expenseTransactions, l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTransactionList(
      List<TransactionModel> transactions, AppLocalizationsProvider l10n) {
    // All transactions are now simple income/expenses (no goal allocations)
    return transactions.map((t) {
      final subtitleText = _formatDate(t.date);
      final isGoalTransaction = t.note.startsWith('Completed goal:');

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          onLongPress: () => _editTransaction(t),
          leading: Icon(
            t.type == '+' ? Icons.add : Icons.remove,
            color: t.type == '+' ? Colors.green : Colors.red,
          ),
          trailing: isGoalTransaction
              ? Icon(
                  Icons.lock,
                  color: Colors.grey[500],
                  size: 20,
                )
              : IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeTransaction(t),
                ),
          title: Text(
            "${_formatAmount(t.amount)}   ${t.note}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(subtitleText),
        ),
      );
    }).toList();
  }

  List<Widget> _buildTransactionListGroupedByMonth(
      List<TransactionModel> transactions, AppLocalizationsProvider l10n) {
    if (transactions.isEmpty) {
      return [];
    }

    // Group transactions by month
    final Map<String, List<TransactionModel>> groupedByMonth = {};
    for (final t in transactions) {
      final monthKey =
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      groupedByMonth.putIfAbsent(monthKey, () => []);
      groupedByMonth[monthKey]!.add(t);
    }

    // Sort months in descending order (newest first)
    final sortedMonths = groupedByMonth.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Build widgets with month headers and transaction lists
    final monthNames = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december'
    ];

    final widgets = <Widget>[];
    for (final monthKey in sortedMonths) {
      final parts = monthKey.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      // Add month header
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Text(
            '${l10n.translate(monthNames[month - 1])} $year',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
      );

      // Calculate and display total for this month
      final monthTransactions = groupedByMonth[monthKey] ?? [];
      // All transactions are now simple income/expenses (no goal allocations)
      final monthTotal = monthTransactions.fold<double>(0, (sum, t) {
        final amount = t.type == '+' ? t.amount : -t.amount;
        return sum + amount;
      });

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '${l10n.translate('total')}: ${_formatAmount(monthTotal.abs())}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: monthTotal >= 0 ? Colors.green[600] : Colors.red[600],
            ),
          ),
        ),
      );

      // Add transactions for this month
      widgets.addAll(_buildTransactionList(monthTransactions, l10n));
    }

    return widgets;
  }

  Widget _buildFinancialTab(AppLocalizationsProvider l10n) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        Expanded(
          child: _buildMonthlyLineChart(l10n),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._buildTransactionListGroupedByMonth(_transactions, l10n),
                if (_transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Text(
                      l10n.translate('noTransactionsYet'),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyLineChart(AppLocalizationsProvider l10n) {
    final chartRange = _getChartDateRange();
    final dailyData = _getDailyData();
    if (dailyData.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                l10n.translate('noDataForMonth'),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
          _buildChartPeriodSelector(l10n),
        ],
      );
    }

    final spots = dailyData.length == 1
        ? [FlSpot(0, dailyData.first), FlSpot(1, dailyData.first)]
        : List.generate(
            dailyData.length,
            (index) => FlSpot(index.toDouble(), dailyData[index]),
          );
    final lowestValue = dailyData.reduce((a, b) => a < b ? a : b);
    final highestValue = dailyData.reduce((a, b) => a > b ? a : b);
    final valueRange = highestValue - lowestValue;
    final verticalPadding = valueRange == 0
        ? (highestValue.abs() * 0.1).clamp(1.0, double.infinity).toDouble()
        : valueRange * 0.12;
    final guideColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: ValueListenableBuilder<int?>(
              valueListenable: _touchedChartIndex,
              builder: (context, touchedValue, _) {
                final touchedIndex =
                    touchedValue?.clamp(0, dailyData.length - 1).toInt();
                final lineBarData = LineChartBarData(
                  spots: spots,
                  isCurved: false,
                  color: const Color(0xFF16A9E0),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  showingIndicators:
                      touchedIndex == null ? const [] : [touchedIndex],
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x4016A9E0), Color(0x0016A9E0)],
                    ),
                  ),
                );
                return LayoutBuilder(
                  builder: (context, constraints) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: (details) =>
                        _updateTouchedChartIndex(
                      details.localPosition.dx,
                      constraints.maxWidth,
                      dailyData.length,
                    ),
                    onHorizontalDragUpdate: (details) =>
                        _updateTouchedChartIndex(
                      details.localPosition.dx,
                      constraints.maxWidth,
                      dailyData.length,
                    ),
                    onHorizontalDragEnd: (_) => _clearTouchedChartIndex(),
                    onHorizontalDragCancel: _clearTouchedChartIndex,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: LineChart(
                            LineChartData(
                              minX: 0,
                              maxX: spots.last.x,
                              minY: lowestValue - verticalPadding,
                              maxY: highestValue + verticalPadding,
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineTouchData: LineTouchData(
                                enabled: false,
                                handleBuiltInTouches: false,
                                getTouchLineStart: (_, __) =>
                                    lowestValue - verticalPadding,
                                getTouchLineEnd: (_, __) =>
                                    highestValue + verticalPadding,
                                getTouchedSpotIndicator:
                                    (barData, spotIndexes) {
                                  return spotIndexes
                                      .map(
                                        (_) => TouchedSpotIndicatorData(
                                          FlLine(
                                            color: guideColor,
                                            strokeWidth: 1.5,
                                          ),
                                          const FlDotData(show: false),
                                        ),
                                      )
                                      .toList();
                                },
                              ),
                              lineBarsData: [lineBarData],
                            ),
                            duration: Duration.zero,
                          ),
                        ),
                        if (touchedIndex != null)
                          _buildChartTooltipOverlay(
                            chartSize: Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
                            index: touchedIndex,
                            values: dailyData,
                            range: chartRange,
                            minY: lowestValue - verticalPadding,
                            maxY: highestValue + verticalPadding,
                            l10n: l10n,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        _buildChartPeriodSelector(l10n),
      ],
    );
  }

  Widget _buildChartTooltipOverlay({
    required Size chartSize,
    required int index,
    required List<double> values,
    required DateTimeRange range,
    required double minY,
    required double maxY,
    required AppLocalizationsProvider l10n,
  }) {
    const tooltipWidth = 124.0;
    const tooltipHeight = 50.0;
    const pointGap = 10.0;

    final horizontalFraction =
        values.length <= 1 ? 0.5 : index / (values.length - 1);
    final pointX = horizontalFraction * chartSize.width;
    final valueRange = maxY - minY;
    final verticalFraction = valueRange == 0
        ? 0.5
        : ((values[index] - minY) / valueRange).clamp(0.0, 1.0);
    final pointY = chartSize.height * (1 - verticalFraction);

    final left = (pointX - tooltipWidth / 2)
        .clamp(0.0, chartSize.width - tooltipWidth)
        .toDouble();
    final preferredTop = pointY < chartSize.height / 2
        ? pointY + pointGap
        : pointY - tooltipHeight - pointGap;
    final top =
        preferredTop.clamp(0.0, chartSize.height - tooltipHeight).toDouble();
    final date = range.start.add(Duration(days: index));

    return Positioned(
      left: left,
      top: top,
      width: tooltipWidth,
      height: tooltipHeight,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                l10n.translate(
                  'chartTooltipDateValue',
                  replacements: {
                    'date': _formatChartDate(date, l10n),
                    'value': _formatAmount(values[index]),
                  },
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateTouchedChartIndex(
    double localX,
    double chartWidth,
    int dataLength,
  ) {
    if (chartWidth <= 0 || dataLength <= 0) return;
    final fraction = (localX / chartWidth).clamp(0.0, 1.0);
    final index = (fraction * (dataLength - 1)).round();
    if (_touchedChartIndex.value == index) return;
    _touchedChartIndex.value = index;
  }

  void _clearTouchedChartIndex() {
    if (_touchedChartIndex.value == null) return;
    _touchedChartIndex.value = null;
  }

  DateTimeRange _getChartDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_selectedChartPeriod) {
      case ChartPeriod.oneMonth:
        return DateTimeRange(start: subtractChartMonths(today, 1), end: today);
      case ChartPeriod.threeMonths:
        return DateTimeRange(start: subtractChartMonths(today, 3), end: today);
      case ChartPeriod.sixMonths:
        return DateTimeRange(start: subtractChartMonths(today, 6), end: today);
      case ChartPeriod.oneYear:
        return DateTimeRange(start: subtractChartMonths(today, 12), end: today);
      case ChartPeriod.custom:
        return _customChartRange ??
            DateTimeRange(start: subtractChartMonths(today, 1), end: today);
    }
  }

  String _formatChartDate(
    DateTime date,
    AppLocalizationsProvider l10n,
  ) {
    if (l10n.currentLanguage == 'sk') {
      return '${date.day}. ${date.month}. ${date.year}';
    }
    return '${date.month}/${date.day}/${date.year}';
  }

  List<double> _getDailyData() {
    return buildFinancialChartDailyData(
      transactions: _transactions,
      range: _getChartDateRange(),
    );
  }

  Widget _buildMonthSelector(AppLocalizationsProvider l10n) {
    final monthNames = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _selectedMonth =
                    DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
              });
            },
          ),
          Expanded(
            child: Text(
              '${l10n.translate(monthNames[_selectedMonth.month - 1])} ${_selectedMonth.year}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                _selectedMonth =
                    DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
              });
            },
          ),
        ],
      ),
    );
  }

  List<TransactionModel> _getTransactionsForMonth(String type) {
    final monthStart = _selectedMonth;
    final monthEnd =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);

    return _transactions.where((t) {
      return t.type == type &&
          t.date.isAfter(monthStart) &&
          t.date.isBefore(monthEnd);
    }).toList();
  }

  Widget _buildChartPeriodSelector(AppLocalizationsProvider l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildPeriodButton(
            label: l10n.translate('chart1Month'),
            period: ChartPeriod.oneMonth,
          ),
          _buildPeriodButton(
            label: l10n.translate('chart3Months'),
            period: ChartPeriod.threeMonths,
          ),
          _buildPeriodButton(
            label: l10n.translate('chartHalfYear'),
            period: ChartPeriod.sixMonths,
          ),
          _buildPeriodButton(
            label: l10n.translate('chart1Year'),
            period: ChartPeriod.oneYear,
          ),
          _buildPeriodButton(
            label: l10n.translate('chartCustom'),
            period: ChartPeriod.custom,
            onPressed: _pickCustomChartRange,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton({
    required String label,
    required ChartPeriod period,
    VoidCallback? onPressed,
  }) {
    final isSelected = _selectedChartPeriod == period;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          key: ValueKey('chart_period_${period.name}'),
          color: isSelected
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPressed ??
                () {
                  setState(() => _selectedChartPeriod = period);
                },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickCustomChartRange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var firstDate = today;
    for (final transaction in _transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      if (date.isBefore(firstDate)) firstDate = date;
    }

    final initialRange = _customChartRange ??
        DateTimeRange(start: subtractChartMonths(today, 1), end: today);
    if (initialRange.start.isBefore(firstDate)) {
      firstDate = initialRange.start;
    }

    final selectedRange = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: today,
      currentDate: today,
      initialDateRange: initialRange,
      helpText: context
          .read<AppLocalizationsProvider>()
          .translate('chartCustomRange'),
    );
    if (selectedRange == null || !mounted) return;

    setState(() {
      _customChartRange = DateTimeRange(
        start: DateTime(
          selectedRange.start.year,
          selectedRange.start.month,
          selectedRange.start.day,
        ),
        end: DateTime(
          selectedRange.end.year,
          selectedRange.end.month,
          selectedRange.end.day,
        ),
      );
      _selectedChartPeriod = ChartPeriod.custom;
    });
  }
}
