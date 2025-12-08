"""
Quick test script to verify Task API is working
Run this after starting the Flask backend server
"""

import requests
import json

BASE_URL = "http://127.0.0.1:5000/api"

def test_api():
    print("Testing Money Mansion Task API...\n")
    
    # Test 1: Get all tasks (should be empty initially)
    print("1. Testing GET /tasks...")
    try:
        response = requests.get(f"{BASE_URL}/tasks")
        print(f"   Status: {response.status_code}")
        print(f"   Tasks: {response.json()}\n")
    except Exception as e:
        print(f"   Error: {e}\n")
    
    # Test 2: Create a task
    print("2. Testing POST /tasks...")
    task_data = {
        "title": "Test Task",
        "description": "This is a test task",
        "rewardCoins": 50,
        "dueDate": 1702080000.0
    }
    try:
        response = requests.post(f"{BASE_URL}/tasks", json=task_data)
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.json()}\n")
    except Exception as e:
        print(f"   Error: {e}\n")
    
    # Test 3: Get all tasks (should now have one)
    print("3. Testing GET /tasks (after create)...")
    try:
        response = requests.get(f"{BASE_URL}/tasks")
        print(f"   Status: {response.status_code}")
        print(f"   Tasks: {json.dumps(response.json(), indent=2)}\n")
    except Exception as e:
        print(f"   Error: {e}\n")
    
    # Test 4: Get game state
    print("4. Testing GET /game/state...")
    try:
        response = requests.get(f"{BASE_URL}/game/state")
        print(f"   Status: {response.status_code}")
        print(f"   Game State: {response.json()}\n")
    except Exception as e:
        print(f"   Error: {e}\n")
    
    print("✅ API Tests Complete!")
    print("\nMake sure the Flask backend is running:")
    print("  python app.py")

if __name__ == "__main__":
    test_api()
