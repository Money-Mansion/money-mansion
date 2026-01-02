import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/game_state.dart';
import '../models/transaction.dart';
import '../services/financial_database_service.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await FinancialDatabaseService.getAll();
    setState(() => _transactions.addAll(data));
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

  // ===== COIN LOGIC =====

  void _applyTransaction(TransactionModel t) {
    final int amount = t.amount.toInt();
    t.type == '+'
        ? widget.gameState.addCoins(amount)
        : widget.gameState.spendCoins(amount);
  }

  void _revertTransaction(TransactionModel t) {
    final int amount = t.amount.toInt();
    t.type == '+'
        ? widget.gameState.spendCoins(amount)
        : widget.gameState.addCoins(amount);
  }

  Future<void> _removeTransaction(TransactionModel t) async {
    _revertTransaction(t);
    await FinancialDatabaseService.delete(t.id);
    setState(() => _transactions.remove(t));
  }

  void _addTransaction() {
    _showTransactionDialog();
  }

  void _editTransaction(TransactionModel t) {
    _showTransactionDialog(transaction: t);
  }

  void _showTransactionDialog({TransactionModel? transaction}) {
    String type = transaction?.type ?? '+';
    final amountController =
    TextEditingController(text: transaction?.amount.toString() ?? '');
    final noteController =
    TextEditingController(text: transaction?.note ?? '');

    showDialog(
      context: context,
      builder: (context) {
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
                    items: const [
                      DropdownMenuItem(
                        value: '+',
                        child: Text('Gain (+)'),
                      ),
                      DropdownMenuItem(
                        value: '-',
                        child: Text('Purchase (-)'),
                      ),
                    ],
                    onChanged: (value) =>
                        dialogSetState(() => type = value!),
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
                  child: const Text('Cancel'),
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

                    Navigator.pop(context);
                  },
                  child: Text(transaction == null ? 'Add' : 'Save'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Financial Management'),
              Tab(text: 'Statistics'),
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
        onPressed: _addTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFinancialTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ..._transactions.map((t) {
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
                subtitle: Text(_formatDate(t.date)),
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
