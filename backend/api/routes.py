"""
API routes for Money Mansion backend
Handles HTTP requests for game operations
"""

from flask import Blueprint, request, jsonify
from api.services import TaskService, GameService
from database.dao import TaskDAO
from datetime import datetime

# Create blueprints for different resources
tasks_bp = Blueprint('tasks', __name__, url_prefix='/api/tasks')
game_bp = Blueprint('game', __name__, url_prefix='/api/game')


# ==================== TASK ROUTES ====================

@tasks_bp.route('', methods=['GET'])
def get_all_tasks():
    """Get all tasks"""
    try:
        tasks = TaskDAO.get_all_tasks()
        tasks_list = []
        for task in tasks:
            tasks_list.append({
                'id': task[0],
                'title': task[1],
                'description': task[2],
                'status': task[3],
                'rewardCoins': task[4],
                'dueDate': task[6],
                'isCompleted': task[3] == 'completed'
            })
        return jsonify(tasks_list), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@tasks_bp.route('', methods=['POST'])
def create_task():
    """Create a new task"""
    try:
        data = request.get_json()
        
        if not data or 'title' not in data:
            return jsonify({'error': 'Missing required field: title'}), 400
        
        title = data.get('title')
        description = data.get('description', '')
        reward_coins = data.get('rewardCoins', 10)
        due_date = data.get('dueDate')
        
        # Convert timestamp to float if provided
        if due_date:
            try:
                due_date = float(due_date)
            except (ValueError, TypeError):
                due_date = None
        
        TaskDAO.create_task(
            task_name=title,
            description=description,
            reward_coins=reward_coins,
            reward_money=0,
            due_date=due_date
        )
        
        return jsonify({'success': True, 'message': 'Task created'}), 201
    
    except Exception as e:
        print(f"Error creating task: {e}")
        return jsonify({'error': str(e)}), 500


@tasks_bp.route('/<int:task_id>', methods=['GET'])
def get_task(task_id):
    """Get a specific task by ID"""
    try:
        task = TaskDAO.get_task_by_id(task_id)
        
        if not task:
            return jsonify({'error': 'Task not found'}), 404
        
        task_data = {
            'id': task[0],
            'title': task[1],
            'description': task[2],
            'status': task[3],
            'rewardCoins': task[4],
            'dueDate': task[6],
            'isCompleted': task[3] == 'completed'
        }
        
        return jsonify(task_data), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@tasks_bp.route('/<int:task_id>/complete', methods=['PUT'])
def complete_task(task_id):
    """Mark a task as completed"""
    try:
        task = TaskDAO.get_task_by_id(task_id)
        
        if not task:
            return jsonify({'error': 'Task not found'}), 404
        
        if task[3] != 'completed':  # task[3] is status
            TaskDAO.complete_task(task_id)
            
            # Add coins reward to game state
            if task[4] > 0:  # task[4] is reward_coins
                GameService.add_coins(task[4])
        
        return jsonify({'success': True, 'message': 'Task completed', 'coinsAwarded': task[4]}), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@tasks_bp.route('/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    """Delete a task"""
    try:
        task = TaskDAO.get_task_by_id(task_id)
        
        if not task:
            return jsonify({'error': 'Task not found'}), 404
        
        # Delete task from database
        from database.db_init import DatabaseManager
        query = 'DELETE FROM tasks WHERE id = ?'
        DatabaseManager.execute_update(query, (task_id,))
        
        return jsonify({'success': True, 'message': 'Task deleted'}), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@tasks_bp.route('/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    """Update a task"""
    try:
        data = request.get_json()
        task = TaskDAO.get_task_by_id(task_id)
        
        if not task:
            return jsonify({'error': 'Task not found'}), 404
        
        from database.db_init import DatabaseManager
        
        # Build update query dynamically
        updates = []
        params = []
        
        if 'title' in data:
            updates.append('task_name = ?')
            params.append(data['title'])
        
        if 'description' in data:
            updates.append('description = ?')
            params.append(data['description'])
        
        if 'rewardCoins' in data:
            updates.append('reward_coins = ?')
            params.append(data['rewardCoins'])
        
        if 'dueDate' in data:
            updates.append('due_date = ?')
            try:
                params.append(float(data['dueDate']))
            except (ValueError, TypeError):
                params.append(None)
        
        if updates:
            params.append(task_id)
            query = f'UPDATE tasks SET {", ".join(updates)} WHERE id = ?'
            DatabaseManager.execute_update(query, params)
        
        return jsonify({'success': True, 'message': 'Task updated'}), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ==================== GAME STATE ROUTES ====================

@game_bp.route('/state', methods=['GET'])
def get_game_state():
    """Get current game state"""
    try:
        game_state = GameService.get_game_state()
        
        if not game_state:
            return jsonify({'error': 'Game state not found'}), 404
        
        state_data = {
            'id': game_state[0],
            'coins': game_state[1],
            'money': game_state[2],
            'date': game_state[3],
            'level': game_state[4],
            'experience': game_state[5]
        }
        
        return jsonify(state_data), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@game_bp.route('/coins/add', methods=['POST'])
def add_coins():
    """Add coins to player"""
    try:
        data = request.get_json()
        amount = data.get('amount', 0)
        
        if not isinstance(amount, int) or amount <= 0:
            return jsonify({'error': 'Invalid amount'}), 400
        
        success = GameService.add_coins(amount)
        
        if success:
            game_state = GameService.get_game_state()
            return jsonify({
                'success': True,
                'message': f'Added {amount} coins',
                'coins': game_state[1]
            }), 200
        else:
            return jsonify({'error': 'Failed to add coins'}), 500
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


def register_blueprints(app):
    """Register all blueprints with the Flask app"""
    app.register_blueprint(tasks_bp)
    app.register_blueprint(game_bp)
