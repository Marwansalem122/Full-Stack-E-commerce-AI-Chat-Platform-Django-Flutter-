import logging
import traceback
from django.utils import timezone
from django.conf import settings
from django.middleware.csrf import get_token
from datetime import timedelta

from rest_framework import status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated,AllowAny
from rest_framework.throttling import AnonRateThrottle,UserRateThrottle
from rest_framework_simplejwt.tokens import RefreshToken

from authentication.core.base_view import BaseAPIView
from authentication.core.response import standardized_response
from .services import AuthenticationService

logger=logging.getLogger(__name__)

class UserRegistrationView(BaseAPIView):
    permission_classes = [AllowAny]
    throttle_classes = [AnonRateThrottle]
    
    def post(self, request):
        try: 
            email = request.data.get('email')
            password = request.data.get('password')
            phone_number = request.data.get('phone_number')
            first_name = request.data.get('first_name')
            last_name = request.data.get('last_name')
            
            success, response_data, status_code = AuthenticationService.register(
                email = email, 
                password = password,
                phone_number= phone_number, 
                first_name= first_name, 
                last_name = last_name, 
                request_meta= request.META, 
                request = request
            )
            
            # create response object
            response = Response(
                standardized_response(**response_data), status=status_code
            )
            
            if success and status_code in (200, 201) and settings.JWT_COOKIE_SECURE:
                tokens = response_data.get(
                    'data', {}
                    ).get('tokens', {})
                if 'refresh_token' in tokens and 'refresh_expires_in' in tokens:
                    response.set_cookie(
                        key = settings.JWT_COOKIE_NAME, 
                        value = tokens['refresh_token'], 
                        expires = timezone.now() +
                         timedelta(seconds=['refresh_expires_in']), 
                        secure = True, 
                        httponly=True, 
                        samesite= 'Strict', 
                        path = '/', 
                        domain = settings.SESSION_COOKIE_DOMAIN
                    )
                    
            # set CSRF token
            if success: 
                get_token(request)
                
            return response
        except Exception as e:
            logger.error(f"Registration error: {str(e)}")
            logger.error(traceback.format_exc())
            return Response(standardized_response(
                success = False,
                error = "Registration failed. Please try again."
                ),
             status= status.HTTP_400_BAD_REQUEST)

class UserLoginView(BaseAPIView):
    permission_classes = [AllowAny]
    throttle_classes = [AnonRateThrottle]
    
    def post(self, request):
        try: 
            email = request.data.get('email')
            password = request.data.get('password')
            device_info = request.data.get('device_info', {})
            
            success, response_data, status_code  = AuthenticationService.login(
                email = email, 
                password = password, 
                device_info = device_info, 
                request_meta= request.META, 
                request = request
            )
            
            # create response object
            response = Response(
                standardized_response(**response_data), status=status_code
            )
            
            if success :
                tokens = response_data.get(
                    'data', {}
                    ).get('tokens', {})
                refresh_token = tokens.get('refresh_token')
                if refresh_token:
                    response.set_cookie(
                        key = settings.JWT_COOKIE_NAME, 
                        value = refresh_token, 
                        expires = timezone.now() +
                        settings.SIMPLE_JWT['REFRESH_TOKEN_LIFETIME'], 
                        
                        secure = settings.JWT_COOKIE_SECURE, 
                        httponly=True, 
                        samesite= settings.JWT_COOKIE_SAMESITE,
                        path = '/', 
                    )
                    del response.data['data']['tokens']['refresh_token']
                    
                
            return response
        except Exception as e:
            logger.error(f"Login error: {str(e)}")
            logger.error(traceback.format_exc())
            return Response(
                standardized_response(
                    success = False,
                    error = "An unexpected error occurred. Please try again."
                    ), status= status.HTTP_500_INTERNAL_SERVER_ERROR
                )
        

class TokenRefreshView(BaseAPIView):
    """API endpoint for refreshing JWT tokens"""
    permission_classes = [AllowAny]
    throttle_classes = [AnonRateThrottle]
    
    def post(self, request):
        try:
            refresh_token = request.COOKIES.get(settings.JWT_COOKIE_NAME)
            
            if not refresh_token:
                return Response(
                    standardized_response(
                        success= False,
                        error = "Refresh token not found in cookie."
                        ), status= status.HTTP_401_UNAUTHORIZED
                    )
            success, response_data , status_code = AuthenticationService.refresh_token(refresh_token)
            
            response = Response(
                standardized_response(**response_data), 
                status = status_code
                )
            
            if success :
                tokens = response_data.get('data', {})
                new_refresh_token = tokens.get('refresh_token')
                if new_refresh_token:
                    response.set_cookie(
                        key = settings.JWT_COOKIE_NAME, 
                        value = new_refresh_token, 
                        expires = timezone.now() + 
                        settings.SIMPLE_JWT['REFRESH_TOKEN_LIFETIME'], 
                        
                        secure = settings.JWT_COOKIE_SECURE, 
                        httponly=True, 
                        samesite= settings.JWT_COOKIE_SAMESITE,
                       
                    )
                    del response.data['data']['refresh_token']
                    
         
            return response
        except Exception as e:
            logger.error(f"Token refresh error: {str(e)}")
            logger.error(traceback.format_exc())
            return Response(
                standardized_response(
                    success = False,
                    error = "An  error occurred during token refresh."
                    ), status= status.HTTP_500_INTERNAL_SERVER_ERROR
                )
        
        
class ValidateTokenView(BaseAPIView):
    """Token validation"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        user = request.user
        
        # Get token from Authorization header
        auth_header = request.META.get('HTTP_AUTHORIZATION', '')
        if auth_header.startswith('Bearer '):
            token = auth_header.split(' ')[1]
        
            success, response_data, status_code = AuthenticationService.validate_token(token, user)
            return Response(
                standardized_response(**response_data), 
                status = status_code
            )
            
        return Response(
            standardized_response(success = False, error = "No token provided"), 
            status = status.HTTP_400_BAD_REQUEST
        )
    

class LogoutView(BaseAPIView):
    """Logout endpoint that invalidates tokens"""
    permission_classes = [IsAuthenticated]
    def post(self, request):
        try:
            user = request.user
            refresh_token = None
            
            if 'refresh_token' in request.data:
                refresh_token = request.data.get('refresh_token')
                
            elif settings.JWT_COOKIE_SECURE:
                refresh_token = request.COOKIES.get(settings.JWT_COOKIE_NAME)
               
            success, response_data , status_code = AuthenticationService.logout(user, refresh_token)
            
            response = Response(standardized_response(**response_data), status = status_code)
            
            if settings.JWT_COOKIE_SECURE:
                response.delete_cookie(
                    key = settings.JWT_COOKIE_NAME, 
                    path = '/', 
                    domain = settings.SESSION_COOKIE_DOMAIN
                ) 
                
            return response
        
        except Exception as e:
            logger.error(f"Logout error: {str(e)}")
            logger.error(traceback.format_exc())
            
            response =Response(
                standardized_response(
                    success = True,
                    message = "Logout processed"
                    ),
                status = status.HTTP_200_OK)
            
            if settings.JWT_COOKIE_SECURE:
                response.delete_cookie(
                    key = settings.JWT_COOKIE_NAME, 
                    path = '/', 
                    domain = settings.SESSION_COOKE_DOMAIN
                ) 
                
            return response