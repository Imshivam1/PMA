from sqlalchemy import Column, Integer, String, ForeignKey
from database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    role = Column(String)  # "owner" or "manager"

class StockRequest(Base):
    __tablename__ = "stock_requests"

    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer)
    requested_by = Column(Integer)  # user_id
    quantity = Column(Integer)
    status = Column(String, default="pending")  # pending/approved/rejected