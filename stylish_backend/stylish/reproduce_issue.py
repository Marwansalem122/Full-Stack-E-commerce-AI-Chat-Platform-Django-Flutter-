import os
import django
from datetime import timedelta

# Setup Django environment
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "stylish.settings")
django.setup()

from authentication.core.jwt_utils import TokenManager

class MockUser:
    def __init__(self):
        self.id = 1
        self.username = "testuser"
        self.email = "test@example.com"
        self.is_staff = False
        self.is_verified = True

def test_token_generation():
    print("Testing TokenManager.generate_token...")
    user = MockUser()
    try:
        tokens = TokenManager.generate_token(user)
        print("Success!", tokens)
    except Exception as e:
        print("Failed!")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_token_generation()
