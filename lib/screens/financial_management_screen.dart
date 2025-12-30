import 'package:flutter/material.dart';
import '../models/game_state.dart';

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
  final List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    if (amount % 1 == 0) {
      return "${amount.toInt()} €";
    }
    return "${amount.toString()} €";
  }
  void _removeTransaction(Map<String, dynamic> t) {
    setState(() => _transactions.remove(t));
  }

  void _addTransaction() {
    _showTransactionDialog();
  }

  void _editTransaction(Map<String, dynamic> t) {
    _showTransactionDialog(transaction: t);
  }

  void _showTransactionDialog({Map<String, dynamic>? transaction}) {
    String type = transaction?['type'] ?? '+';
    final amountController = TextEditingController(
      text: transaction?['amount']?.toString() ?? '',
    );
    final noteController = TextEditingController(
      text: transaction?['note'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: Text(transaction == null
                  ? 'Add Gain/Purchase'
                  : 'Edit Transaction'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: type,
                    items: const [
                      DropdownMenuItem(
                          value: '+', child: Text('Gain (+)')),
                      DropdownMenuItem(
                          value: '-', child: Text('Purchase (-)')),
                    ],
                    onChanged: (value) {
                      dialogSetState(() => type = value!);
                    },
                  ),
                  TextField(
                    controller: amountController,
                    decoration:
                    const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: 'Note'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount =
                        double.tryParse(amountController.text) ?? 0;

                    setState(() {
                      if (transaction == null) {
                        _transactions.insert(0, {
                          'type': type,
                          'amount': amount,
                          'note': noteController.text,
                          'date': DateTime.now(),
                        });
                      } else {
                        transaction['type'] = type;
                        transaction['amount'] = amount;
                        transaction['note'] = noteController.text;
                        transaction['date'] = DateTime.now();
                      }
                    });

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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Financial Management',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          ..._transactions.map((t) {
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                onLongPress: () => _editTransaction(t),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeTransaction(t),
                ),
                leading: Icon(
                  t['type'] == '+' ? Icons.add : Icons.remove,
                  color: t['type'] == '+' ? Colors.green : Colors.red,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_formatAmount(t['amount'])}     ${t['note']}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(t['date']),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          if (_transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: Center(
                child: Text(
                  'No transactions yet. Tap + to add one!',
                  style:
                  TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Statistics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your progress and achievements',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}