# Stylish Backend - AI Agent Instructions

## Project Overview

**Stylish** is a Django REST Framework backend service with CORS support. Early-stage project with foundational structure in place but minimal implemented features.

- **Framework**: Django 5.2 + Django REST Framework
- **Database**: SQLite (default, development-ready)
- **Authentication App**: Present but not yet implemented (models/views/serializers empty)

## Architecture & Key Components

### Project Structure

```
stylish/                          # Django project (settings, URLs, WSGI)
  settings.py                     # Core Django config, DRF, CORS middleware
  urls.py                         # Root URL routing (currently only admin)
authentication/                   # First Django app (user auth placeholder)
  models.py                       # (empty - ready for User model extension)
  views.py                        # (empty - ready for auth endpoints)
  admin.py                        # (empty - ready for model registration)
```

### Middleware Order & CORS

**Critical**: `corsheaders.CorsMiddleware` is first in middleware list. This is correct per CORS best practices but must be maintained if adding security middleware.

```python
# Key installed apps:
- rest_framework          # DRF serializers, viewsets, permissions
- corsheaders             # CORS support for frontend
- django.contrib.auth    # Built-in User model available for extension
```

## Development Workflow

### Common Commands

```bash
# Migrations
python manage.py makemigrations
python manage.py migrate

# Development server
python manage.py runserver

# Django shell (useful for testing models)
python manage.py shell

# Create admin user
python manage.py createsuperuser
```

### Database

- Using SQLite (file: `db.sqlite3` in project root)
- Migrations stored in `authentication/migrations/`
- No environment-specific DB config yet (add to settings for production)

## Code Patterns & Conventions

### When Adding Models

1. Define in `authentication/models.py`
2. Register in `authentication/admin.py` for admin interface
3. Create migration: `python manage.py makemigrations`
4. Apply: `python manage.py migrate`

### When Adding API Endpoints

1. Create serializers alongside views (import `rest_framework.serializers`)
2. Use DRF's `ViewSet` or APIView classes
3. Add route in `stylish/urls.py` using `path()` from `django.urls`
4. Consider CORS implications if frontend calls these endpoints

### DRF Patterns

- **Serializers**: Convert models ↔ JSON
- **ViewSets**: Combine list/create/retrieve/update/destroy into one class
- **Permissions**: Use `rest_framework.permissions` for auth checks
- **Status Codes**: Use `rest_framework.status` constants (not magic numbers)

## Integration Points

### CORS Configuration

Currently permissive (empty `ALLOWED_HOSTS`, no explicit CORS config). Before production:

- Add `CORS_ALLOWED_ORIGINS` in settings.py
- Restrict `ALLOWED_HOSTS` to actual domain(s)

### Admin Interface

Available at `/admin/` - use for development/testing data entry. Remember to register new models in `authentication/admin.py`.

### Django Built-in Auth

Project includes `django.contrib.auth` (User, Group, Permission models). The `authentication` app should extend or customize this as needed.

## Important Settings Notes

- `SECRET_KEY` is hardcoded (change before any deployment)
- `DEBUG = True` (disable in production)
- `BASE_DIR` uses `pathlib.Path` for cross-platform compatibility

## Environment & dependencies (decouple)

- The project uses `python-decouple` to load secrets from environment variables in `stylish/settings.py` via `from decouple import config`.
- If your editor (e.g. VS Code/Pylance) reports "Import 'decouple' could not be resolved":

  - Ensure the workspace Python interpreter matches the environment where `python-decouple` is installed.
  - Install dependencies: `pip install -r requirements.txt` (a `requirements.txt` has been added to the repo).
  - If you prefer not to use `decouple`, replace `config('SECRET_KEY')` in `stylish/settings.py` with `os.environ.get('SECRET_KEY')` and update imports.

- A sample `.env.example` is added at the project root with the `SECRET_KEY` and `DEBUG` placeholders — copy it to `.env` for local development and keep secrets out of source control.

## Common Patterns to Avoid

- ❌ Adding models without migrations
- ❌ Forgetting to register models in admin.py if they need admin interface
- ❌ Hardcoding URLs - use `path()` names for reversibility
- ❌ Mixing logic into views - extract to serializer validators or model methods
