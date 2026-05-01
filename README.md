# 🧾 Inventory Management System (Flutter + FastAPI)

A full-stack inventory management application built with **Flutter (Frontend)** and **FastAPI (Backend)** featuring role-based access, smart inventory handling, and real-time stock tracking.

---

## 🚀 Features

### 🔐 Authentication
- Login / Register system  
- Role-based access:
  - 👑 Owner  
  - 👨‍💼 Manager  
- JWT-based authentication  

---

### 📦 Inventory Management
- Add product  
- Edit product  
- Delete product (with confirmation)  
- View all products  
- Low stock alerts (⚠️ if stock < 5)  

---

### 🧠 Smart Product Handling
- Case-insensitive matching:
  - `"Curd" == "curd"`  
- Prevents duplicate products  
- Automatically updates stock instead of creating duplicates  

---

### 🔍 Search & Suggestions
- Search by product name and brand  
- Smart suggestion dropdown (like macOS Spotlight)  
- Autofill product details from suggestions  

---

### 📩 Stock Request System
- Managers can request stock  
- Owners can:
  - Approve requests  
  - Reject requests  

---

### 📊 Dashboard
- Total products  
- Low stock items  
- Pending requests  

---

### 📜 Stock History Tracking

Tracks every inventory change:

- ➕ Product created  
- ➕ Stock restocked  
- ➖ Product sold  
- ✏️ Manual adjustments  

#### Example:

+10 RESTOCKED • Added 10 items
-5 SOLD • Product sold
+20 CREATED • Initial stock added


---

### 🎯 Smart UI/UX
- Reusable dialog for Add/Edit  
- Real-time feedback messages:
  - ✅ Product created  
  - 🔄 Stock updated (+5)  
- Clean card-based UI  
- Role-based UI rendering  

---

## 🏗️ Tech Stack

### Frontend
- Flutter  
- Dart  
- Material UI  

### Backend
- FastAPI  
- SQLAlchemy  
- SQLite  

---

## ⚙️ Project Structure


backend/
├── main.py
├── models.py
├── routes/
│ ├── auth.py
│ ├── products.py
│ ├── requests.py
│ └── reports.py
├── schemas.py
├── database.py

frontend/
├── screens/
├── models/
├── services/
├── widgets/


---

## 🧪 Key Learnings
- Reusable UI components (single dialog for multiple flows)  
- Backend-driven logic (duplicate handling)  
- REST API design  
- Role-based access control  
- State management in Flutter  
- Full-stack debugging (API + UI)  

---

## 🐛 Issues Fixed
- Case-sensitive duplicate bug  
- API route mismatch (`/history/{id}` vs `/id/history`)  
- Missing DB columns (`owner_id`)  
- Incorrect imports (`SQLAlchemy func`)  
- UI rendering issues (nested widgets)  
- API connection issues (`localhost` vs `127.0.0.1`)  

---

## 🚀 Future Improvements

### 🔥 Short Term
- Show user names in stock history (instead of IDs)  
- Role labels (Owner / Manager)  
- History filters (Today / Week)  

---

### 📈 Mid Term
- Sales tracking  
- Analytics dashboard (charts)  
- Expiry alerts  
- Barcode scanning  

---

### 🤖 Long Term
- AI-based stock prediction  
- Smart restocking suggestions  
- Multi-store support  
- Notification system  

---

## 🧑‍💻 Author

**Shivam Kumar Manjhi**  
Junior Full Stack Developer  

---

## ⭐ Final Note

This project evolved from a basic CRUD app into a **real-world inventory system with intelligent behavior and scalable architecture**.