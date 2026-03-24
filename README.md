# 📱 PMA — Phone-based POS & Inventory System

## 🚀 Overview

PMA (Phone Management Application) is a mobile-first POS + inventory system designed to replace traditional laptop/register-based shop management.

The goal is simple:
👉 Enable shopkeepers to manage everything directly from their phone
👉 Add accountability and control to inventory operations

---

## ✨ Core Features (Built So Far)

### 🔐 Authentication System

* User Registration & Login (FastAPI)
* JWT-based authentication
* Secure password hashing (bcrypt)

---

### 👥 Role-Based Access Control (RBAC)

* **Owner**

  * Full control over system
  * Can add products
  * Can approve/reject stock requests

* **Manager**

  * Can view inventory
  * Cannot directly modify stock

---

### 📦 Inventory Management

* Add products (Owner only)
* View products (Manager + Owner)
* Database-driven (SQLite + SQLAlchemy)

---

### 🔄 Stock Approval System (USP Feature)

A key differentiator of PMA:

> Managers cannot directly reduce stock.

Flow:

1. Manager raises stock reduction request
2. Request is stored as **pending**
3. Owner reviews request
4. Owner approves/rejects
5. If approved → stock updates

✅ Adds accountability
✅ Prevents misuse
✅ Tracks every inventory change

---

## 🧱 Tech Stack

### Backend

* FastAPI
* SQLAlchemy
* SQLite
* JWT (python-jose)
* Passlib (bcrypt)

### Frontend (In Progress)

* Flutter
* Material UI
* REST API integration

---

## 📁 Project Structure

```
PMA/
├── backend/
│   ├── core/
│   │   ├── security.py
│   │   └── dependencies.py
│   ├── routes/
│   │   ├── auth.py
│   │   ├── products.py
│   │   ├── stock_requests.py
│   │   ├── sales.py
│   │   └── reports.py
│   ├── models.py
│   ├── database.py
│   ├── main.py
│   └── shop.db
│
├── shop_app/
│   ├── lib/
│   └── pubspec.yaml
│
└── README.md
```

---

## ⚙️ How to Run

### Backend

```bash
cd backend
source venv/bin/activate
uvicorn main:app --reload
```

Open:
👉 http://127.0.0.1:8000/docs

---

### Flutter App

```bash
cd shop_app
flutter pub get
flutter run
```

---

## 🧪 Current API Flow

### Auth

* `POST /auth/register`
* `POST /auth/login`

### Products

* `GET /products/` (Manager + Owner)
* `POST /products/` (Owner only)

### Stock Requests

* `POST /requests/` (Manager)
* `GET /requests/` (Owner)
* `PUT /requests/{id}` (Owner approve/reject)

---

## 🚧 Work In Progress

* Flutter Login Screen (JWT integration)
* Inventory UI connected to backend
* Approval UI for owners
* Notifications system
* Sales & analytics dashboard

---

## 🎯 Vision

PMA aims to evolve into a full SaaS product for small and medium retail businesses:

* 📊 Smart reports & analytics
* 🔔 Real-time notifications
* ☁️ Cloud sync
* 🧾 Billing system
* 📱 Fully mobile-first experience

---

## 👨‍💻 Author

**Shivam Kumar Manjhi**
Full Stack Developer (Flutter + FastAPI)

---

## 📌 Status

🚧 Actively under development
🔥 Core backend architecture completed
📱 Frontend integration in progress

---
