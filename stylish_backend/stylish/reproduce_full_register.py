import os
import django
from unittest.mock import MagicMock

# Setup Django environment
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "stylish.settings")
django.setup()

from authentication.auth.services import AuthenticationService
from authentication.models import CustomUser

def test_registration():
    print("Testing AuthenticationService.register...")
    
    # Generate random email to avoid collision
    import random
    suffix = random.randint(1000, 9999)
    email = f"test_full_{suffix}@example.com"
    password = "StrongPassword123!"
    
    request = MagicMock()
    request.META = {'REMOTE_ADDR': '127.0.0.1'}
    
    try:
        success, response, status_code = AuthenticationService.register(
            email=email,
            password=password,
            first_name=f"Test{suffix}",
            last_name="User",
            phone_number="+1234567890",
            request_meta=request.META,
            request=request
        )
        
        print(f"Result: success={success}, status={status_code}")
        if not success:
            print("Response:", response)
            
    except Exception as e:
        print("CRITICAL FAILURE - Uncaught Exception:")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_registration()
