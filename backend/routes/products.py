from fastapi import APIRouter, Body, Depends
from sqlalchemy.orm import Session
from database import SessionLocal
from models import Product
from core.dependencies import manager_required, owner_required

router = APIRouter(tags=["Products"])


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# ✅ GET products (manager + owner)
@router.get("/")
def get_products(user=Depends(manager_required), db: Session = Depends(get_db)):
    return db.query(Product).all()


# ✅ ADD product (owner only)
@router.post("/")
def add_product(product: dict = Body(...), user=Depends(owner_required), db: Session = Depends(get_db)):
    new_product = Product(
        name=product["name"],
        price=product["price"],
        stock=product["stock"]
    )
    db.add(new_product)
    db.commit()
    db.refresh(new_product)
    return new_product