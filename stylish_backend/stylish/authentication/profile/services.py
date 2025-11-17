import base64 
import json
import logging
import os
from django.core.files.base import ContentFile
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError

from authentication.core.jwt_utils import TokenManager
from authentication.serializers import UserSerializer

logger = logging.getLogger(__name__)

class ProfileService:
    """Service class to handle user profile operations"""
    
    @staticmethod
    def get_profile(user, request = None):
        """Get user profile data"""
        context = {'request': request} if request else {}
        serializer = UserSerializer(user, context = context)
        return serializer.data
    
    @staticmethod
    def update_profile(user, data, files = None, request =None):
        """Update user profile data"""
        try: 
            if files and 'profile_picture' in files:
                ProfileService._process_profile_picture_file(user, files['profile_picture'])
                
            elif 'image_data' in data:
                ProfileService._process_image_data(user, data.get('image_data'))
                
            # Handle password change if provided
            if 'current_password' in data and 'new_password' in data:
                result = ProfileService._process_password_change(user, data.get('current_password'), data.get('new_password'))
                if not result['success']:
                    return False, {
                        "success": False, 
                        "error": result['error']
                    }, 400
                    
                    
            safe_data = {k: v for k, v in data.items() if k not in ['profile_picture', 'image_data', 'current_password', 'new_password']}
            context = {'request': request} if request else {}
            serializer = UserSerializer(user, data = safe_data, partial = True, context = context)
            
            if serializer.is_valid():
                serializer.save()
                updated_user = type(user).objects.get(pk = user.pk)
                updated_serializer = UserSerializer(updated_user, context = context)
                
                return True, {
                    "success": True, 
                    "data": updated_serializer.data, 
                    "message": "Profile updated successfully"
                }, 200
                
            return False, {
                "success": False, 
                "error": serializer.errors
            }, 400
            
        except Exception as e:
            logger.error(f"Profile update error: {str(e)}")
            return False, {
                "success": False, 
                "error": "Failed to update profile"
            }, 400
                
                
    @staticmethod
    def _process_password_change(user, current_password, new_password):
        """Process password change request"""
        # Verify current password
        if not user.check_password(current_password):
            return {"success": False, "error": "Current password is incorrect"}
        
        # Validate new password
        try:
            validate_password(new_password, user = user)
        except ValidationError as e:
            return {'success': False, 'error': ', '.join(e.messages)}
        
        user.set_password(new_password)
        user.save(update_fields = ['password'])
        
        logger.info(f"Password changed for user {user.id}")
        
        # Invalidate all existing refresh tokens for security
        TokenManager.blacklist_all_user_tokens(user.id)
        return {'success': True}
    
    @staticmethod
    def _process_image_data(user, image_data):
        """Process base64 image data"""
        try:
            # Try to parse as JSON array first
            try:
                image_list = json.loads(image_data)
                if isinstance(image_list, list) and len(image_list) > 0:
                    image_info = image_list[0]
                    data_url = image_info.get('data')
                    
                else:
                    data_url = f"data:image/jpeg;base64,{image_data}"
            except json.JSONDecodeError:
                data_url = f"data:image/jpeg;base64,{image_data}"
                
            # Process the data_url
            if ';base64' in data_url:
                format_part, imgstr = data_url.split(';base64,')
                # Extract file extension, default to jpeg
                try:
                    ext = format_part.split('/')[-1].lower()
                    if ext not in ['jpeg', 'jpg', 'png', 'gif', 'webp']:
                        ext = 'jpeg'
                except:
                    ext = 'jpeg'
                    
                # Create a contentFile from decoded base64
                data = ContentFile(base64.b64decode(imgstr), name = f"profile_{user.id}.{ext}")
                if user.profile_picture:
                    try:
                        if os.path.isfile(user.profile_picture.path):
                            os.remove(user.profile_picture.path)
                            
                    except (ValueError, OSError) as e:
                        logger.warning(f"Could not remove old profile picture: {e}")
                        
                user.profile_picture = data
                user.save(update_fields = ['profile_picture'])
                logger.info(f"Profile picture updated from base64 for  user {user.id}")
                return True
            
            else:
                raise ValueError("Invalid image data format - missing base64 prefix")
            
        except Exception as e:
            logger.error(f"Error processing image data {str(e)}")
            raise
                  
                
    @staticmethod
    def _process_profile_picture_file(user, file):
        """Process uploaded profile picture file"""
        if user.profile_picture:
            try:
                if os.path.isfile(user.profile_picture.path):
                    os.remove(user.profile_picture.path)
                    
            except (ValueError, OSError) as e:
                logger.warning(f"Could not remove old profile picture: {e}")
                
        # Set new profile picture
        user.profile_picture = file
        user.save(update_fields = ['profile_picture'])
        logger.info(f"Profile picture updated for user {user.id}")
        return True
    