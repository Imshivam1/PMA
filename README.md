# 🏪 PMA — Product Management & Billing App

A full-stack **mobile-first POS (Point of Sale) + Inventory Management System** built using:

* ⚡ FastAPI (Backend)
* 📱 Flutter (Frontend)
* 🗄 SQLite (Currently, moving to production DB)
* 🔐 JWT Authentication (In Progress)

---

# 🚀 Vision

To replace traditional shop systems where:

* ❌ Shopkeepers rely on laptops or manual registers
* ❌ No real-time inventory tracking
* ❌ No role-based control

With a **mobile-first smart POS system** where everything is handled via phone.

---

# ✨ Features (Planned + In Progress)

## ✅ Completed

* 📦 Inventory Listing (Real-time via API)
* ➕ Add Product (Full stack integration)
* 🔄 Auto-refresh UI after updates
* 🌐 Backend-Frontend Integration (Flutter ↔ FastAPI)
* 🧱 Clean modular architecture (models, services, routes)

---

## 🚧 In Progress

* 🔐 JWT Authentication (Owner / Manager login)
* 👥 Role-Based Access Control (RBAC)

---

## 🔜 Upcoming Features

### 🔐 Security & Roles

* Owner & Manager login system
* Role-based permissions:

  * Owner → Full control
  * Manager → Limited access

---

### 📉 Stock Control System

* Manager cannot directly delete stock
* Manager creates **stock reduction request**
* Owner approves/rejects request

---

### 🔔 Notification System

* Owner receives approval alerts
* Pending request badge system

---

### 🧾 Billing System

* Scan & bill products
* Generate invoice
* Track daily & weekly sales

---

### 📊 Reports

* Weekly sales
* Product performance
* Profit tracking

---

### ☁️ Production Features

* PostgreSQL / Cloud DB
* Deployment (Render / AWS)
* Secure environment configs

---

# 🏗 Project Structure

## Root

```
PMA/
├── backend/       # FastAPI backend
└── shop_app/      # Flutter app
```

---

## 🔙 Backend (FastAPI)

```
backend/
├── main.py
├── database.py
├── models.py
├── schemas.py
│
├── core/
│   └── security.py        # JWT + password hashing
│
├── routes/
│   ├── auth.py           # Login & Register
│   ├── products.py       # Inventory APIs
│   ├── sales.py
│   └── reports.py
│
├── shop.db               # SQLite DB (temporary)
└── venv/
```

---

## 📱 Frontend (Flutter)

```
shop_app/
├── lib/
│   ├── main.dart
│   │
│   ├── models/
│   │   └── product.dart
│   │
│   ├── services/
│   │   └── api_service.dart
│   │
│   └── screens/
│       └── inventory_screen.dart
│
├── pubspec.yaml
```

---

# 🔄 Current Workflow

### Backend

* FastAPI server running on:

```
http://127.0.0.1:8000
```

### Frontend

* Flutter Web connected via API
* Real-time product fetching & updates

---

# 🔧 Setup Instructions

## Backend

```bash
cd backend
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```

---

## Frontend

```bash
cd shop_app
flutter pub get
flutter run
```

---

# 🧠 Architecture Highlights

* Clean separation: UI → Service → API → DB
* Scalable backend structure
* Stateless authentication (JWT)
* Future-ready for microservices

---

# 📈 Progress Tracker

| Feature               | Status         |
| --------------------- | -------------- |
| Inventory API         | ✅ Done         |
| Add Product           | ✅ Done         |
| Flutter Integration   | ✅ Done         |
| JWT Auth              | 🚧 In Progress |
| Role-Based Access     | 🚧 In Progress |
| Stock Approval System | ⏳ Planned      |
| Billing System        | ⏳ Planned      |

---

# 👨‍💻 Author

**Shivam Kumar Manjhi**

* 💻 Full Stack Developer
* 🚀 Building scalable real-world systems
* 📍 India

---

# ⭐ Future Scope

This project is designed to evolve into:

* Multi-shop SaaS platform
* Cloud-based POS system
* AI-powered inventory predictions

---

# ⚡ Note

This is an actively developed project.
README will be updated with each major milestone.

---
