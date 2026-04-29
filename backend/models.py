from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base


# 👤 USER MODEL
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    role = Column(String)  # "owner" or "manager"

    owner_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    # 🔗 Relationships
    managers = relationship("User")
    history = relationship("StockHistory", back_populates="user")


# 📦 PRODUCT MODEL
class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)

    name = Column(String)
    brand = Column(String)
    price = Column(Integer)
    stock = Column(Integer)

    owner_id = Column(Integer, ForeignKey("users.id"))  # 🔥 IMPORTANT

    # 🔗 Relationships
    history = relationship("StockHistory", back_populates="product")


# 📩 STOCK REQUEST (Manager → Owner)
class StockRequest(Base):
    __tablename__ = "stock_requests"

    id = Column(Integer, primary_key=True, index=True)

    product_id = Column(Integer, ForeignKey("products.id"))
    manager_id = Column(Integer, ForeignKey("users.id"))

    quantity = Column(Integer)
    status = Column(String, default="pending")  # pending / approved / rejected

    # 🔗 Relationships
    product = relationship("Product")
    manager = relationship("User")


# 📊 STOCK HISTORY (CORE FEATURE)
class StockHistory(Base):
    __tablename__ = "stock_history"

    id = Column(Integer, primary_key=True, index=True)

    product_id = Column(Integer, ForeignKey("products.id"))
    user_id = Column(Integer, ForeignKey("users.id"))

    change = Column(Integer)  # +10 / -5
    action = Column(String)   # created / sold / restocked / adjusted
    note = Column(String, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)

    # 🔗 Relationships
    product = relationship("Product", back_populates="history")
    user = relationship("User", back_populates="history")