import os
from datetime import timedelta
from decouple import config
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent.parent


SECRET_KEY = config('SECRET_KEY')

DEBUG = config('DEBUG', default = False, cast=bool)

ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='*', cast=lambda v:[s.strip() for s in v.split(',')])

# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    #Third party apps
      'corsheaders',
      'rest_framework',
    #Local apps
    'authentication'
    
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'stylish.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [os.path.join(BASE_DIR, 'templates')],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'stylish.wsgi.application'


# Database
# https://docs.djangoproject.com/en/5.2/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME':config('DB_NAME'),
        'USER':config('DB_USER'),
        'PASSWORD': config('DB_PASSWORD'), 
        'HOST': config('DB_HOST'), 
        'PORT': config('DB_PORT', cast = int),
    }
}


# Password validation
# https://docs.djangoproject.com/en/5.2/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization
# https://docs.djangoproject.com/en/5.2/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/5.2/howto/static-files/

STATIC_URL = 'static/'
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# Default primary key field type
# https://docs.djangoproject.com/en/5.2/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'



...

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=15),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=14),
    "ROTATE_REFRESH_TOKENS": True,
    "BLACKLIST_AFTER_ROTATION": True,

    "ALGORITHM": "HS256",
    "SIGNING_KEY": SECRET_KEY,
   

    "AUTH_HEADER_TYPES": ("Bearer",),
    "USER_ID_FIELD": "id",
    "USER_ID_CLAIM": "user_id",
   
    "AUTH_TOKEN_CLASSES": ("rest_framework_simplejwt.tokens.AccessToken",),
    "TOKEN_TYPE_CLAIM": "token_type",

}

#JWT Cookie Settings
JWT_COOKIE_SECURE = config('JWT_COOKIE_SECURE', default = False, cast = bool)
JWT_COOKIE_NAME = 'refresh_token'
JWT_COOKIE_SAMESITE = 'Lax' # Use 'Strict' if possible

#cache settings
CACHED={
    'default':{
        'BACKEND':'django_redis.cache.RedisCache',
        'LOCATION':config('REDIS_URL',default='redis://127.0.0.1:6379/1'),
        'OPTIONS':{
            'CLIENT_CLASS':'django_redis.client.Default',
            'SOCKET_CONNECT_TIMEOUT':5,
            'SOCKET_TIMEOUT':5,
            'IGNORE_EXCEPTIONS':True
        },
        'TIMEOUT':3600,
    }
}

#REST Framework settings
REST_FRAMEWORK={
    'DEFAULT_AUTHENTICATION_CLASSES':('rest_framework_simplejwt.authentication.JWTAuthentication'),
    'DEFAULT_PERMISSION_CLASSES':('rest_framework.permissions.IsAuthenticated',),
    'DEFAULT_THROTTLE_CLASSES':{
        'rest_framework.throttling.AnonRateThrottle',
         'rest_framework.throttling.UserRateThrottle',
    }
}

CELERY_TIMEZONE = "Africa/Cairo"
CELERY_TASK_TRACK_STARTED = True
CELERY_TASK_TIME_LIMIT = 30*60
CELERY_RESULT_BACKEND = 'redis://localhost:6379/0'
CELERY_BROKER_URL = 'redis://localhost:6379/0'
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'

FRONTEND_URL ='http://127.0.0.1/api'
# Email verification settings
REQUIRE_EMAIL_VERIFICATION = True
EMAIL_VERIFICATION_TIMEOUT = 3600*24*3  # 3 days verification link
APP_NAME = 'stylish'
DEFAULT_FROM_EMAIL = 'stylish <noreply@stylishapp.come>'


AUTH_USER_MODEL = 'authentication.CustomUser'

# Email settings
#For Gmail SMTP
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = config('EMAIL_HOST_USER', default = 'your-gmail@gmail.com')
EMAIL_HOST_PASSWORD = config('EMAIL_HOST_PASSWORD', default = '')


# cors configurations
CORS_ALLOW_CREDENTIALS = True

# Development vs Production CORS settings
if DEBUG:
    # Allow all origins in development for Flutter web testing
    CORS_ALLOW_ALL_ORIGINS = True
    CORS_ALLOW_HEADERS = [
        'accept', 
        'accept-encoding', 
        'authorization', 
        'content-type',
        'dnt', 
        'origin', 
        'user-agent', 
        'x-csrftoken', 
        'x-requested-with',
    ]
else:
    # Production settings - specific origins only
    CORS_ALLOW_ALL_ORIGINS = True
    CORS_ALLOWED_ORIGINS = config(
        'CORS_ALLOWED_ORIGINS', 
        default = 'https://yourdomain.com', 
        cast = lambda v: [s.strip() for s in v.split(',')]
    )
    
# Allow specific methods
CORS_ALLOWED_METHODS = [
    'DELETE', 
    'GET', 
    'OPTIONS', 
    'PATCH', 
    'POST', 
    'PUT',
]

# CORS preflight cache
CORS_PREFLIGHT_MAX_AGE = 86400



OPENROUTER_API_KEY = config('OPENROUTER_API_KEY', default='<YOUR_OPENROUTER_API_KEY>')
OPENROUTER_BASE_URL = "https://openrouter.ai/api/v1"
DEEPSEEK_MODEL = "deepseek/deepseek-r1-0528:free"
CHAT_RATE_LIMIT_PER_MINUTE = int(os.getenv('CHAT_RATE_LIMIT_PER_MINUTE', '10'))
CHAT_RATE_LIMIT_PER_HOUR = int(os.getenv('CHAT_RATE_LIMIT_PER_HOUR', '100'))
CHAT_CACHE_TTL = int(os.getenv('CHAT_CACHE_TTL', '300'))
CHAT_MAX_QUERY_LENGTH = int(os.getenv('CHAT_MAX_QUERY_LENGTH', '1000'))
OPENAI_TIMEOUT = float(os.getenv('OPENAI_TIMEOUT', '30.0'))
OPENAI_MAX_RETRIES = int(os.getenv('OPENAI_MAX_RETRIES', '3'))
OPENAI_MODEL = os.getenv('OPENAI_MODEL', 'gpt-3.5-turbo')
CIRCUIT_BREAKER_FAILURE_THRESHOLD = int(os.getenv('CIRCUIT_BREAKER_FAILURE_THRESHOLD', '5'))
CIRCUIT_BREAKER_RECOVERY_TIMEOUT = int(os.getenv('CIRCUIT_BREAKER_RECOVERY_TIMEOUT', '60'))
REDIS_MAX_CONNECTIONS = int(os.getenv('REDIS_MAX_CONNECTIONS', '20'))