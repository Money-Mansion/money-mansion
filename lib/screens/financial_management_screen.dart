import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/game_state.dart';
import '../models/goal.dart';
import '../models/transaction.dart';
import '../services/financial_database_service.dart';
import '../services/goal_allocation_service.dart';
import '../services/goal_database_service.dart';
import '../services/app_localizations_provider.dart';

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
  static const int _hardGoalMilestoneCount = 5;
  late TabController _tabController;
  final List<TransactionModel> _transactions = [];
  final List<Goal> _goals = [];
  bool _isLoading = true;
  late DateTime _selectedMonth;

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
      _goals
        ..clear()
        ..addAll(goals);
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
    return rounded % 1 == 0 ? "${rounded.toInt()} €" : "${rounded.toStringAsFixed(2)} €";
  }

  String? _goalTitle(String? goalId) {
    if (goalId == null) return null;
    final match = _goals.where((g) => g.id == goalId);
    return match.isEmpty ? null : match.first.title;
  }

  Goal? _findGoal(String? goalId) {
    if (goalId == null) return null;
    final match = _goals.where((g) => g.id == goalId);
    return match.isEmpty ? null : match.first;
  }

  bool _isGoalCompleted(String? goalId) {
    final goal = _findGoal(goalId);
    return goal?.isCompleted ?? false;
  }

  int _hardGoalRewardForMilestones(Goal goal, int milestoneCount) {
    final clamped = milestoneCount.clamp(0, _hardGoalMilestoneCount);
    return (goal.rewardCoins * clamped) ~/ _hardGoalMilestoneCount;
  }

  Future<void> _recalculateMoneyAndAllocations() async {
    await GoalAllocationService.recalculate(widget.gameState);
    setState(() {});
  }

  // ===== MONEY LOGIC =====

  void _applyTransaction(TransactionModel t) {
    final double amount = t.amount;
    if (t.goalId == null) {
      t.type == '+'
          ? widget.gameState.addMoney(amount)
          : widget.gameState.spendMoney(amount);
    }
  }

  void _revertTransaction(TransactionModel t) {
    final double amount = t.amount;
    if (t.goalId == null) {
      t.type == '+'
          ? widget.gameState.spendMoney(amount)
          : widget.gameState.addMoney(amount);
    }
  }

  Future<void> _removeTransaction(TransactionModel t) async {
    _revertTransaction(t);
    await FinancialDatabaseService.delete(t.id);
    setState(() => _transactions.remove(t));
    await _recalculateMoneyAndAllocations();
  }

  void _addTransaction() {
    _showTransactionDialog();
  }

  void _editTransaction(TransactionModel t) {
    _showTransactionDialog(transaction: t);
  }

  Future<void> _showReassignFundsDialog() async {
    String? fromGoalId;
    String? toGoalId;
    final amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        final l10n = Provider.of<AppLocalizationsProvider>(context);
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            final sourceGoals = _goals
                .where((g) => !g.isCompleted && g.allocatedMoney > 0)
                .toList();
            final destinationGoals = _goals
                .where((g) => !g.isCompleted && g.id != fromGoalId)
                .toList();

            return AlertDialog(
              title: const Text('Reassign Funds'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: fromGoalId,
                    decoration: const InputDecoration(
                      labelText: 'From goal',
                    ),
                    items: sourceGoals
                        .map(
                          (goal) => DropdownMenuItem<String>(
                            value: goal.id,
                            child: Text(
                              '${goal.title} (${_formatAmount(goal.allocatedMoney)})',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      dialogSetState(() {
                        fromGoalId = value;
                        if (toGoalId == fromGoalId) {
                          toGoalId = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: toGoalId,
                    decoration: const InputDecoration(
                      labelText: 'To goal',
                    ),
                    items: destinationGoals
                        .map(
                          (goal) => DropdownMenuItem<String>(
                            value: goal.id,
                            child: Text(goal.title),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        dialogSetState(() => toGoalId = value),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (fromGoalId == null || toGoalId == null) return;
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0) return;
                    if (_isGoalCompleted(toGoalId)) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.translate('completedGoalsCannotAccept'),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                      return;
                    }

                    final fromGoal = _findGoal(fromGoalId);
                    if (fromGoal == null || amount > fromGoal.allocatedMoney) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text(l10n.translate('amountExceedsGoalFunds')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                      return;
                    }

                    final debitTx = TransactionModel(
                      id: const Uuid().v4(),
                      type: '-',
                      amount: amount,
                      note: l10n.translate('reassignedToAnother'),
                      date: DateTime.now(),
                      goalId: fromGoalId,
                    );
                    final creditTx = TransactionModel(
                      id: const Uuid().v4(),
                      type: '+',
                      amount: amount,
                      note: l10n.translate('reassignedFromAnother'),
                      date: DateTime.now(),
                      goalId: toGoalId,
                    );

                    // Do not surface reassign transactions in the list; just persist and recalc
                    await FinancialDatabaseService.insert(debitTx);
                    await FinancialDatabaseService.insert(creditTx);
                    await _recalculateMoneyAndAllocations();

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(l10n.translate('fundsReassignedSuccess')),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Text(l10n.translate('reassignMove')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static const List<String> _categories = [
    'categoryAuto',
    'categoryRestaurants',
    'categoryHealth',
    'categorySupermarket',
    'categoryLeisure',
    'categoryOther',
    'categoryUnassigned',
    'categoryPocketMoney',
  ];

  void _showTransactionDialog({TransactionModel? transaction}) {
    String type = transaction?.type ?? '+';
    String? category = transaction?.category;
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
                  DropdownButtonFormField<String?>(
                    value: category,
                    decoration: InputDecoration(
                      labelText: l10n.translate('category'),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.translate('categoryUnassigned')),
                      ),
                      ..._categories.map(
                        (cat) => DropdownMenuItem<String?>(
                          value: cat,
                          child: Text(l10n.translate(cat)),
                        ),
                      ),
                    ],
                    onChanged: (value) => dialogSetState(() => category = value),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.translate('amount')),
                  ),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(labelText: l10n.translate('note')),
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
                      goalId: null,
                      category: category,
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
                  child: Text(transaction == null ? l10n.translate('add') : l10n.translate('save')),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
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
              Tab(text: l10n.translate('income')),
              Tab(text: l10n.translate('expense')),
              Tab(text: l10n.translate('total')),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIncomeTab(l10n),
                _buildExpenseTab(l10n),
                _buildFinancialTab(l10n),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: _addTransaction,
        child: const Icon(Icons.add),
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

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildMonthSelector(l10n),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ..._buildTransactionList(incomeTransactions, l10n),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildCategoryPieChart(incomeTransactions, l10n),
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

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildMonthSelector(l10n),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ..._buildTransactionList(expenseTransactions, l10n),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildCategoryPieChart(expenseTransactions, l10n),
        ),
      ],
    );
  }

  List<Widget> _buildTransactionList(List<TransactionModel> transactions, AppLocalizationsProvider l10n) {
    return transactions.map((t) {
      final goalTitle = _goalTitle(t.goalId);
      final categoryTitle = t.category != null ? l10n.translate(t.category!) : null;
      final subtitleParts = [_formatDate(t.date)];
      if (goalTitle != null) {
        subtitleParts.add('Goal: $goalTitle');
      }
      if (categoryTitle != null) {
        subtitleParts.add('${l10n.translate('category')}: $categoryTitle');
      }
      final subtitleText = subtitleParts.join(' · ');

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          onLongPress: () => _editTransaction(t),
          leading: Icon(
            t.type == '+' ? Icons.add : Icons.remove,
            color: t.type == '+' ? Colors.green : Colors.red,
          ),
          trailing: IconButton(
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

  List<Widget> _buildTransactionListGroupedByMonth(List<TransactionModel> transactions, AppLocalizationsProvider l10n) {
    if (transactions.isEmpty) {
      return [];
    }

    // Group transactions by month
    final Map<String, List<TransactionModel>> groupedByMonth = {};
    for (final t in transactions) {
      final monthKey = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      groupedByMonth.putIfAbsent(monthKey, () => []);
      groupedByMonth[monthKey]!.add(t);
    }

    // Sort months in descending order (newest first)
    final sortedMonths = groupedByMonth.keys.toList()..sort((a, b) => b.compareTo(a));

    // Build widgets with month headers and transaction lists
    final monthNames = [
      'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december'
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

      // Add transactions for this month
      final monthTransactions = groupedByMonth[monthKey] ?? [];
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

    return Row(
      children: [
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
        Expanded(
          child: _buildMonthlyLineChart(l10n),
        ),
      ],
    );
  }

  Widget _buildCategoryPieChart(List<TransactionModel> transactions, AppLocalizationsProvider l10n) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          l10n.translate('noDataForMonth'),
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    // Group by category
    final Map<String, double> categoryTotals = {};
    for (final t in transactions) {
      final category = t.category ?? 'categoryUnassigned';
      categoryTotals[category] = (categoryTotals[category] ?? 0) + t.amount;
    }

    // Create pie chart sections
    final entries = categoryTotals.entries.toList();
    final sections = entries.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value.key;
      final amount = entry.value.value;
      final percentage = (amount / categoryTotals.values.fold(0.0, (a, b) => a + b)) * 100;

      return PieChartSectionData(
        color: _getCategoryColor(index),
        value: amount,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: categoryTotals.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value.key;
                  final amount = entry.value.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(index),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.translate(category),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatAmount(amount),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyLineChart(AppLocalizationsProvider l10n) {
    // Get monthly data for last 12 months
    final monthlyData = _getMonthlyData();
    if (monthlyData.isEmpty) {
      return Center(
        child: Text(
          l10n.translate('noDataForMonth'),
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    // Create line chart spots
    final spots = monthlyData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    return Padding(
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
                  if (index < 0 || index >= monthlyData.length) {
                    return const SizedBox.shrink();
                  }
                  final now = DateTime.now();
                  final month = DateTime(now.year, now.month - (monthlyData.length - 1 - index), 1);
                  return Text(
                    '${month.month}/${month.year.toString().substring(2)}',
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
                    _formatAmount(value),
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
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
          minY: monthlyData.reduce((a, b) => a < b ? a : b) * 0.9,
          maxY: monthlyData.reduce((a, b) => a > b ? a : b) * 1.1,
        ),
      ),
    );
  }

  List<double> _getMonthlyData() {
    final now = DateTime.now();
    final monthlyTotals = <double>[];

    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthStart = DateTime(date.year, date.month, 1);
      final monthEnd = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

      double monthTotal = 0;
      for (final t in _transactions) {
        if (t.date.isAfter(monthStart) && t.date.isBefore(monthEnd)) {
          final amount = t.type == '+' ? t.amount : -t.amount;
          monthTotal += amount;
        }
      }
      monthlyTotals.add(monthTotal);
    }

    return monthlyTotals;
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }

  Widget _buildMonthSelector(AppLocalizationsProvider l10n) {
    final monthNames = [
      'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december'
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
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
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
              });
            },
          ),
        ],
      ),
    );
  }

  List<TransactionModel> _getTransactionsForMonth(String type) {
    final monthStart = _selectedMonth;
    final monthEnd = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);
    
    return _transactions.where((t) {
      return t.type == type && t.date.isAfter(monthStart) && t.date.isBefore(monthEnd);
    }).toList();
  }

}
