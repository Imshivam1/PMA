from pydantic import BaseModel


#  PRODUCT CREATE
class ProductCreate(BaseModel):
    name: str
    brand: str
    price: int
    stock: int


#  PRODUCT RESPONSE 
class ProductResponse(BaseModel):
    id: int
    name: str
    brand: str
    price: int
    stock: int

    class Config:
        from_attributes = True  #important for SQLAlchemy

# STOCK REQUEST CREATE
class StockRequestCreate(BaseModel):
    product_id: int
    quantity: int


# STOCK REQUEST RESPONSE
class StockRequestResponse(BaseModel):
    id: int
    product_id: int
    quantity: int
    status: str
    manager_id: int

    class Config:
        from_attributes = True

class LoginResponse(BaseModel):
    access_token: str
    role: str
    user_id: int

# Owner creates manager profile
class CreateUserRequest(BaseModel):
    name: str
    email: str
    password: str
    role: str