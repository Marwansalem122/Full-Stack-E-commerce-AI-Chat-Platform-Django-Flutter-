import logging
import traceback
from django.utils import timezone
from django.conf import settings
from django.core.cache import cache
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError

from authentication.serializers import UserSerializer
from authentication.core.jwt_utils import TokenManager
from authentication.models import CustomUser
from rest_framework_simplejwt.tokens import RefreshToken
from authentication.verification.tasks import send_verification_email_task
from django.contrib.auth import authenticate

logger=logging.getLogger(__name__)

class AuthenticationService:
  '''Service class to handle authentication-related business logic'''
  @staticmethod
  def register(email,password,phone_number=None,first_name=None,last_name=None,request_meta=None,request=None):
    '''Handle user registration with email and password'''
    if not email or not password:
      return False,{'success':False,'error':"Email and password are required."},400
    
    #Log registration attempt
    if request_meta:
      logger.info(f'Registration attempt from IP: {request_meta.get('REMOTE_ADDR')}')
    try:
      # check if email already exists
      if CustomUser.objects.filter(email=email).exists():
        return False,{'success':False,'error':'A user with this email already exists.'},400
      
      # valid password strength
      try:
        validate_password(password)
      except ValidationError as e:
        return False,{'success':False,'error':', '.join(e.messages)},400
      
      # Generate unique username
      username = email.split('@')[0]
      base_username = username
      counter = 1
      while CustomUser.objects.filter(username=username).exists():
        username = f"{base_username}{counter}"
        counter += 1

      # create new user
      user=CustomUser.objects.create_user(email=email,password=password,username=username,is_verified=False)
      if first_name:
        user.first_name=first_name
        user.save(update_fields=['first_name'])
      if last_name:
        user.last_name=last_name
        user.save(update_fields=['last_name'])
      if phone_number:
        user.phone_number=phone_number
        user.save(update_fields=['phone_number'])
       # Queue verification email for new users asynchronously
        if user.email and settings.REQUIRE_EMAIL_VERIFICATION:
            try:
              send_verification_email_task.delay(user.id)
              logger.info(f"Queued verification email for new user: {user.email}")
            except Exception as e:
                    logger.error(f"Failed to queue verification email task for user {user.id}: {str(e)}")
                    
            # Serialize user data with request context
            context = {}
            if request:
                context['request'] = request
            serializer = UserSerializer(user, context= context)
            
            # Generate tokes
            tokens = TokenManager.generate_token(user)
            
            logger.info(f"Registration successful for user: {user.email}")
            
            # Return successful response data
            return True, {
                "success": True, 
                "data" : {
                    'user': serializer.data, 
                    'tokens': tokens, 
                    'is_new_user': True, 
                    'email_verified': user.is_verified
                }
            }, 201
            
    except Exception as e:
            logger.error(f"Registration error: {str(e)}")
            return False, {
                "success": False,
                "error": "Registration failed. Please try again"
            }, 400
            
  @staticmethod
  def login(email, password, device_info = None, request_meta = None, request = None):
      """ Handle user login with email and password"""
      if not email or not password:
          return False, {"success": False, "error": "Email and password are required."}, 400
      
      if request_meta:
          logger.info(f"Login attempt from IP: {request_meta.get('REMOTE_ADDR')}, User-Agent : {request_meta.get('HTTP_USER_AGENT')}")
          
          
      try:
          # check for account lockout
          if cache.get(f"account_lockout: {email}"):
              logger.warning(f"Login attempt for locked account: {email}")
              return False, {
                  "success": False, 
                  "error": "Account temporarily locked due to multiple failed attempts. Try again later.", 
                  "lockout": True
              }, 403
              
          # check if user exists first
          try:
              user_exists = CustomUser.objects.filter(email = email).exists()
              if not user_exists:
                  logger.warning(f"Login attempt for non-existent email: {email}")
                  failed_atempts = cache.get(f"failed_logins:{email}", 0)+1
                  cache.set(f"failed_logins:{email}", failed_atempts, timeout=1800)
                  return False, {
                      "success": False, 
                      "error": "Invalid email or password"
                  }, 401
                  
          except Exception as user_check_error:
              logger.error(f"Error checking user existence : {str(user_check_error)}")
              return False, {
                  "success": False,
                  "error": "Database error occurred"
                  
              }, 500
              
          user = authenticate(username = email, password = password)
          
          if not user:
              # Increment failed login attempts
              failed_attempts = cache.get(f"failed_logins:{email}", 0) + 1
              cache.set(f"failed_logins:{email}", failed_attempts, timeout=1800)
              
              # Lock account after 5 failed attempts
              if failed_attempts >= 5:
                  cache.set(f"account_lockout: {email}", True, timeout=900)
                  logger.warning(f"Account locked due to failed attempts: {email}")
                  return False, {
                      "success": False, 
                      "error": "Account temporarily locked due to multiple failed attempts. Try again later.", 
                      "lockout": True
                  }, 403
                  
              logger.waring(f"Failed loging attempt for email: {email}")
              return False, {
                  "success": False, 
                  "error": "Invalid email or password"
              }, 401
              
          if not user.is_active:
              logger.warning(f"Login attempt for disable account: {email}")
              return False, {
                  "success": False, 
                  "error": "Account is disabled. Please contact support. "
              }, 403
              
              
          cache.delete(f"failed_logins:{email}")
          
          # serialize user data 
          try:
              context = {}
              if request:
                  context['request'] = request
                  
              serializer = UserSerializer(user, context = context)
          except Exception as serializer_error:
              logger.error(f"User serilization error: {str(serializer_error)}")
              return False, {
                  "success": False, 
                  "error": "User data serialization failed"
              }, 500
              
              
          # Generate tokens
          try: 
              tokens = TokenManager.generate_token(user)
          except Exception as token_error:
              logger.error(f"Token generation error: {str(token_error)}")
              return False, {
                  "success": False, 
                  "error": "Token generation failed"
              }, 500
              
          # Record login  with device information for audit trail
          try: 
              user.last_login = timezone.now()
              user.save(update_fields = ['last_login'])
              
          except Exception as save_error:
              logger.warning(f"Failed to update last_login: {str(save_error)}")
              
          # Log successful login
          if request_meta:
              logger.info(f"Login successful for user: {user.email} from IP: {request_meta.get('REMOTE_ADDR')}") 
                  
          # Return successful response data
          return True, {
              "success": True, 
              "data": {
                  'user': serializer.data, 
                  'tokens': tokens, 
                  'email_verified': user.is_verified, 
                  'verification_needed': not user.is_verified and settings.REQUIRE_EMAIL_VERIFICATION
              }
          }, 200
          
      except ValidationError as ve:
          logger.error(f"Validation error during login: {str(ve)}")
          return False, {
              "succes": False, 
              "error": f"Validation error: {str(ve)}"
          }, 400
          
      except Exception as e:
          logger.error(f"Unexpected login error: {str(e)}")
          logger.error(f"Login error tracebacke: {traceback.format_exc()}")  
          
          return False, {
              "success": False, 
              "error": "Authentication failed. Please try again"
          }, 500           
          
  @staticmethod
  def refresh_token(refresh_token):
      """Refresh an authentication token"""
      if not refresh_token:
          return False, {"success": False, "error": "Refresh token is required"}, 400
      
      try:
          tokens = TokenManager.refresh_tokens(refresh_token) 
          return True, {
              "success": True, 
              "data": {
                  'access_token': tokens['access_token'], 
                  "refresh_token": tokens['refresh_token'], 
                  'token_type': tokens['token_type'], 
                  'expires_in': tokens['expires_in']
              }
          }, 200
          
      except Exception as e:
          logger.error(f"Token refresh error: {str(e)}")
          return False, {
              "success": False, 
              "error": "An error occurred during token refresh"
          }, 500
      
  @staticmethod
  def validate_token(token, user):
      """Validate a token and check if it belongs to the user"""
      is_valid, user_id, token_type = TokenManager.validate_token(token)
      
      if not is_valid or user_id != user.id:
          logger.warning(f"Token validation failed: expected user {user.id}, got {user_id}")
          return False, {"success": False, "error": "Token validation failed"}, 401
      
      from authentication.verification.services import EmailVerificationService
      success, verification_response, _ = EmailVerificationService.check_verification_status(user)
      if not success:
          logger.error(f"Error checking verification status for user {user.id}")
          if_verified = user.is_verified
      else:
          is_verified = verification_response.get('data', {}).get('is_verified', user.is_verified)
          
      logger.info(f"Token validation retrieved verification status for user {user.id} : is_verified={is_verified}")
      
      return True, {
          "success": True, 
          "data": {
              'valid': True, 
              'user_id': user.id, 
              'email_verified': is_verified
          }
      }, 200
      
      
  @staticmethod
  def logout(user, refresh_token =None):
      """Handle user logout, invalidating tokens as needed"""
      if refresh_token:
          try: 
              token = RefreshToken(refresh_token)
              jti = token.get('jti')
              if jti:
                  TokenManager.blacklist_token(jti)
                  logger.info(f"Token blacklisted during logout: {jti}")
          except Exception as e:
              logger.warning(f"Error blacklisting token during logout: {str(e)}")
              
      logger.info(f"User logged out: {user.id}")
      return True, {
          "success": True, 
          "message": "Successfully logged out"
      }, 200