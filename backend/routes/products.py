from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func 
from database import SessionLocal
from models import Product, StockHistory
from core.dependencies import manager_required, owner_required
from schemas import ProductCreate, ProductResponse

router = APIRouter(tags=["Products"])


# =========================
# 📦 DB DEPENDENCY
# =========================
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# =========================
# 🔐 HELPER (VERY IMPORTANT)
# =========================
def get_owner_id(user):
    return user.owner_id if user.role == "manager" else user.id


# =========================
# 📦 GET PRODUCTS
# =========================
@router.get("/", response_model=list[ProductResponse])
def get_products(
    db: Session = Depends(get_db),
    current_user=Depends(manager_required)
):
    owner_id = get_owner_id(current_user)

    return db.query(Product).filter(
        Product.owner_id == owner_id
    ).all()


# =========================
# ➕ ADD / UPDATE PRODUCT
# =========================
@router.post("/")
def add_product(
    product: ProductCreate,
    db: Session = Depends(get_db),
    current_user=Depends(owner_required)
):
    owner_id = current_user.id

    existing = db.query(Product).filter(
        func.lower(Product.name) == product.name.lower(),
        func.lower(Product.brand) == product.brand.lower(),
        Product.owner_id == owner_id
    ).first()

    # 🔄 UPDATE STOCK
    if existing:
        existing.stock += product.stock

        history = StockHistory(
            product_id=existing.id,
            change=product.stock,
            action="restocked",
            user_id=current_user.id,
            note=f"Added {product.stock} items"
        )

        db.add(history)
        db.commit()

        return {"message": f"Stock updated (+{product.stock})", "type": "update"}
    

    # 🆕 CREATE PRODUCT
    new_product = Product(
        name=product.name,
        brand=product.brand,
        price=product.price,
        stock=product.stock,
        owner_id=owner_id  # 🔥 critical
    )

    db.add(new_product)
    db.commit()
    db.refresh(new_product)

    history = StockHistory(
        product_id=new_product.id,
        change=product.stock,
        action="created",
        user_id=current_user.id,
        note="Initial stock added"
    )

    db.add(history)
    db.commit()

    return {"message": "Product created", "type": "create"}


# =========================
# 🛒 SELL PRODUCT
# =========================
@router.post("/sell/{product_id}")
def sell_product(
    product_id: int,
    quantity: int,
    db: Session = Depends(get_db),
    current_user=Depends(manager_required)
):
    owner_id = get_owner_id(current_user)

    product = db.query(Product).filter(
        Product.id == product_id,
        Product.owner_id == owner_id
    ).first()

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    if product.stock < quantity:
        raise HTTPException(status_code=400, detail="Not enough stock")

    product.stock -= quantity

    history = StockHistory(
        product_id=product.id,
        change=-quantity,
        action="sold",
        user_id=current_user.id,
        note="Product sold"
    )

    db.add(history)
    db.commit()

    return {"message": "Product sold successfully"}


# =========================
# ✏️ UPDATE PRODUCT
# =========================
@router.put("/{product_id}")
def update_product(
    product_id: int,
    product: ProductCreate,
    db: Session = Depends(get_db),
    current_user=Depends(owner_required)
):
    owner_id = current_user.id

    existing = db.query(Product).filter(
        Product.id == product_id,
        Product.owner_id == owner_id
    ).first()

    if not existing:
        raise HTTPException(status_code=404, detail="Product not found")

    stock_diff = product.stock - existing.stock

    existing.name = product.name
    existing.brand = product.brand
    existing.price = product.price
    existing.stock = product.stock

    if stock_diff != 0:
        history = StockHistory(
            product_id=existing.id,
            change=stock_diff,
            action="adjusted",
            user_id=current_user.id,
            note="Manual update"
        )
        db.add(history)

    db.commit()

    return {"message": "Product updated successfully"}


# =========================
# ❌ DELETE PRODUCT
# =========================
@router.delete("/{product_id}")
def delete_product(
    product_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(owner_required)
):
    owner_id = current_user.id

    product = db.query(Product).filter(
        Product.id == product_id,
        Product.owner_id == owner_id
    ).first()

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    db.delete(product)
    db.commit()

    return {"message": "Product deleted successfully"}


# =========================
# 🔍 SEARCH PRODUCTS
# =========================
@router.get("/search")
def search_products(
    query: str,
    db: Session = Depends(get_db),
    current_user=Depends(manager_required)
):
    owner_id = get_owner_id(current_user)

    return db.query(Product).filter(
        Product.owner_id == owner_id,
        Product.name.ilike(f"%{query}%")
    ).limit(5).all()


# =========================
# 📜 STOCK HISTORY
# =========================
@router.get("/{product_id}/history")
def get_stock_history(
    product_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(manager_required)
):
    owner_id = get_owner_id(current_user)

    product = db.query(Product).filter(
        Product.id == product_id,
        Product.owner_id == owner_id
    ).first()

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    return db.query(StockHistory).filter(
        StockHistory.product_id == product_id
    ).order_by(StockHistory.created_at.desc()).all()