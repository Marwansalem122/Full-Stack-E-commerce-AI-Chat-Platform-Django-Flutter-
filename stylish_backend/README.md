# 🖧 Stylish Backend

### Django REST API • AI Services • Background Processing

The **Stylish Backend** is a **production-ready Django REST Framework (DRF)** application that powers the Stylish E-Commerce Admin Dashboard.

It is responsible for authentication, business logic, inventory management, background processing, and AI-powered analytics consumed by the Flutter admin frontend.

This backend is structured to reflect **real-world, enterprise-grade Django applications**.

---

## 📁 Project Structure

```
stylish_backend/
│
├── stylish/ # Django project root
│ ├── .github/ # CI/CD workflows and GitHub config
│ ├── authentication/ # Authentication app (users, JWT, auth logic)
│ ├── media/ # Uploaded media files
│ ├── templates/ # Email & server-side templates
│ │
│ ├── stylish/ # Django settings package
│ │ ├── settings.py
│ │ ├── urls.py
│ │ ├── celery.py
│ │ ├── .env
│ │ ├── asgi.py
│ │ └── wsgi.py
│ │
│ ├── manage.py # Django management entry point
│ ├── reproduce_issue.py # Debug / reproduction scripts
│ └── reproduce_full_register.py
│
├── stylishenv/ # Python virtual environment
│ ├── Scripts/
│ ├── Lib/
│ └── pyvenv.cfg
│
└── README.md
```

---

---

## 🧱 Architecture Overview

The backend follows a **Service-Oriented / Modular Django Architecture** with a strong focus on:

- Separation of concerns
- Testability
- Scalability
- Clean API boundaries

### Architectural Principles

- Django apps represent **business domains**
- Authentication logic isolated in its own app
- Views remain thin and orchestration-focused
- Business rules encapsulated in reusable services
- Ready for AI & background task integration

---

## ✨ Core Features

### 🔐 Authentication & Security

- Custom authentication system
- JWT-based authentication (access & refresh tokens)
- Secure user registration & login
- Email-based workflows using templates
- Token-protected API endpoints

---

### 🛒 E-Commerce Business Logic

- Product & inventory management foundations
- Domain-driven app structure
- Validation and business rules at the service level
- Media handling for product assets

---

### 🤖 AI & Analytics (Planned / Integrated)

- Large Language Model (LLM) integration
- Model Context Protocol (MCP)
- Secure AI interaction with application data
- Natural-language analytics and insights

---

### ⚙️ Background Processing

- Designed for Celery integration
- Redis-ready architecture
- Async workflows (emails, analytics, AI tasks)

---

### 🚀 Performance & Scalability

- Modular Django apps
- Optimized query patterns
- Media separation
- Environment-based configuration readiness

---

## 🧠 Technologies Used

- Python
- Django
- Django REST Framework
- JWT Authentication
- Redis (planned / integrated)
- Celery (planned / integrated)
- PostgreSQL / SQLite

---

## ▶️ Getting Started (Windows)

### 1️⃣ Activate Virtual Environment

```bash
stylishenv\Scripts\activate
```

### 2️⃣ Install Dependencies

```bash
pip install -r requirements.txt###
```

### 3️⃣ Run Migrations

```bash
python stylish\manage.py migrate
```

### 4️⃣ Start Development Server

```
python stylish\manage.py runserver
```
