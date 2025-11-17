from django.urls import path
from .auth.views import (
    UserLoginView, 
    UserRegistrationView, 
    TokenRefreshView, 
    ValidateTokenView, 
    LogoutView
)

from .profile.views import UserProfileView
from .verification.views import (
    VerifyEmailView, 
    SendVerificationEmailView, 
    CheckVerificationStatusView, 
    PasswordResetView, 
    ConfirmPasswordResetView
)

app_name = 'authentication'

urlpatterns = [
    # Auth routes 
    path('login/', UserLoginView.as_view(), name = 'login'), 
    path('register/', UserRegistrationView.as_view(), name = 'register'),
    path('token/refresh/', TokenRefreshView.as_view(), name = 'token_refresh'), 
    path('token/validate/', ValidateTokenView.as_view(), name = 'validate_token'), 
    path('logout/', LogoutView.as_view(), name = 'logout'), 
    
    # Profile routes
    path('profile/', UserProfileView.as_view(), name = 'logout'), 
    
    # Verification routes
    path('email-verify/', VerifyEmailView.as_view(), name = 'verify_email'), 
    path('send-verification/', SendVerificationEmailView.as_view(), name = 'send_verification'), 
    path('verification-status/', CheckVerificationStatusView.as_view(), name = 'check_verification'), 
    path('password-reset/', PasswordResetView.as_view(), name = 'password_reset'), 
    path('password-reset-confirm/', ConfirmPasswordResetView.as_view(), name = 'confirm_password_reset'),
]
