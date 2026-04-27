from fastapi import APIRouter, Depends, HTTPException
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


# ✅ GET products (manager + owner)
@router.get("/", response_model=list[ProductResponse])
def get_products(
    db: Session = Depends(get_db),
    user=Depends(manager_required)
):
    return db.query(Product).all()


# ✅ ADD / UPDATE product (owner only)
@router.post("/")
def add_product(product: ProductCreate, db: Session = Depends(get_db)):

    # 🔍 Check if same product already exists
    existing = db.query(Product).filter(
        Product.name == product.name,
        Product.brand == product.brand
    ).first()

    # ✅ IF EXISTS → UPDATE STOCK
    if existing:
        existing.stock += product.stock
        db.commit()

        return {
            "message": "Stock updated",
            "type": "update"
        }

    # ✅ ELSE → CREATE NEW PRODUCT
    new_product = Product(
        name=product.name,
        brand=product.brand,
        price=product.price,
        stock=product.stock
    )

    db.add(new_product)
    db.commit()

    return {
        "message": "Product created",
        "type": "create"
    }


# ❌ DELETE product
@router.delete("/{product_id}")
def delete_product(
    product_id: int,
    user=Depends(owner_required),
    db: Session = Depends(get_db)
):
    product = db.query(Product).filter(Product.id == product_id).first()

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    db.delete(product)
    db.commit()

    return {"message": "Product deleted successfully"}

# 🧱 BACKEND API (SEARCH)

@router.get("/search")
def search_products(query: str, db: Session = Depends(get_db)):
    results = db.query(Product).filter(
        Product.name.ilike(f"%{query}%")
    ).limit(5).all()

    return results