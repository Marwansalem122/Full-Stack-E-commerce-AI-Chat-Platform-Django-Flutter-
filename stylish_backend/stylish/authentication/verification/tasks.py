import logging
from celery import shared_task
from django.contrib.auth import get_user_model
from .emails import EmailService

User = get_user_model()
logger = logging.getLogger(__name__)

@shared_task(
    bind = True, 
    autoretry_for = (Exception,), 
    retry_kwargs = {'max_retries': 3}, 
    retry_backoff = True, 
    retry_back_off_max =60, 
    name = "authentication.verification.send_verification_email"
)
def send_verification_email_task(self, user_id: int):
    """celery task to send a verificaiton email."""
    try:
        user = User.objects.get(id=user_id)
        if not user.is_verified:
            logger.info(f"Executing verificaiton email task for user: {user.email}")
            EmailService.send_verification_email(user)
        else:
            logger.info(f"Skipping verification email for already verified user: {user.email}")
    except User.DoesNotExist:
        logger.warning(f"User with ID {user_id} not found. Cannot send verification email.")
        
    except Exception as e:
        logger.error(f"Failed to send verificaiton email for user {user_id} on attempt {self.request.retries}: {e}")
        raise e
    


@shared_task(
    bind = True, 
    autoretry_for = (Exception,), 
    retry_kwargs = {'max_retries': 3}, 
    retry_backoff = True, 
    retry_back_off_max =60, 
    name = "authentication.verification.send_password_reset_email"
)
def send_password_reset_email_task(self, user_id: int):
    """celery task to send a password reset  email."""
    try:
        user = User.objects.get(id=user_id)
        if not user.is_verified:
            logger.info(f"Executing password email task for user: {user.email}")
            EmailService.send_password_reset_email(user)
       
    except User.DoesNotExist:
        logger.warning(f"User with ID {user_id} not found. Cannot send password reset email.")
        
    except Exception as e:
        logger.error(f"Failed to send password reset email for user {user_id} on attempt {self.request.retries}: {e}")
        raise e