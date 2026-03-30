from fastapi import APIRouter, Body, Depends
from sqlalchemy.orm import Session
from database import SessionLocal
from models import Product
from core.dependencies import manager_required, owner_required
from schemas import ProductCreate, ProductResponse

router = APIRouter(tags=["Products"])


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# GET products (manager + owner)
@router.get("/", response_model=list[ProductResponse])
def get_products(
    db: Session = Depends(get_db),
    user=Depends(manager_required)
):
    return db.query(Product).all()


# ADD product (owner only)
@router.post("/", response_model=ProductResponse)
def add_product(
    product: ProductCreate,
    db: Session = Depends(get_db),
    user=Depends(owner_required)
):
    new_product = Product(
        name=product.name,
        price=product.price,
        stock=product.stock
    )

    db.add(new_product)
    db.commit()
    db.refresh(new_product)

    return new_product