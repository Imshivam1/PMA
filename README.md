📱 PMA — Phone-based POS & Inventory System
🚀 Overview

PMA (Phone Management Application) is a mobile-first POS + inventory system designed to eliminate dependency on laptops, registers, and manual tracking.

🎯 Built for shopkeepers who want speed, control, and accountability — directly from their phone

✨ Core Features
🔐 Authentication & Security
User Registration & Login (FastAPI)
JWT-based authentication (Token-based access)
Secure password hashing using bcrypt
Protected routes with dependency-based auth system
👥 Role-Based Access Control (RBAC)

A strict and scalable role system:

🧑‍💼 Owner
Full system access
Add & manage products
Approve/reject stock requests
View all requests & operations
👨‍🔧 Manager
View inventory
Raise stock modification requests
Cannot directly change stock

🔒 All sensitive actions are restricted via role validation middleware

📦 Inventory Management
Add products (Owner only)
View products (Owner + Manager)
Structured database using SQLAlchemy ORM
Scalable schema design for future analytics
🔄 Stock Request & Approval System (🔥 USP)

💡 Core Innovation of PMA

Unlike traditional POS systems:

❌ Managers cannot directly modify stock
✅ Every stock change is controlled & tracked

⚙️ Workflow
Manager creates a stock request
Request is stored with PENDING status
Owner reviews the request
Owner APPROVES / REJECTS
If approved → stock updates automatically
✅ Benefits
Full accountability
Prevents inventory misuse
Audit trail for every change
Real-world business control logic
📡 Request Tracking System
Status-based tracking:
PENDING
APPROVED
REJECTED
Linked with user roles
Designed for future notification system
🧱 Tech Stack
⚙️ Backend
FastAPI — High-performance API framework
SQLAlchemy — ORM for database handling
SQLite — Lightweight DB (dev phase)
JWT (python-jose) — Authentication
Passlib (bcrypt) — Password security
📱 Frontend (In Progress)
Flutter
Material UI
REST API integration
📁 Project Structure
PMA/
├── backend/
│   ├── core/
│   │   ├── security.py        # JWT + hashing
│   │   └── dependencies.py    # Auth + role guards
│   │
│   ├── routes/
│   │   ├── auth.py
│   │   ├── products.py
│   │   ├── stock_requests.py
│   │   ├── sales.py
│   │   └── reports.py
│   │
│   ├── models.py              # DB models
│   ├── database.py            # DB connection
│   ├── main.py                # Entry point
│   └── shop.db
│
├── shop_app/
│   ├── lib/
│   └── pubspec.yaml
│
└── README.md
⚙️ Setup & Run
🔧 Backend
cd backend

# activate virtual environment
source venv/bin/activate

# run server
uvicorn main:app --reload

📍 API Docs:
👉 http://127.0.0.1:8000/docs

📱 Flutter App
cd shop_app
flutter pub get
flutter run
🔌 API Endpoints
🔐 Authentication
POST /auth/register → Register new user
POST /auth/login → Login & get JWT token
📦 Products
GET /products/ → View products (Owner + Manager)
POST /products/ → Add product (Owner only)
🔄 Stock Requests
POST /requests/ → Create request (Manager)
GET /requests/ → View all requests (Owner)
PUT /requests/{id} → Approve/Reject (Owner)
🧠 System Design Highlights
🔐 Dependency-based authentication (FastAPI)
🧩 Modular route structure
🛡️ Role validation at API level
🔄 Event-driven inventory updates
📈 Designed for scaling to microservices
🚧 Work In Progress
Flutter JWT Authentication flow
Inventory UI integration
Owner approval dashboard
Push notifications system
Sales tracking & analytics
Multi-shop support (future SaaS)
🎯 Vision

PMA is being built as a full SaaS platform for retail businesses:

📊 Smart analytics & reports
🔔 Real-time notifications
☁️ Cloud-based sync
🧾 Billing & invoice system
📱 100% mobile-first operations
👨‍💻 Author

Shivam Kumar Manjhi
Full Stack Developer (Flutter + FastAPI)
🚀 Building scalable real-world systems

📌 Status

🚧 Actively under development
🔥 Backend architecture stable
📱 Frontend integration ongoing