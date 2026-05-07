import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/goal.dart';
import '../services/goal_database_service.dart';
import '../services/app_localizations_provider.dart';
import '../services/goal_ai_service.dart';
import '../services/financial_database_service.dart';
import '../services/goal_allocation_service.dart';
import '../services/tutorial_provider.dart';
import '../widgets/tutorial_target.dart';
import 'package:uuid/uuid.dart';

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
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetMoneyController;
  late FocusNode _titleFocusNode;
  late FocusNode _descriptionFocusNode;
  late FocusNode _amountFocusNode;
  late ScrollController _dialogScrollController;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _isSyncing = false;

  Future<void> _showReassignFundsDialog() async {
    String? fromGoalId;
    String? toGoalId;
    final amountController = TextEditingController();
    final l10n = context.read<AppLocalizationsProvider>();

    final sourceGoals = widget.gameState.goals
        .where((g) => !g.isCompleted && g.allocatedMoney > 0)
        .toList();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            final destinationGoals = widget.gameState.goals
                .where((g) => !g.isCompleted && g.id != fromGoalId)
                .toList();

            return AlertDialog(
              title: Text(l10n.translate('reassignFundsTitle')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: fromGoalId,
                    decoration: InputDecoration(
                      labelText: l10n.translate('fromGoal'),
                    ),
                    items: sourceGoals
                        .map(
                          (goal) => DropdownMenuItem<String>(
                            value: goal.id,
                            child: Text(
                              '${goal.title} (${_formatMoney(goal.allocatedMoney)})',
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
                    decoration: InputDecoration(
                      labelText: l10n.translate('toGoal'),
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
                    decoration:
                        InputDecoration(labelText: l10n.translate('amount')),
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
                    if (fromGoalId == null || toGoalId == null) return;
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0) return;

                    // Get the allocations for the source goal
                    final allocations =
                        await FinancialDatabaseService.getAllocationsForGoal(
                            fromGoalId!);
                    final totalAllocated = allocations.fold<double>(
                        0, (sum, alloc) => sum + alloc.amount);

                    if (amount > totalAllocated + 0.0001) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(l10n.translate('amountExceedsGoalFunds')),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // Use new transfer method instead of transactions
                    await GoalAllocationService.transferBetweenGoals(
                      fromGoalId!,
                      toGoalId!,
                      amount,
                    );
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

  String _formatMoney(double money) {
    if (money % 1 == 0) {
      return money.toStringAsFixed(0);
    }
    return money.toStringAsFixed(2);
  }

  double get _allocatedGoalMoney {
    return widget.gameState.goals.fold<double>(
      0,
      (sum, goal) => sum + goal.allocatedMoney,
    );
  }

  double get _assignableGoalMoney {
    final available = widget.gameState.money - _allocatedGoalMoney;
    return available > 0 ? available : 0.0;
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _targetMoneyController = TextEditingController(text: '0');
    _titleFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
    _amountFocusNode = FocusNode();
    _dialogScrollController = ScrollController();
    _loadGoalsFromBackend();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetMoneyController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _amountFocusNode.dispose();
    _dialogScrollController.dispose();
    super.dispose();
  }

  /// Load goals from local database
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
      });

      // Recalculate allocations to populate allocatedMoney fields
      await GoalAllocationService.recalculate(widget.gameState);

      if (!mounted) return;
      setState(() {
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
          SnackBar(
            content: Text(context
                .read<AppLocalizationsProvider>()
                .translate('goalLoadFail')),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _recalculateMoneyAndAllocations() async {
    await GoalAllocationService.recalculate(widget.gameState);
    if (mounted) {
      setState(() {});
    }
  }

  void _showCreateGoalDialog(AppLocalizationsProvider l10n) {
    DateTime selectedDate = _selectedDate;
    final titleFieldKey = GlobalKey();
    final descriptionFieldKey = GlobalKey();
    final amountFieldKey = GlobalKey();

    String? titleError;
    String? descriptionError;
    String? amountError;
    String? generalWarning;

    Future<void> scrollToField({
      required GlobalKey fieldKey,
      FocusNode? focusNode,
    }) async {
      focusNode?.requestFocus();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final fieldContext = fieldKey.currentContext;
      if (fieldContext == null) return;
      await Scrollable.ensureVisible(
        fieldContext,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: 0.2,
      );
    }

    Future<void> scrollToInvalidField(GoalAiInvalidField field) async {
      switch (field) {
        case GoalAiInvalidField.title:
          await scrollToField(
            fieldKey: titleFieldKey,
            focusNode: _titleFocusNode,
          );
          break;
        case GoalAiInvalidField.description:
          await scrollToField(
            fieldKey: descriptionFieldKey,
            focusNode: _descriptionFocusNode,
          );
          break;
        case GoalAiInvalidField.amount:
          await scrollToField(
            fieldKey: amountFieldKey,
            focusNode: _amountFocusNode,
          );
          break;
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) {
          final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
          final maxDialogHeight = MediaQuery.of(context).size.height * 0.72;

          return AlertDialog(
            title: Text(l10n.translate('createNewGoal')),
            content: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxDialogHeight),
              child: SingleChildScrollView(
                controller: _dialogScrollController,
                child: Padding(
                  padding: EdgeInsets.only(bottom: keyboardInset),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        key: titleFieldKey,
                        child: TextField(
                          controller: _titleController,
                          focusNode: _titleFocusNode,
                          maxLength: 80,
                          scrollPadding: const EdgeInsets.only(bottom: 220),
                          onChanged: (_) {
                            if (titleError != null || generalWarning != null) {
                              dialogSetState(() {
                                titleError = null;
                                generalWarning = null;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: l10n.translate('goalTitle'),
                            hintText: l10n.translate('enterGoalTitleHint'),
                            border: const OutlineInputBorder(),
                            errorText: titleError,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        key: descriptionFieldKey,
                        child: TextField(
                          controller: _descriptionController,
                          focusNode: _descriptionFocusNode,
                          maxLength: 400,
                          scrollPadding: const EdgeInsets.only(bottom: 220),
                          onChanged: (_) {
                            if (descriptionError != null ||
                                generalWarning != null) {
                              dialogSetState(() {
                                descriptionError = null;
                                generalWarning = null;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: l10n.translate('goalDescription'),
                            hintText: l10n.translate('enterGoalDescription'),
                            border: const OutlineInputBorder(),
                            errorText: descriptionError,
                          ),
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.translate('rewardAiInfo'),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        key: amountFieldKey,
                        child: TextField(
                          controller: _targetMoneyController,
                          focusNode: _amountFocusNode,
                          maxLength: 50,
                          scrollPadding: const EdgeInsets.only(bottom: 220),
                          decoration: InputDecoration(
                            labelText: l10n.translate('goalAmount'),
                            hintText: l10n.translate('enterMoneyTarget'),
                            border: const OutlineInputBorder(),
                            errorText: amountError,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) {
                            if (amountError != null || generalWarning != null) {
                              dialogSetState(() {
                                amountError = null;
                                generalWarning = null;
                              });
                            }
                          },
                        ),
                      ),
                      if (generalWarning != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Text(
                            generalWarning!,
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${l10n.translate('dueDate')}: ${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
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
                            child: Text(l10n.translate('pickDate')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.translate('cancel')),
              ),
              ElevatedButton(
                onPressed: _isSyncing
                    ? null
                    : () async {
                        final trimmedTitle = _titleController.text.trim();
                        final rawTargetText =
                            _targetMoneyController.text.trim();
                        final parsedTarget = double.tryParse(rawTargetText);

                        if (trimmedTitle.isEmpty) {
                          dialogSetState(() {
                            titleError = l10n.translate('enterGoalTitle');
                            descriptionError = null;
                            amountError = null;
                            generalWarning = null;
                          });
                          await scrollToInvalidField(GoalAiInvalidField.title);
                          return;
                        }

                        if (rawTargetText.isNotEmpty &&
                            rawTargetText != '0' &&
                            (parsedTarget == null || parsedTarget <= 0)) {
                          dialogSetState(() {
                            titleError = null;
                            descriptionError = null;
                            amountError = l10n.translate('enterMoneyTarget');
                            generalWarning = null;
                          });
                          await scrollToInvalidField(GoalAiInvalidField.amount);
                          return;
                        }

                        final targetMoney =
                            parsedTarget != null && parsedTarget > 0
                                ? parsedTarget
                                : null;

                        dialogSetState(() {
                          titleError = null;
                          descriptionError = null;
                          amountError = null;
                          generalWarning = null;
                        });
                        setState(() {
                          _isSyncing = true;
                        });

                        final aiResult = await GoalAiService.classifyGoal(
                          title: _titleController.text,
                          description: _descriptionController.text,
                          targetMoney: targetMoney,
                          dueDate: selectedDate,
                          language: l10n.currentLanguage,
                        );

                        if (!mounted) return;

                        if (aiResult.needsMoreInfo) {
                          setState(() {
                            _isSyncing = false;
                          });

                          final warningText = aiResult.reason ??
                              l10n.translate('needMoreGoalDetails');
                          final invalidField = aiResult.invalidField ??
                              GoalAiInvalidField.description;

                          dialogSetState(() {
                            titleError =
                                invalidField == GoalAiInvalidField.title
                                    ? warningText
                                    : null;
                            descriptionError =
                                invalidField == GoalAiInvalidField.description
                                    ? warningText
                                    : null;
                            amountError =
                                invalidField == GoalAiInvalidField.amount
                                    ? warningText
                                    : null;
                            generalWarning = aiResult.invalidField == null
                                ? warningText
                                : null;
                          });

                          await scrollToInvalidField(invalidField);
                          return;
                        }

                        final resolvedScore = aiResult.challengeScore ??
                            GoalAiService.estimateChallengeScore(
                              targetMoney: targetMoney,
                              dueDate: selectedDate,
                            );
                        final resolvedReward = aiResult.rewardCoins ??
                            GoalAiService.estimateRewardCoins(
                              challengeScore: resolvedScore,
                              targetMoney: targetMoney,
                              dueDate: selectedDate,
                            );

                        final newGoal = Goal(
                          id: const Uuid().v4(),
                          title: _titleController.text,
                          description: _descriptionController.text,
                          challengeScore: resolvedScore,
                          rewardCoins: resolvedReward,
                          targetMoney: targetMoney ?? 0.0,
                          dueDate: selectedDate,
                        );

                        final success =
                            await GoalDatabaseService.createGoal(newGoal);

                        setState(() {
                          _isSyncing = false;
                        });

                        if (success) {
                          widget.gameState.addGoal(newGoal);
                          _titleController.clear();
                          _descriptionController.clear();
                          _targetMoneyController.text = '0';
                          _selectedDate = DateTime.now();

                          if (mounted) {
                            Navigator.pop(context);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    l10n.translate('goalCreatedSuccessfully')),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text(l10n.translate('failedToCreateGoal')),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                child: Text(l10n.translate('createGoal')),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAllocateMoneyDialog(Goal goal) async {
    final l10n = context.read<AppLocalizationsProvider>();
    final amountController = TextEditingController();
    final spendableBalance = _assignableGoalMoney;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n
              .translate('assignMoneyToGoal')
              .replaceFirst('{goal}', goal.title),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('goalsAssignableMoney').replaceFirst(
                    '{amount}',
                    _formatMoney(spendableBalance),
                  ),
              style: TextStyle(
                color: Colors.deepPurple[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.translate('enterAmount'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: _isSyncing
                ? null
                : () async {
                    final amount =
                        double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (amount <= 0) return;

                    if (amount > spendableBalance + 0.0001) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.translate('amountExceedsBalance')),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    if (goal.targetMoney > 0 &&
                        amount >
                            goal.targetMoney - goal.allocatedMoney + 0.0001) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(l10n.translate('amountExceedsGoalTarget')),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    setState(() => _isSyncing = true);

                    // Use new allocation system instead of transactions
                    await GoalAllocationService.allocateToGoal(goal.id, amount);
                    await _recalculateMoneyAndAllocations();

                    if (mounted) {
                      setState(() => _isSyncing = false);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.translate('moneyAssignedSuccess')),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
            child: Text(l10n.translate('assignMoney')),
          ),
        ],
      ),
    );
  }

  Future<void> _showWithdrawMoneyDialog(Goal goal) async {
    final l10n = context.read<AppLocalizationsProvider>();
    final amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n
              .translate('withdrawMoneyFromGoal')
              .replaceFirst('{goal}', goal.title),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${l10n.translate('currentlyAssigned')}: €${goal.allocatedMoney.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.translate('withdrawAmount'),
                hintText: '0.00',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: _isSyncing
                ? null
                : () async {
                    final amount =
                        double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (amount <= 0) return;

                    if (amount > goal.allocatedMoney + 0.0001) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(l10n.translate('amountExceedsAllocated')),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    setState(() => _isSyncing = true);

                    await GoalAllocationService.removeFromGoal(goal.id, amount);
                    await _recalculateMoneyAndAllocations();

                    if (mounted) {
                      setState(() => _isSyncing = false);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(l10n.translate('moneyWithdrawnSuccess')),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
            child: Text(l10n.translate('withdraw')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = widget.gameState.goals;
    final activeGoals = goals.where((g) => !g.isCompleted).toList();
    final completedGoals = goals.where((g) => g.isCompleted).toList();

    return Consumer<AppLocalizationsProvider>(
      builder: (context, localizationsProvider, _) {
        final l10n = localizationsProvider;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.translate('goals')),
            backgroundColor: Colors.deepPurple[300],
            centerTitle: true,
            leading: TutorialTarget(
              id: 'close_goals',
              child: IconButton(
                icon: const Icon(Icons.close),
                color: Colors.black,
                onPressed: widget.onBack,
              ),
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
                  tooltip: l10n.translate('refreshGoals'),
                ),
              TutorialTarget(
                id: 'reassign_funds',
                child: IconButton(
                  onPressed: _showReassignFundsDialog,
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: l10n.translate('reassignTooltip'),
                ),
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
                      Text(
                        l10n.translate('loadingGoals'),
                        style: const TextStyle(fontSize: 16),
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
                            l10n.translate('noGoalsYet'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.translate('createYourFirstGoal'),
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
                          _buildAssignableMoneySummary(l10n),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              '${l10n.translate('goalsActive')} (${activeGoals.length})',
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
                              '${l10n.translate('goalsCompleted')} (${completedGoals.length})',
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
          floatingActionButton: TutorialTarget(
            id: 'add_goal',
            child: FloatingActionButton(
              heroTag: null,
              onPressed: _isSyncing
                  ? null
                  : () {
                      context
                          .read<TutorialProvider>()
                          .registerAction('add_goal');
                      _showCreateGoalDialog(l10n);
                    },
              backgroundColor: Colors.deepPurple[300],
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssignableMoneySummary(AppLocalizationsProvider l10n) {
    final assignable = _assignableGoalMoney;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.deepPurple[400],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('goalsAssignableSummaryTitle'),
                  style: TextStyle(
                    color: Colors.deepPurple[800],
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 112),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                _formatMoney(assignable),
                style: TextStyle(
                  color: Colors.deepPurple[900],
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    final l10n = context.read<AppLocalizationsProvider>();
    final bool hasTarget = goal.targetMoney > 0;
    final double progress =
        hasTarget ? (goal.allocatedMoney / goal.targetMoney).clamp(0, 1) : 0;
    final bool canComplete = !hasTarget || progress >= 1;
    final bool isMilestoneGoal = goal.supportsMilestones;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: isMilestoneGoal ? Colors.orange[50] : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isMilestoneGoal
            ? BorderSide(
                color: Colors.orange.shade300,
                width: 1.25,
              )
            : BorderSide.none,
      ),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
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
                          ),
                          if (isMilestoneGoal) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.orange.shade300,
                                ),
                              ),
                              child: Text(
                                l10n.translate('milestoneGoalLabel'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.translate('goalRewardLabel').replaceFirst(
                            '{coins}', goal.rewardCoins.toString()),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        goal.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                            SnackBar(
                              content: Text(
                                l10n.translate('goalCompleteProgressError'),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                        return;
                      }

                      setState(() => _isSyncing = true);

                      try {
                        // Use completeGoalManually to create the transaction
                        await GoalAllocationService.completeGoalManually(
                          widget.gameState,
                          goal.id,
                          goal.title,
                          goal.allocatedMoney,
                          goal.rewardCoins,
                        );

                        if (mounted) {
                          setState(() => _isSyncing = false);
                          final completionText = l10n
                              .translate('goalCompleted')
                              .replaceFirst(
                                  '{coins}', goal.rewardCoins.toString());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(completionText),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          setState(() {});
                        }
                      } catch (e) {
                        if (mounted) {
                          setState(() => _isSyncing = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text(l10n.translate('failedToCompleteGoal')),
                              duration: const Duration(seconds: 2),
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
                l10n
                    .translate('savedProgress')
                    .replaceFirst('{saved}', _formatMoney(goal.allocatedMoney))
                    .replaceFirst('{target}', _formatMoney(goal.targetMoney)),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isMilestoneGoal) ...[
                const SizedBox(height: 6),
                Text(
                  l10n
                      .translate('milestoneProgressLabel')
                      .replaceFirst(
                        '{current}',
                        goal.milestonesAwarded.toString(),
                      )
                      .replaceFirst(
                        '{total}',
                        Goal.milestoneStepCount.toString(),
                      ),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
            ],
            if (!goal.isCompleted)
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: _assignableGoalMoney > 0
                          ? () => _showAllocateMoneyDialog(goal)
                          : null,
                      icon: const Icon(Icons.account_balance_wallet_outlined),
                      label: Text(l10n.translate('assignMoney')),
                    ),
                    if (goal.allocatedMoney > 0)
                      TextButton.icon(
                        onPressed: () => _showWithdrawMoneyDialog(goal),
                        icon: const Icon(Icons.remove_circle_outline),
                        label: Text(l10n.translate('withdraw')),
                      ),
                  ],
                ),
              ),
            if (!goal.isCompleted) const SizedBox(height: 12),
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
                    final success =
                        await GoalDatabaseService.deleteGoal(goal.id);

                    if (success) {
                      // Refund allocated money back to balance
                      if (goal.allocatedMoney > 0) {
                        widget.gameState.addMoney(goal.allocatedMoney);
                      }
                      widget.gameState.removeGoal(goal.id);
                      setState(() {});

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.translate('goalDeleted')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.translate('failedToDeleteGoal'),
                            ),
                            duration: const Duration(seconds: 2),
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
