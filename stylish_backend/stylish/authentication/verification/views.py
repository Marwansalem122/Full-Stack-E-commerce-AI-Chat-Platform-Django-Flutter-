import logging
import traceback
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.throttling import AnonRateThrottle, UserRateThrottle

from authentication.core.base_view import BaseAPIView
from authentication.core.response import standardized_response

from .services import EmailVerificationService, PasswordResetService, User

logger = logging.getLogger(__name__)

class VerifyEmailView(BaseAPIView):
    """Endpoint for verifying email with token"""
    permission_classes = [AllowAny]
    throttle_classes = [AnonRateThrottle]
    
    def post(self, request):
        try:
            uidb64 = request.data.get('uid') or request.query_params.get('uid')
            token = request.data.get('token') or request.query_params.get('token')
            
            if not uidb64 or not token:
                return Response(standardized_response(success=False, error = "Missing required fields"), status = status.HTTP_400_BAD_REQUEST)
            
            success, response_data, status_code = EmailVerificationService.verify_email(uidb64=uidb64, token= token)
            return Response(
                standardized_response(**response_data), 
                status = status_code
                
            )
            
        except Exception as e:
            logger.error(f"Email verification error: {str(e)}")
            logger.error(traceback.format_exc())
            return Response(
                standardized_response(
                    success= False, 
                    error = "Email verification failed. Please try again."
                ), 
                status= status.HTTP_400_BAD_REQUEST
            )
            
    def get(self, request):
        return self.post(request)
    
    

class SendVerificationEmailView(BaseAPIView):
    """Endpoint for sending verification email"""
    permission_classes = [IsAuthenticated]
    throttle_classes = [UserRateThrottle]
    
    def post(self, request):
        try:
            success, response_data, status_code = EmailVerificationService.send_verification_email(request.user)
            
            return Response(
                standardized_response(**response_data), status = status_code
            )
            
        except Exception as e:
            logger.error(f"Send verification email error: {str(e)}")
            logger.error(traceback.format_exc())
            
            return Response(
                standardized_response(success = False, error = "Failed to send verification email. Please try again later."), status= status.HTTP_400_BAD_REQUEST
            )
            

class CheckVerificationStatusView(BaseAPIView):
    """Endpoint for checking verification status"""
    permission_classes = [IsAuthenticated]
    throttle_classes = [UserRateThrottle]
    
    def get(self, request):
        try: 
            success, response_data, status_code = EmailVerificationService.check_verification_status(request.user)
            
            logger.info(f"Verification status check for user {request.user.pk}: {response_data.get('data', {}).get('is_verified')}")
            return Response(
                standardized_response(**response_data), status = status_code
            )
            
        except Exception as e:
            logger.error(f"Check verification status error: {str(e)}")
            logger.error(traceback.format_exc())
            
            return Response(
                standardized_response(
                    success= True, 
                    data = {'is_verified': request.user.is_verified}, 
                    message= "Could not check latest status, using existing information"
                ), status= status.HTTP_200_OK
            )
            

class PasswordResetView(BaseAPIView):
    """Endpoint for requesting password reset"""
    permission_classes = [AllowAny]
    throttle_classes = [AnonRateThrottle]
    
    def post(self, request):
        try:
            email = request.data.get('email')
            
            if not email:
                return Response(
                    standardized_response(
                        success= False, 
                        error = "Email is required"
                    ), status = status.HTTP_400_BAD_REQUEST
                )
                
            success, response_data, status_code = PasswordResetService.request_reset(email=email)
            return Response(
                standardized_response(**response_data), 
                status= status_code
                
            )
            
        except Exception as e:
            logger.error(f"Password reset error: {str(e)}")
            logger.error(traceback.format_exc())
            
            return Response(
                standardized_response(success= True, message= "If an account exists with this email, a password reset link will be sent."), status = status.HTTP_200_OK
            )
            
            
class ConfirmPasswordResetView(BaseAPIView):
    """Endpoint for confirming password reset with token"""
    permission_classes = [AllowAny]
    throttle_classes = [AnonRateThrottle]
    def post(self, request):
        try:
            uidb64 = request.data.get('uid') or request.query_params.get('uid')
            token = request.data.get('token') or request.query_params.get('token')
            new_password = request.data.get('new_password')
            
            if not uidb64 or not token or not new_password:
                return Response(
                    standardized_response(
                        success=False, 
                        error = "Missing required fields"
                    ), status= status.HTTP_400_BAD_REQUEST
                )
                
            success, response_data, status_code = PasswordResetService.confirm_reset(uidb64=uidb64, token = token, new_password=new_password)
            return Response(
                standardized_response(**response_data), status = status_code
            ) 
            
        except Exception as e:
            logger.error(f"Password reset confirmation error: {str(e)}")
            logger.error(traceback.format_exc())
            
            return Response (
                standardized_response(
                    success= False, 
                    error = "Password reset failed.Please try again."
                ), status = status.HTTP_400_BAD_REQUEST
            )
            
            