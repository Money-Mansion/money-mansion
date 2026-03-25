import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/game_state.dart';
import '../models/goal.dart';
import '../models/transaction.dart';
import '../services/app_localizations_provider.dart';
import '../services/financial_database_service.dart';
import '../services/goal_database_service.dart';

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
    return amount % 1 == 0 ? "${amount.toInt()} EUR" : "$amount EUR";
  }

  String _tr(AppLocalizationsProvider l10n, String key) {
    return l10n.translate(key);
  }

  String? _goalTitle(String? goalId) {
    if (goalId == null) return null;
    final match = _goals.where((g) => g.id == goalId);
    return match.isEmpty ? null : match.first.title;
  }



  void _applyTransaction(TransactionModel transaction) {
    final amount = transaction.amount;
    if (transaction.type == '+') {
      widget.gameState.addMoney(amount);
    } else {
      widget.gameState.spendMoney(amount);
    }
  }

  void _revertTransaction(TransactionModel transaction) {
    final amount = transaction.amount;
    if (transaction.type == '+') {
      widget.gameState.spendMoney(amount);
    } else {
      widget.gameState.addMoney(amount);
    }
  }

  Future<void> _removeTransaction(TransactionModel transaction) async {
    _revertTransaction(transaction);
    await FinancialDatabaseService.delete(transaction.id);
    setState(() => _transactions.remove(transaction));
  }

  void _addTransaction() {
    _showTransactionDialog();
  }

  void _editTransaction(TransactionModel transaction) {
    _showTransactionDialog(transaction: transaction);
  }

  void _showTransactionDialog({TransactionModel? transaction}) {
    String type = transaction?.type ?? '+';
    final amountController = TextEditingController(
      text: transaction?.amount.toString() ?? '',
    );
    final noteController = TextEditingController(text: transaction?.note ?? '');

    showDialog(
      context: context,
      builder: (context) {
        final l10n = Provider.of<AppLocalizationsProvider>(context);
        return StatefulBuilder(
          builder: (context, dialogSetState) => AlertDialog(
            title: Text(
              transaction == null
                  ? _tr(l10n, 'addGainOrPurchase')
                  : _tr(l10n, 'editTransaction'),
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
                  onChanged: (value) => dialogSetState(() => type = value!),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: _tr(l10n, 'amount')),
                ),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(labelText: _tr(l10n, 'note')),
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
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount <= 0) return;

                  if (transaction != null) {
                    _revertTransaction(transaction);
                  }

                  final newTransaction = TransactionModel(
                    id: transaction?.id ?? const Uuid().v4(),
                    type: type,
                    amount: amount,
                    note: noteController.text,
                    date: DateTime.now(),
                    goalId: transaction?.goalId,
                  );

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

                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  transaction == null
                      ? l10n.translate('add')
                      : l10n.translate('save'),
                ),
              ),
            ],
          ),
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
    final l10n = context.watch<AppLocalizationsProvider>();
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ..._transactions.map((transaction) {
            final goalTitle = _goalTitle(transaction.goalId);
            final subtitleText = goalTitle == null
                ? _formatDate(transaction.date)
                : "${_formatDate(transaction.date)} - Goal: $goalTitle";
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                onLongPress: () => _editTransaction(transaction),
                leading: Icon(
                  transaction.type == '+' ? Icons.add : Icons.remove,
                  color: transaction.type == '+' ? Colors.green : Colors.red,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeTransaction(transaction),
                ),
                title: Text(
                  "${_formatAmount(transaction.amount)}   ${transaction.note}",
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
                _tr(l10n, 'noTransactionsYetTapAdd'),
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
