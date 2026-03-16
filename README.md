# 🚀 Stylish – AI-Powered E-Commerce Admin Dashboard

### Flutter Admin Panel + Django REST API + AI (LLMs & MCP)

**Stylish** is a **production-ready full-stack e-commerce administration system** built from scratch using **Flutter** for the admin frontend and **Django REST Framework** for the backend.  
The system follows **professional architectural patterns** and integrates **AI-powered analytics** using Large Language Models (LLMs) and the **Model Context Protocol (MCP)**.

This project is designed to reflect how **real-world enterprise systems** are built — not a tutorial or demo application.

---

## 📁 Project Structure

This repository is organized as a **monorepo**, containing both frontend and backend applications:

```
DEVELOPMENT/
│
├── stylish_admin_frontend/ # Flutter Admin Dashboard
├── stylish_backend/ # Django REST API Backend
│
├── .gitignore
└── README.md
```

---

## 🧱 Architecture Overview

### 🖥 Frontend – Flutter

- Clean Architecture (Presentation / Domain / Data layers)
- BLoC Pattern for state management
- Dependency Injection
- Responsive Admin UI (Web / Desktop / Mobile-ready)
- REST API integration

### 🖧 Backend – Django

- Django REST Framework (DRF)
- Service-Based Architecture
- JWT Authentication
- Redis caching
- Celery for background tasks
- Modular and scalable app structure

### 🤖 AI Layer

- Large Language Models (LLMs)
- Model Context Protocol (MCP)
- Secure and controlled AI-to-database communication
- Natural language analytics and recommendations

---

## ✨ Core Features

### 🔐 Authentication & Security

- Custom User Model
- JWT Authentication (Access & Refresh Tokens)
- Email Verification
- Password Reset Workflow
- Secure API authorization

---

### 🛒 E-Commerce Management

- Products CRUD
- Categories & Subcategories
- Product Variations (size, color, etc.)
- Inventory & Stock Management
- Business rules and validation logic

---

### 📊 Admin Dashboard

- Sales overview and metrics
- Inventory insights
- Product performance tracking
- Clean, scalable Flutter UI

---

### 🤖 AI-Powered Chat Assistant

An intelligent AI agent capable of:

- Querying sales and inventory data
- Answering business questions in natural language
- Providing data-driven insights and recommendations
- Safely interacting with backend services via MCP

Example queries:

- “Which products are low in stock?”
- “What are the top-selling products this month?”

---

### ⚙️ Background Processing

- Celery workers for asynchronous tasks
- Redis as message broker and cache
- Use cases include:
  - Sending emails
  - Heavy data processing
  - AI-related background jobs

---

## 🧠 Technologies Used

### Frontend

- Flutter
- Dart
- BLoC
- Clean Architecture
- REST APIs

### Backend

- Python
- Django
- Django REST Framework
- JWT Authentication
- Celery
- Redis
- PostgreSQL / SQLite (configurable)

### AI & Intelligence

- Large Language Models (LLMs)
- Model Context Protocol (MCP)
- AI-driven analytics and recommendations

---

## 🎯 Purpose of This Project

This project serves as:

- A **strong full-stack portfolio project**
- A real-world example of scalable architecture
- Hands-on experience with:
  - Flutter Clean Architecture
  - Django Service-Based Architecture
  - AI integration in production systems

---

## 👨‍💻 Target Audience

- Intermediate to Advanced Flutter Developers
- Backend Developers using Django
- Full-Stack Engineers
- Developers transitioning from tutorials to professional systems

---

## 🚧 Future Enhancements

- Role-based access control (RBAC)
- Advanced analytics dashboards
- Real-time updates (WebSockets)
- Docker & CI/CD pipelines
- Multi-store / multi-vendor support

---

## ⭐ Final Notes

**Stylish** is not just an admin panel —  
it is a **scalable, enterprise-style system** that demonstrates real-world full-stack and AI engineering skills.

Feel free to explore, fork, and build upon it 🚀
