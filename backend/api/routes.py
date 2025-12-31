"""
REST API routes for Money Mansion backend
"""

from flask import Blueprint, request, jsonify
from database.dao import TaskDAO

def create_api_blueprint():
    """Create and return the API blueprint"""
    api_bp = Blueprint('api', __name__, url_prefix='/api')
    
    # ============ TASK ENDPOINTS ============
    
    @api_bp.route('/tasks', methods=['GET'])
    def get_tasks():
        """Get all tasks"""
        try:
            tasks = TaskDAO.get_all_tasks()
            return jsonify({
                'success': True,
                'data': tasks,
                'count': len(tasks)
            }), 200
        except Exception as e:
            return jsonify({
                'success': False,
                'error': str(e)
            }), 500
    
    @api_bp.route('/tasks', methods=['POST'])
    def create_task():
        """Create a new task"""
        try:
            data = request.get_json()
            
            if not data or 'id' not in data or 'task_name' not in data:
                return jsonify({
                    'success': False,
                    'message': 'Missing required fields: id, task_name'
                }), 400
            
            task_id = data.get('id')
            task_name = data.get('task_name')
            description = data.get('description', '')
            reward_coins = data.get('reward_coins', 0)
            reward_money = data.get('reward_money', 0.0)
            due_date = data.get('due_date')
            
            print(f"Creating task: id={task_id}, name={task_name}, coins={reward_coins}, money={reward_money}")
            
            success = TaskDAO.create_task(
                task_id=task_id,
                task_name=task_name,
                description=description,
                reward_coins=reward_coins,
                reward_money=reward_money,
                due_date=due_date
            )
            
            if success:
                return jsonify({
                    'success': True,
                    'message': 'Task created successfully',
                    'id': task_id
                }), 201
            else:
                return jsonify({
                    'success': False,
                    'message': 'Failed to create task'
                }), 500
        except Exception as e:
            print(f"Error creating task: {e}")
            return jsonify({
                'success': False,
                'message': f'Error: {str(e)}'
            }), 500
    
    @api_bp.route('/tasks/<task_id>', methods=['GET'])
    def get_task(task_id):
        """Get a specific task by ID"""
        try:
            task = TaskDAO.get_task_by_id(task_id)
            if task:
                return jsonify({
                    'success': True,
                    'data': task
                }), 200
            else:
                return jsonify({
                    'success': False,
                    'message': 'Task not found'
                }), 404
        except Exception as e:
            return jsonify({
                'success': False,
                'error': str(e)
            }), 500
    
    @api_bp.route('/tasks/<task_id>', methods=['PUT'])
    def update_task(task_id):
        """Update a task"""
        try:
            data = request.get_json()
            
            success = TaskDAO.update_task(
                task_id=task_id,
                task_name=data.get('task_name'),
                description=data.get('description'),
                reward_coins=data.get('reward_coins'),
                reward_money=data.get('reward_money'),
                due_date=data.get('due_date')
            )
            
            if success:
                return jsonify({
                    'success': True,
                    'message': 'Task updated successfully'
                }), 200
            else:
                return jsonify({
                    'success': False,
                    'message': 'Failed to update task'
                }), 500
        except Exception as e:
            return jsonify({
                'success': False,
                'error': str(e)
            }), 500
    
    @api_bp.route('/tasks/<task_id>', methods=['DELETE'])
    def delete_task(task_id):
        """Delete a task"""
        try:
            success = TaskDAO.delete_task(task_id)
            if success:
                return jsonify({
                    'success': True,
                    'message': 'Task deleted successfully'
                }), 200
            else:
                return jsonify({
                    'success': False,
                    'message': 'Failed to delete task'
                }), 500
        except Exception as e:
            return jsonify({
                'success': False,
                'error': str(e)
            }), 500
    
    @api_bp.route('/tasks/<task_id>/complete', methods=['PUT'])
    def complete_task(task_id):
        """Mark a task as completed"""
        try:
            success = TaskDAO.complete_task(task_id)
            if success:
                return jsonify({
                    'success': True,
                    'message': 'Task marked as completed'
                }), 200
            else:
                return jsonify({
                    'success': False,
                    'message': 'Failed to complete task'
                }), 500
        except Exception as e:
            return jsonify({
                'success': False,
                'error': str(e)
            }), 500
    
    # ============ GAME STATE ENDPOINTS ============
    
    @api_bp.route('/game/state', methods=['GET'])
    def get_game_state():
        """Get current game state (coins, money, tasks progress)"""
        try:
            state = TaskDAO.get_game_state()
            return jsonify({
                'success': True,
                'data': state
            }), 200
        except Exception as e:
            return jsonify({
                'success': False,
                'error': str(e)
            }), 500
    
    return api_bp
