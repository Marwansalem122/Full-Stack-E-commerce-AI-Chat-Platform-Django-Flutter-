import logging
import traceback
from django.conf import settings
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.utils.http import urlsafe_base64_encode
from django.utils.encoding import force_bytes
from django.contrib.auth.tokens import default_token_generator
from django.contrib.auth import get_user_model

User  = get_user_model()
logger = logging.getLogger(__name__)

class EmailService:
    """Service for sending user-related emails"""
    @staticmethod
    def send_verification_email(user):
        """Send verification email to user with verification link"""
        try:
            #Generate verification token for link
            uid = urlsafe_base64_encode(force_bytes(user.pk))
            token = default_token_generator.make_token(user)
            
            # create verification link
            verify_url = f"{settings.FRONTEND_URL}/auth/email-verify?uid={uid}&token={token}"
            
            subject = f"{settings.APP_NAME} - Verify your email address"
            
            context = {'user': user, 'verify_url': verify_url, 'app_name': settings.APP_NAME}
            
            try:
                html_message = render_to_string('emails/verify_email.html', context)
                
                plain_message = f"""
                Hellow {user.email}, 
                Please verify your email address by clicking the link below:
                {verify_url}
                Thank you, 
                {settings.APP_NAME} Team
                """
                
            except Exception as template_error:
                logger.error(f"Template rendering error: {str(template_error)}")
                raise
            
            # send email
            from_email = settings.DEFAULT_FROM_EMAIL or settings.EMAIL_HOST_USER
            send_mail(
                subject= subject, 
                message = plain_message, 
                from_email = from_email, 
                recipient_list= [user.email], 
                html_message= html_message, 
                fail_silently= False
            )
            logger.info(f"Verification email sent to {user.email}")
            return True
        except Exception as e:
            logger.error(f"Error in verification email preparation for {user.email}: {str(e)}")
            raise e
                
    @staticmethod
    def send_password_reset_email(user):
        """Send password reset email to user with reset link"""
        try:
            #Generate verification token for link
            uid = urlsafe_base64_encode(force_bytes(user.pk))
            token = default_token_generator.make_token(user)
            
            # create verification link
            reset_url = f"{settings.FRONTEND_URL}/auth/password-reset-confirm?uid={uid}&token={token}"
            
            subject = f"{settings.APP_NAME} - Reset your  password"
            
            context = {'user': user, 'reset_url': reset_url, 'app_name': settings.APP_NAME}
            
            try:
                html_message = render_to_string('emails/password_reset.html', context)
                
                plain_message = f"""
                Hello {user.email}, 
               You requested to reset your password for your {settings.APP_NAME} account
               Please click the link below to reset your password.
               {reset_url}
               if your did't request this, please ignore this email. 
                Thank you, 
                {settings.APP_NAME} Team
                """
                
            except Exception as template_error:
                logger.error(f"Template rendering error: {str(template_error)}")
                raise
            
            # send email
            from_email = settings.DEFAULT_FROM_EMAIL or settings.EMAIL_HOST_USER
            send_mail(
                subject= subject, 
                message = plain_message, 
                from_email = from_email, 
                recipient_list= [user.email], 
                html_message= html_message, 
                fail_silently= False
            )
            logger.info(f"Password reset  email sent to {user.email}")
            return True
        except Exception as e:
            logger.error(f"Error sending password reset email :{user.email}: {str(e)}")
            raise e