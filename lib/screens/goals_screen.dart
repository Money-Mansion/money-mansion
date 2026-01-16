import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/goal.dart';
import '../services/goal_database_service.dart';
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
  late TextEditingController _coinsController;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _coinsController = TextEditingController(text: '10');
    _loadGoalsFromBackend();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _coinsController.dispose();
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

  void _showCreateGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              TextField(
                controller: _coinsController,
                decoration: const InputDecoration(
                  labelText: 'Reward Coins',
                  hintText: 'Enter coin reward',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Due Date: ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
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
                rewardCoins: int.tryParse(_coinsController.text) ?? 10,
                dueDate: _selectedDate,
              );

              // Create goal in local database
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
                _coinsController.text = '10';
                _selectedDate = DateTime.now();

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
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = widget.gameState.goals;
    final activeGoals = goals.where((g) => !g.isCompleted).toList();
    final completedGoals = goals.where((g) => g.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
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
        onPressed: _isSyncing ? null : _showCreateGoalDialog,
        backgroundColor: Colors.deepPurple[300],
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
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
                    ],
                  ),
                ),
                if (!goal.isCompleted)
                  Checkbox(
                    value: false,
                    onChanged: (value) async {
                      final success = await GoalDatabaseService.completeGoal(goal.id);
                      
                      if (success) {
                        widget.gameState.completeGoal(goal.id);
                        setState(() {});
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Goal completed! +${goal.rewardCoins} coins',
                              ),
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
                    final success = await GoalDatabaseService.deleteGoal(goal.id);
                    
                    if (success) {
                      widget.gameState.removeGoal(goal.id);
                      setState(() {});
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Goal deleted'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } else {
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
