"""
Backend Setup Verification
Checks if backend is properly installed and configured
"""

import sys
import os
from pathlib import Path


def check_python_version():
    """Check Python version"""
    version = sys.version_info
    required = (3, 8)
    
    if version >= required:
        print(f"[OK] Python {version.major}.{version.minor}.{version.micro} (Required: 3.8+)")
        return True
    else:
        print(f"[ERROR] Python {version.major}.{version.minor}.{version.micro} (Required: 3.8+)")
        return False


def check_backend_structure():
    """Check backend directory structure"""
    backend_path = Path(__file__).parent
    
    required_dirs = [
        'database',
        'models',
        'api',
        'utils',
        'tests'
    ]
    
    required_files = {
        'database': ['__init__.py', 'db_init.py', 'dao.py'],
        'models': ['__init__.py', 'models.py'],
        'api': ['__init__.py', 'services.py'],
        'utils': ['__init__.py', 'helpers.py'],
        'tests': ['__init__.py', 'test_backend.py', 'interactive_tester.py', 'quick_test.py'],
        '': ['app.py', 'config.ini', 'requirements.txt', 'README.md', 'QUICKSTART.md']
    }
    
    all_ok = True
    
    # Check directories
    print("\nBackend Structure:")
    for dir_name in required_dirs:
        dir_path = backend_path / dir_name
        if dir_path.is_dir():
            print(f"  [OK] {dir_name}/")
        else:
            print(f"  [ERROR] {dir_name}/ (MISSING)")
            all_ok = False
    
    # Check files
    print("\nRequired Files:")
    for location, files in required_files.items():
        for file_name in files:
            file_path = backend_path / location / file_name if location else backend_path / file_name
            rel_path = f"{location}/{file_name}" if location else file_name
            
            if file_path.exists():
                print(f"  [OK] {rel_path}")
            else:
                print(f"  [ERROR] {rel_path} (MISSING)")
                all_ok = False
    
    return all_ok


def check_imports():
    """Check if all imports work"""
    print("\nImport Check:")
    
    try:
        sys.path.insert(0, str(Path(__file__).parent))
        
        # Try importing core modules
        modules = [
            ('database.db_init', 'DatabaseManager'),
            ('database.dao', 'GameStateDAO'),
            ('models.models', 'GameState'),
            ('api.services', 'GameService'),
            ('utils.helpers', 'DateUtil'),
        ]
        
        all_ok = True
        for module_name, class_name in modules:
            try:
                module = __import__(module_name, fromlist=[class_name])
                cls = getattr(module, class_name)
                print(f"  [OK] {module_name}.{class_name}")
            except Exception as e:
                print(f"  [ERROR] {module_name}.{class_name} - {str(e)[:50]}")
                all_ok = False
        
        return all_ok
    
    except Exception as e:
        print(f"  [ERROR] Error checking imports: {e}")
        return False


def check_database_init():
    """Check if database can be initialized"""
    print("\nDatabase Initialization Check:")
    
    try:
        sys.path.insert(0, str(Path(__file__).parent))
        from database.db_init import DatabaseManager
        
        # Use a test database
        DatabaseManager.DB_NAME = 'setup_test.db'
        DatabaseManager.DB_PATH = Path(__file__).parent / 'setup_test.db'
        
        DatabaseManager.init_database()
        
        test_db_path = Path(__file__).parent / 'setup_test.db'
        if test_db_path.exists():
            print(f"  [OK] Database initialization successful")
            print(f"    Location: {test_db_path}")
            
            # Clean up
            try:
                test_db_path.unlink()
                print(f"  [OK] Cleanup successful")
            except:
                pass
            
            return True
        else:
            print(f"  [ERROR] Database not created at {test_db_path}")
            return False
    
    except Exception as e:
        print(f"  [ERROR] Database initialization failed: {e}")
        import traceback
        traceback.print_exc()
        return False


def print_summary(results):
    """Print summary of checks"""
    print("\n" + "="*60)
    print("  BACKEND SETUP VERIFICATION SUMMARY")
    print("="*60)
    
    checks = [
        ("Python Version", results[0]),
        ("Backend Structure", results[1]),
        ("Module Imports", results[2]),
        ("Database Initialization", results[3])
    ]
    
    all_passed = all(r for r in results)
    
    for check_name, passed in checks:
        status = "[OK] PASS" if passed else "[ERROR] FAIL"
        print(f"{status:8} {check_name}")
    
    print("="*60)
    
    if all_passed:
        print("\n[OK] Backend setup is complete and verified!")
        print("\nNext steps:")
        print("  1. Run quick test: python tests/quick_test.py")
        print("  2. Try interactive tester: python tests/interactive_tester.py")
        print("  3. Run full tests: python tests/test_backend.py")
        print("  4. Read TESTING_GUIDE.md for more information")
        return 0
    else:
        print("\n[ERROR] Some checks failed. Please fix the issues above.")
        print("\nTroubleshooting:")
        print("  - Ensure you're in the backend directory")
        print("  - Check Python version (3.8+ required)")
        print("  - Verify all files are present")
        print("  - Check file permissions")
        return 1


def main():
    """Run all checks"""
    print("\n" + "="*60)
    print("  MONEY MANSION BACKEND SETUP VERIFICATION")
    print("="*60)
    
    results = [
        check_python_version(),
        check_backend_structure(),
        check_imports(),
        check_database_init()
    ]
    
    exit_code = print_summary(results)
    sys.exit(exit_code)


if __name__ == '__main__':
    main()
