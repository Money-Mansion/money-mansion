import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/game_state.dart';
import '../models/goal.dart';
import '../models/transaction.dart';
import '../services/app_localizations_provider.dart';
import '../services/financial_database_service.dart';
import '../services/goal_database_service.dart';

class GoalsScreen extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onBack;

  const GoalsScreen({
    super.key,
    required this.gameState,
    required this.onBack,
  });

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  static const int _hardGoalMilestoneCount = 5;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetMoneyController;
  DateTime _selectedDate = DateTime.now();
  String _selectedDifficulty = Goal.easyDifficulty;
  bool _isLoading = true;
  bool _isSyncing = false;

  static const Map<String, int> _difficultyRewards = {
    Goal.easyDifficulty: 50,
    Goal.mediumDifficulty: 100,
    Goal.hardDifficulty: 200,
  };

  String _formatMoney(double money) {
    if (money % 1 == 0) {
      return money.toStringAsFixed(0);
    }
    return money.toStringAsFixed(2);
  }

  String _tr(AppLocalizationsProvider l10n, String key) {
    return l10n.translate(key);
  }

  String _trParams(
    AppLocalizationsProvider l10n,
    String key,
    Map<String, String> params,
  ) {
    var text = l10n.translate(key);
    params.forEach((paramKey, value) {
      text = text.replaceAll('{$paramKey}', value);
    });
    return text;
  }

  String _difficultyLabel(AppLocalizationsProvider l10n, String difficulty) {
    switch (difficulty) {
      case Goal.easyDifficulty:
        return _tr(l10n, 'difficultyEasy');
      case Goal.mediumDifficulty:
        return _tr(l10n, 'difficultyMedium');
      case Goal.hardDifficulty:
        return _tr(l10n, 'difficultyHard');
      default:
        return difficulty;
    }
  }

  int _hardGoalRewardForMilestones(Goal goal, int milestoneCount) {
    final clamped = milestoneCount.clamp(0, _hardGoalMilestoneCount);
    return (goal.rewardCoins * clamped) ~/ _hardGoalMilestoneCount;
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _targetMoneyController = TextEditingController(text: '0');
    _loadGoalsFromBackend();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetMoneyController.dispose();
    super.dispose();
  }

  Future<void> _loadGoalsFromBackend() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      final goals = await GoalDatabaseService.getAllGoals();

      if (!mounted) return;
      setState(() {
        widget.gameState.goals.clear();
        widget.gameState.goals.addAll(goals);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading goals: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load goals.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _applyGoalAllocation(Goal goal, double amount) async {
    if (amount <= 0 || amount > widget.gameState.money || goal.isCompleted) {
      return;
    }

    var updatedGoal = goal.copyWith(
      allocatedMoney: goal.allocatedMoney + amount,
    );
    var newlyEarnedCoins = 0;

    if (updatedGoal.difficulty == Goal.hardDifficulty &&
        updatedGoal.targetMoney > 0) {
      final progress = (updatedGoal.allocatedMoney / updatedGoal.targetMoney)
          .clamp(0.0, 1.0)
          .toDouble();
      final reachedMilestones = (progress * _hardGoalMilestoneCount).floor();
      if (reachedMilestones > updatedGoal.milestonesAwarded) {
        final newlyEarned = _hardGoalRewardForMilestones(
              updatedGoal,
              reachedMilestones,
            ) -
            _hardGoalRewardForMilestones(
              updatedGoal,
              updatedGoal.milestonesAwarded,
            );
        newlyEarnedCoins = newlyEarned;
        updatedGoal = updatedGoal.copyWith(
          milestonesAwarded: reachedMilestones,
        );
      }
    }

    final shouldComplete = !updatedGoal.isCompleted &&
        updatedGoal.targetMoney > 0 &&
        updatedGoal.allocatedMoney >= updatedGoal.targetMoney;
    final storedGoal =
        shouldComplete ? updatedGoal.copyWith(isCompleted: true) : updatedGoal;

    final success = await GoalDatabaseService.updateGoal(storedGoal);
    if (!success || !mounted) {
      return;
    }

    widget.gameState.spendMoney(amount);

    final l10n = context.read<AppLocalizationsProvider>();
    final transaction = TransactionModel(
      id: const Uuid().v4(),
      type: '-',
      amount: amount,
      note: _trParams(l10n, 'assignMoneyToGoal', {'goal': goal.title}),
      date: DateTime.now(),
      goalId: goal.id,
    );
    await FinancialDatabaseService.insert(transaction);

    widget.gameState.updateGoal(updatedGoal);
    if (newlyEarnedCoins > 0) {
      widget.gameState.addCoins(newlyEarnedCoins);
    }

    if (shouldComplete) {
      widget.gameState.completeGoal(goal.id);
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          shouldComplete
              ? _tr(l10n, 'moneyAssignedAndGoalCompleted')
              : _tr(l10n, 'moneyAssignedToGoal'),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showAllocateMoneyDialog(Goal goal) async {
    final amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = Provider.of<AppLocalizationsProvider>(dialogContext);
        return AlertDialog(
          title: Text(
            _trParams(l10n, 'assignMoneyToGoal', {'goal': goal.title}),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _trParams(l10n, 'availableBalance', {
                  'amount': _formatMoney(widget.gameState.money),
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: _tr(l10n, 'amount'),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (amount <= 0) {
                  return;
                }
                if (amount > widget.gameState.money) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _tr(l10n, 'amountExceedsCurrentAppBalance'),
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                  return;
                }

                Navigator.pop(dialogContext);
                await _applyGoalAllocation(goal, amount);
              },
              child: Text(_tr(l10n, 'assignMoney')),
            ),
          ],
        );
      },
    );
  }

  void _showCreateGoalDialog() {
    final l10n = context.read<AppLocalizationsProvider>();
    DateTime selectedDate = _selectedDate;
    String selectedDifficulty = _selectedDifficulty;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          title: const Text('Create New Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Title',
                    hintText: 'Enter goal title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter goal description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: _tr(l10n, 'rewardLabel'),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_difficultyRewards[selectedDifficulty]} coins',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedDifficulty,
                  decoration: InputDecoration(
                    labelText: _tr(l10n, 'difficulty'),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: Goal.easyDifficulty,
                      child: Text(_difficultyLabel(l10n, Goal.easyDifficulty)),
                    ),
                    DropdownMenuItem(
                      value: Goal.mediumDifficulty,
                      child: Text(
                        _difficultyLabel(l10n, Goal.mediumDifficulty),
                      ),
                    ),
                    DropdownMenuItem(
                      value: Goal.hardDifficulty,
                      child: Text(_difficultyLabel(l10n, Goal.hardDifficulty)),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    dialogSetState(() {
                      selectedDifficulty = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _targetMoneyController,
                  decoration: InputDecoration(
                    labelText: _tr(l10n, 'goalAmount'),
                    hintText: 'Enter money target',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Due Date: ${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          dialogSetState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: const Text('Pick Date'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a goal title')),
                  );
                  return;
                }

                final newGoal = Goal(
                  id: const Uuid().v4(),
                  title: _titleController.text,
                  description: _descriptionController.text,
                  difficulty: selectedDifficulty,
                  rewardCoins: _difficultyRewards[selectedDifficulty] ?? 50,
                  targetMoney:
                      double.tryParse(_targetMoneyController.text) ?? 0.0,
                  dueDate: selectedDate,
                );

                setState(() {
                  _isSyncing = true;
                });

                final success = await GoalDatabaseService.createGoal(newGoal);

                setState(() {
                  _isSyncing = false;
                });

                if (success) {
                  widget.gameState.addGoal(newGoal);
                  _titleController.clear();
                  _descriptionController.clear();
                  _targetMoneyController.text = '0';
                  _selectedDate = DateTime.now();
                  _selectedDifficulty = Goal.easyDifficulty;

                  if (mounted) {
                    Navigator.pop(context);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Goal created successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to create goal'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: const Text('Create Goal'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();
    final goals = widget.gameState.goals;
    final activeGoals = goals.where((g) => !g.isCompleted).toList();
    final completedGoals = goals.where((g) => g.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('goals')),
        backgroundColor: Colors.deepPurple[300],
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        actions: [
          if (_isSyncing)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              ),
            )
          else
            IconButton(
              onPressed: _loadGoalsFromBackend,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh goals',
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple[300]!,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading goals...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : goals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No goals yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first goal to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    if (activeGoals.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Active Goals (${activeGoals.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      ...activeGoals.map((goal) => _buildGoalCard(goal)),
                    ],
                    if (completedGoals.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                        child: Text(
                          'Completed Goals (${completedGoals.length})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      ...completedGoals.map((goal) => _buildGoalCard(goal)),
                    ],
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: _isSyncing ? null : _showCreateGoalDialog,
        backgroundColor: Colors.deepPurple[300],
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    final l10n = context.watch<AppLocalizationsProvider>();
    final hasTarget = goal.targetMoney > 0;
    final progress = hasTarget
        ? (goal.allocatedMoney / goal.targetMoney).clamp(0.0, 1.0).toDouble()
        : 0.0;
    final canComplete = !hasTarget || progress >= 1;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: goal.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: goal.isCompleted
                              ? Colors.grey[400]
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_difficultyLabel(l10n, goal.difficulty)} - ${_tr(l10n, 'rewardLabel')} ${goal.rewardCoins}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!goal.isCompleted)
                  Checkbox(
                    value: false,
                    onChanged: (value) async {
                      if (!canComplete) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Goal can only be completed at 100% progress.',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                        return;
                      }
                      final success =
                          await GoalDatabaseService.completeGoal(goal.id);

                      if (success) {
                        widget.gameState.completeGoal(goal.id);
                        setState(() {});

                        if (mounted) {
                          final completionMessage =
                              goal.difficulty == Goal.hardDifficulty
                                  ? _tr(l10n, 'goalCompletedChrumkaOnly')
                                  : _trParams(
                                      l10n,
                                      'goalCompletedCoinsAndChrumka',
                                      {'coins': goal.rewardCoins.toString()},
                                    );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(completionMessage),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to complete goal'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  )
                else
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[400],
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasTarget) ...[
              Text(
                'Saved ${_formatMoney(goal.allocatedMoney)} / ${_formatMoney(goal.targetMoney)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1
                        ? Colors.green[400]!
                        : Colors.deepPurple[300]!,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (!goal.isCompleted)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: widget.gameState.money > 0
                        ? () => _showAllocateMoneyDialog(goal)
                        : null,
                    icon: const Icon(Icons.account_balance_wallet_outlined),
                    label: Text(_tr(l10n, 'assignMoney')),
                  ),
                ),
              if (!goal.isCompleted) const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${goal.dueDate.day}.${goal.dueDate.month}.${goal.dueDate.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${goal.rewardCoins}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[700],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () async {
                    final shouldRefundAllocatedMoney =
                        goal.allocatedMoney > 0 &&
                            !(goal.isCompleted &&
                                goal.difficulty == Goal.hardDifficulty);
                    if (shouldRefundAllocatedMoney) {
                      widget.gameState.addMoney(goal.allocatedMoney);
                    }
                    final success =
                        await GoalDatabaseService.deleteGoal(goal.id);

                    if (success) {
                      if (shouldRefundAllocatedMoney) {
                        final tx = TransactionModel(
                          id: const Uuid().v4(),
                          type: '+',
                          amount: goal.allocatedMoney,
                          note: _tr(l10n, 'goalDeletedAndMoneyReturned'),
                          date: DateTime.now(),
                        );
                        await FinancialDatabaseService.insert(tx);
                      }
                      widget.gameState.removeGoal(goal.id);
                      setState(() {});

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              shouldRefundAllocatedMoney
                                  ? _tr(l10n, 'goalDeletedAndMoneyReturned')
                                  : _tr(l10n, 'goalDeleted'),
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } else {
                      if (shouldRefundAllocatedMoney) {
                        widget.gameState.spendMoney(goal.allocatedMoney);
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to delete goal'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.delete),
                  iconSize: 20,
                  color: Colors.red[400],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
