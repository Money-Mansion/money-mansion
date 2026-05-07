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

enum ChartPeriod { days30, days90, days180 }

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
  ChartPeriod _selectedChartPeriod = ChartPeriod.days180;

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
    t.type == '+' ? widget.gameState.addMoney(amount) : widget.gameState.spendMoney(amount);
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
    // Get daily data for selected period
    final dailyData = _getDailyData();
    if (dailyData.isEmpty) {
      return Column(
        children: [
          _buildChartPeriodSelector(l10n),
          Expanded(
            child: Center(
              child: Text(
                l10n.translate('noDataForMonth'),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      );
    }

    // Create line chart spots
    final spots = <FlSpot>[];
    for (int i = 0; i < dailyData.length; i++) {
      spots.add(FlSpot(i.toDouble(), dailyData[i]));
    }

    final startDate = _getChartStartDate();
    // Normalize start date to midnight
    final startDateNormalized =
        DateTime(startDate.year, startDate.month, startDate.day);
    final labelStep = _getLabelStep(dailyData.length);

    return Column(
      children: [
        _buildChartPeriodSelector(l10n),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 ||
                            index >= dailyData.length ||
                            index % labelStep != 0) {
                          return const SizedBox.shrink();
                        }
                        final date =
                            startDateNormalized.add(Duration(days: index));
                        return Text(
                          '${date.day}.${date.month}.',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatAmount(value.roundToDouble()),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                      reservedSize: 50,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    color: Colors.blue,
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                ],
                minY: dailyData.reduce((a, b) => a < b ? a : b) * 0.9,
                maxY: dailyData.reduce((a, b) => a > b ? a : b) * 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  DateTime _getChartStartDate() {
    final now = DateTime.now();
    switch (_selectedChartPeriod) {
      case ChartPeriod.days30:
        return now.subtract(const Duration(days: 30));
      case ChartPeriod.days90:
        return now.subtract(const Duration(days: 90));
      case ChartPeriod.days180:
        return now.subtract(const Duration(days: 180));
    }
  }

  int _getLabelStep(int totalDays) {
    if (totalDays <= 40) {
      return 5;
    } else if (totalDays <= 100) {
      return 10;
    } else {
      return 20;
    }
  }

  List<double> _getDailyData() {
    final now = DateTime.now();
    final startDate = _getChartStartDate();

    // Normalize dates to midnight to avoid time-based precision issues
    final startDateNormalized =
        DateTime(startDate.year, startDate.month, startDate.day);
    final nowNormalized = DateTime(now.year, now.month, now.day);

    // Calculate days between start date and now
    final daysDifference = nowNormalized.difference(startDateNormalized).inDays;
    final dailyTotals = List<double>.filled(daysDifference + 1, 0.0);

    // Populate daily totals - all transactions are simple income/expenses
    for (final t in _transactions) {
      final tDateNormalized = DateTime(t.date.year, t.date.month, t.date.day);
      if (tDateNormalized.isAfter(startDateNormalized) ||
          tDateNormalized.isAtSameMomentAs(startDateNormalized)) {
        if (tDateNormalized.isBefore(nowNormalized) ||
            tDateNormalized.isAtSameMomentAs(nowNormalized)) {
          final dayIndex =
              tDateNormalized.difference(startDateNormalized).inDays;
          if (dayIndex >= 0 && dayIndex < dailyTotals.length) {
            final amount = t.type == '+' ? t.amount : -t.amount;
            dailyTotals[dayIndex] += amount;
          }
        }
      }
    }

    // Convert daily totals to cumulative balance
    for (int i = 1; i < dailyTotals.length; i++) {
      dailyTotals[i] += dailyTotals[i - 1];
    }

    return dailyTotals;
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPeriodButton(
            label: l10n.translate('chart30Days'),
            period: ChartPeriod.days30,
            l10n: l10n,
          ),
          _buildPeriodButton(
            label: l10n.translate('chartQuarter'),
            period: ChartPeriod.days90,
            l10n: l10n,
          ),
          _buildPeriodButton(
            label: l10n.translate('chartHalfYear'),
            period: ChartPeriod.days180,
            l10n: l10n,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton({
    required String label,
    required ChartPeriod period,
    required AppLocalizationsProvider l10n,
  }) {
    final isSelected = _selectedChartPeriod == period;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: () {
        setState(() {
          _selectedChartPeriod = period;
        });
      },
      child: Text(label),
    );
  }
}
