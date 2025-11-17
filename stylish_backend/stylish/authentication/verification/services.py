import logging
import traceback
from django.core.cache import cache
from django.contrib.auth import get_user_model

from authentication.verification.tasks import send_verification_email_task, send_password_reset_email_task
from authentication.verification.tokens import TokenVerifier
from authentication.core.jwt_utils import TokenManager
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError

User = get_user_model()
logger = logging.getLogger(__name__)

class EmailVerificationService:
    """service class to handle email verification operations"""
    @staticmethod
    def get_verification_cache_key(user_id):
        """Get standardized cache key for user verification status"""
        return f"user_verified_status_{user_id}"
    
    @staticmethod
    def check_verification_status(user):
        """check email verification status"""
        try:
            cache_key = EmailVerificationService.get_verification_cache_key(user.pk)
            cached_status = cache.get(cache_key)
            
            if cached_status is not None:
                logger.info(f"Using cached verification status for user {user.pk}: {cached_status}")
                return True, {
                    "success": True, 
                    "data": {'is_verified': cached_status}
                }, 200
                
                
            try:
                fresh_user = User.objects.get(pk = user.pk)
                is_verified = fresh_user.is_verified
                
                # Cache the result for future queries
                cache.set(cache_key, is_verified, timeout=3600)
                
                logger.info(f"Fetched verification status from DB fro user {user.pk}: {is_verified}")
                return True, {
                    "success": True,
                    "data": {"is_verified": is_verified}
                    
                }, 200
                
            except User.DoesNotExist:
                logger.error(f"User {user.pk} not found in database")
                return False, {
                    "success": False, 
                    "error": "User not found"
                }, 400
                
        except Exception as e:
            logger.error(f"check verification status error: {str(e)}")
            return True, {
                "success": True, 
                "data": {"is_verified": user.is_verified}, 
                "message": "Could not check latest status, using existing information"
            }, 200
            
            
    @staticmethod
    def verify_email(uidb64, token):
        """Verify email with token"""
        is_valid, user, error = TokenVerifier.verify_token(uidb64, token)
        
        if not is_valid:
            logger.warning(f"Invalid token verification attempt with uidb64: {uidb64}")
            return False, {"success": False, "error": error or "Invalid verification link.Please request a new one."}, 400
        
        try:
            from django.db import transaction
            with transaction.atomic():
                if not user.is_verified:
                    user.is_verified = True
                    user.save(update_fields=['is_verified'])
                    logger.info(f"Email verified for user {user.id} ({user.email}) via link")
                    
                else:
                    logger.info(f"Email verification attempt for already verified user: {user.id} ({user.email})")
                    
                    
            cache_key = EmailVerificationService.get_verification_cache_key(user.id)
            cache.set(cache_key, True, timeout=3600)
            logger.info(f"Updated verification cache for user {user.id} : set to True")
            return True, {
                "success": True, 
                "message": "Email verification successful."
            }, 200
            
        except Exception as e:
            logger.error(f"Error during verification: {str(e)}")
            return False, {
                "success": False, 
                "error": "An error occurred during verification. Please try again."
            }, 500
            
    @staticmethod
    def send_verification_email(user):
        """Send verification email to user"""
        try:
            if user.is_verified:
                return True, {"success": True, "message": "Email is already verified."}, 200
            
            
            rate_key = f"verification_email_{user.id}"
            if cache.get(rate_key):
                return False, {"success": False, "error": "Please wait before requesting another verification email."}, 429
            
            send_verification_email_task.delay(user.id)
            
            cache.set(rate_key, True, timeout=300)
            logger.info(f"Verification email task queued for {user.email}")
            return True, {
                "success": True, 
                "message": "A verification link has been sent to your email."
            }, 200
            
        except Exception as e:
            logger.error(f"Error queueing verification email: {str(e)}")
            return False, {
                "success": False, 
                "error": "Failed to send verification email. Please try again later."
            }, 500
            
        except Exception as e:
            logger.error(f"Send verification email error: {str(e)}")
            return False, {
                "success": False, 
                "error": "Failed to send verification email. Please try again later."
            }, 400
            
            
class PasswordResetService:
    """Service class to handle password reset operations"""
    @staticmethod
    def request_reset(email):
        """Request password reset for email"""
        try:
            if not email:
                return False, {
                    "success": False, 
                    "error": "Email is required"
                    
                }, 400
                
                
            rate_key= f"password_reset_{email}"
            if cache.get(rate_key):
                return True, {
                    "success": True, 
                    "message": "If an account exists with this email, a password reset link will be sent"
                }, 200
                
            try:
                user = User.objects.get(email = email)
                # Send email in the background using celery
                send_password_reset_email_task.delay(user.id)
                logger.info(f"Password reset email task queued for user {user.email}")
                
            except User.DoesNotExist:
                pass
            
            cache.set(rate_key, True, timeout= 300) 
            
            return True, {
                "success": True,
                "message": "If an account exists with this email, a password reset link will be sent."
            }, 200
            
        except Exception as e:
            logger.error(f"Password reset error: {str(e)}")
            return True, {
                "success": True, 
                "message": "If an account exists with this email, a password reset link will be sent."
            }, 200
            
    @staticmethod
    def confirm_reset(uidb64, token, new_password):
        """complete password reset with token and new password"""
        
        is_valid, user, error = TokenVerifier.verify_token(uidb64, token)
        
        if not is_valid:
            return False, {
                "success": False, 
                "error": error or "Invalid password reset link.Please request a new one."
            }, 400
            
        try:
            validate_password(new_password, user = user)
        except ValidationError as e:
            return False, {
                "success": False, 
                "error": ", ".join(e.messages)
            }, 400
            
        # update password
        user.set_password(new_password)
        user.save(update_fields=['password'])
        
        logger.info(f"Password reset completed for user {user.id} via link")
        
        TokenManager.blacklist_all_user_tokens(user.id)
        
        return True, {
            "success" : True,
            "message": "Password has been reset successfully. You can now log in with your new password."
        }, 200