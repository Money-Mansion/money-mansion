import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/game_state.dart';
import '../models/goal.dart';
import '../models/transaction.dart';
import '../services/financial_database_service.dart';
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
  late TabController _tabController;
  final List<TransactionModel> _transactions = [];
  final List<Goal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    return amount % 1 == 0
        ? "${amount.toInt()} €"
        : "${amount.toString()} €";
  }

  String? _goalTitle(String? goalId) {
    if (goalId == null) return null;
    final match = _goals.where((g) => g.id == goalId);
    return match.isEmpty ? null : match.first.title;
  }

  Future<void> _recalculateMoneyAndAllocations() async {
    double total = 0.0;
    final Map<String, double> allocations = {};

    for (final t in _transactions) {
      final signed = t.type == '+' ? t.amount : -t.amount;
      total += signed;

      if (t.goalId != null) {
        allocations[t.goalId!] = (allocations[t.goalId!] ?? 0) + signed;
      }
    }

    widget.gameState.setMoney(total);

    bool updated = false;
    for (var i = 0; i < _goals.length; i++) {
      final goal = _goals[i];
      final allocated =
          (allocations[goal.id] ?? 0).clamp(0, double.infinity).toDouble();
      Goal updatedGoal = goal;

      if ((goal.allocatedMoney - allocated).abs() > 0.009) {
        updatedGoal = updatedGoal.copyWith(allocatedMoney: allocated);
        await GoalDatabaseService.updateGoal(updatedGoal);
        _goals[i] = updatedGoal;
        updated = true;
      }

      if (!updatedGoal.isCompleted &&
          updatedGoal.targetMoney > 0 &&
          allocated >= updatedGoal.targetMoney) {
        updatedGoal = updatedGoal.copyWith(isCompleted: true);
        await GoalDatabaseService.updateGoal(updatedGoal);
        _goals[i] = updatedGoal;
        widget.gameState.completeGoal(updatedGoal.id);
        updated = true;
      }
    }

    if (updated && mounted) {
      setState(() {});
    }
  }

  // ===== MONEY LOGIC =====

  void _applyTransaction(TransactionModel t) {
    final double amount = t.amount;
    t.type == '+'
        ? widget.gameState.addMoney(amount)
        : widget.gameState.spendMoney(amount);
  }

  void _revertTransaction(TransactionModel t) {
    final double amount = t.amount;
    t.type == '+'
        ? widget.gameState.spendMoney(amount)
        : widget.gameState.addMoney(amount);
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

  void _showTransactionDialog({TransactionModel? transaction}) {
    String type = transaction?.type ?? '+';
    String? goalId = transaction?.goalId;
    final amountController =
    TextEditingController(text: transaction?.amount.toString() ?? '');
    final noteController =
    TextEditingController(text: transaction?.note ?? '');

    showDialog(
      context: context,
      builder: (context) {
        final l10n = Provider.of<AppLocalizationsProvider>(context);
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: Text(
                transaction == null
                    ? 'Add Gain / Purchase'
                    : 'Edit Transaction',
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
                    onChanged: (value) =>
                        dialogSetState(() => type = value!),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: goalId,
                    decoration: const InputDecoration(
                      labelText: 'Allocate to Goal',
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.translate('noGoalAllocation')),
                      ),
                      ..._goals.map(
                        (goal) => DropdownMenuItem<String?>(
                          value: goal.id,
                          child: Text(goal.title),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        dialogSetState(() => goalId = value),
                  ),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration:
                    const InputDecoration(labelText: 'Amount'),
                  ),
                  TextField(
                    controller: noteController,
                    decoration:
                    const InputDecoration(labelText: 'Note'),
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
                      goalId: goalId,
                    );

                    // 🔥 apply new transaction
                    _applyTransaction(newTransaction);

                    if (transaction == null) {
                      await FinancialDatabaseService.insert(
                          newTransaction);
                      setState(() =>
                          _transactions.insert(0, newTransaction));
                    } else {
                      await FinancialDatabaseService.update(
                          newTransaction);
                      setState(() {
                        final index =
                        _transactions.indexOf(transaction);
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
              Tab(text: l10n.translate('financial')),
              Tab(text: l10n.translate('statistics')),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFinancialTab(),
                _buildStatisticsTab(),
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

  Widget _buildFinancialTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ..._transactions.map((t) {
            final goalTitle = _goalTitle(t.goalId);
            final subtitleText = goalTitle == null
                ? _formatDate(t.date)
                : "${_formatDate(t.date)} - Goal: $goalTitle";
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                onLongPress: () => _editTransaction(t),
                leading: Icon(
                  t.type == '+' ? Icons.add : Icons.remove,
                  color:
                  t.type == '+' ? Colors.green : Colors.red,
                ),
                trailing: IconButton(
                  icon:
                  const Icon(Icons.delete, color: Colors.red),
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
          }),
          if (_transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Text(
                'No transactions yet. Tap + to add one!',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return const Center(
      child: Icon(Icons.bar_chart, size: 64, color: Colors.grey),
    );
  }
}







