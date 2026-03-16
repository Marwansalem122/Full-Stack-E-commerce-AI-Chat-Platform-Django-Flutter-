# 🎨 Stylish Admin Frontend

### Flutter Admin Dashboard (Clean Architecture + BLoC)

The **Stylish Admin Frontend** is a scalable and maintainable **Flutter-based administration dashboard** built using **Clean Architecture** and the **BLoC pattern**.

This application consumes a RESTful API provided by the Django backend and is designed to manage products, inventory, and business analytics in a professional e-commerce environment.

---

## 🧱 Architecture

The frontend strictly follows **Clean Architecture**, ensuring separation of concerns and long-term maintainability.

```
lib/
├── presentation/ # UI, Pages, Widgets, BLoC
├── domain/ # Entities, Use Cases, Repositories (abstract)
├── data/ # API clients, DTOs, Repositories (implementation)
└── core/ # Shared utilities, constants, error handling
```

---

### Key Architectural Principles

- Business logic is framework-independent
- UI is driven by state (BLoC)
- Dependency inversion between layers
- Easily testable components

---

## ✨ Features

- Admin authentication (JWT-based)
- Product & category management
- Inventory tracking
- Sales overview dashboards
- AI analytics interaction via backend APIs
- Responsive UI (Web / Desktop / Mobile-ready)

---

## 🔄 State Management

- **BLoC (Business Logic Component)**
- Predictable and testable state transitions
- Event-driven architecture

---

## 🔌 API Integration

- RESTful communication with Django backend
- Secure token-based authorization
- Centralized error handling
- DTO mapping between API and domain models

---

## 🧠 Technologies Used

- Flutter
- Dart
- BLoC
- Clean Architecture
- REST APIs

---

## ▶️ Getting Started

```bash
flutter pub get
flutter run
```
