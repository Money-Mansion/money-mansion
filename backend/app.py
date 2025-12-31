#!/usr/bin/env python3
"""
Money Mansion Backend Server
Flask-based REST API for game state and task management
"""

import os
import sys
from flask import Flask, jsonify
from flask_cors import CORS

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from database.db_init import init_database
from api.routes import create_api_blueprint

def create_app():
    """Create and configure Flask application"""
    app = Flask(__name__)
    
    # Enable CORS for all routes
    CORS(app, resources={r"/api/*": {"origins": "*"}})
    
    # Initialize database
    init_database()
    
    # Register API blueprint
    api_bp = create_api_blueprint()
    app.register_blueprint(api_bp)
    
    @app.route('/')
    def home():
        return jsonify({
            'status': 'online',
            'message': 'Money Mansion Backend API',
            'version': '1.0.0'
        }), 200
    
    @app.route('/health')
    def health():
        return jsonify({
            'status': 'healthy',
            'database': 'connected'
        }), 200
    
    return app

if __name__ == '__main__':
    app = create_app()
    
    print("=" * 60)
    print("Money Mansion Backend Server")
    print("=" * 60)
    print("\nServer will listen on: 0.0.0.0:5000")
    print("Running on all addresses (0.0.0.0)")
    print("  - http://localhost:5000")
    print("  - http://127.0.0.1:5000")
    print("\nEndpoints:")
    print("  GET  /api/tasks              - Get all tasks")
    print("  POST /api/tasks              - Create new task")
    print("  GET  /api/tasks/<id>         - Get task by ID")
    print("  PUT  /api/tasks/<id>         - Update task")
    print("  DELETE /api/tasks/<id>       - Delete task")
    print("  PUT  /api/tasks/<id>/complete - Mark task as complete")
    print("  GET  /api/game/state         - Get game state")
    print("\nPress CTRL+C to stop the server")
    print("=" * 60 + "\n")
    
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True
    )
