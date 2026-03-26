# 🚀 PMA — Product Update: Stock Request & Approval System

## 📌 Overview

This update introduces one of the **core business features** of PMA — a complete **Stock Request & Approval Workflow**.

The system now supports real-world retail operations where:

* Managers request stock adjustments
* Owners review and approve/reject requests
* Inventory updates automatically based on decisions

---

## ✨ Features Implemented

### 🔐 Role-Based Workflow

* **Manager**

  * Can view products
  * Can create stock requests

* **Owner**

  * Can create products
  * Can approve/reject requests
  * Controls inventory flow

---

### 📦 Product Management (Database-Based)

* Migrated from in-memory storage → **SQL database**
* Product model includes:

  * `id`
  * `name`
  * `price`
  * `stock`

---

### 📩 Stock Request System

Managers can create requests:

* Linked to a specific product
* Includes requested quantity
* Automatically assigned status:

  * `pending`

---

### ✅ Approval System (Core Logic)

When an owner updates request status:

* **If approved:**

  * Product stock is reduced automatically
* **If rejected:**

  * No changes to inventory

---

## 🔁 Request Lifecycle

```text
Manager → Create Request → Status: pending
        ↓
Owner → Approve / Reject
        ↓
System → Update Inventory (if approved)
```

---

## ⚙️ API Endpoints

### 📦 Products

* `GET /products/` → View products (Manager/Owner)
* `POST /products/` → Add product (Owner only)

---

### 📩 Stock Requests

* `POST /requests/` → Create request (Manager)
* `GET /requests/` → View requests
* `PUT /requests/{id}` → Approve/Reject (Owner)

---

## 🧠 Core Business Logic

```python
if status == "approved":
    product.stock -= request.quantity
```

This ensures:

* Real-time inventory control
* Data consistency
* Role-based accountability

---

## ⚠️ Important Notes

* Database reset required after schema updates:

  ```bash
  rm shop.db
  uvicorn main:app --reload
  ```

* Authentication required for all protected routes (JWT-based)

---

## 📈 Current Progress

### ✅ Completed

* Authentication (JWT)
* Role-based access (Owner / Manager)
* Product management (DB integrated)
* Stock request system
* Approval workflow with inventory update

---

### 🚧 In Progress

* Flutter UI integration with backend
* Token persistence (auto-login)
* Profile & logout system

---

### 🔮 Upcoming

* Multi-owner support with separate managers
* Analytics & reporting dashboard
* AI-powered inventory insights

---

## 💡 Vision

PMA is evolving into a **mobile-first smart POS system** where:

* Shopkeepers manage everything from their phone
* Inventory is controlled with accountability
* AI will assist in decision-making

---

## 🤝 Contribution & Feedback

This project is actively evolving. Feedback and ideas are always welcome!

---

## 🧑‍💻 Author

**Shivam Kumar Manjhi**
Building practical, scalable systems with real-world impact 🚀
