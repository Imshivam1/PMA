from pydantic import BaseModel


# 🔹 PRODUCT CREATE
class ProductCreate(BaseModel):
    name: str
    price: int
    stock: int


# 🔹 PRODUCT RESPONSE (Optional but best practice)
class ProductResponse(BaseModel):
    id: int
    name: str
    price: int
    stock: int

    class Config:
        from_attributes = True  # 🔥 important for SQLAlchemy