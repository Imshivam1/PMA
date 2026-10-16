from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from models import Product, StockRequest
from core.dependencies import get_db, manager_required

router = APIRouter(tags=["Reports"])


@router.get("/summary")
def get_summary(
    db: Session = Depends(get_db),
    user=Depends(manager_required)
):
    # Managers belong to an owner.
    # Owners use their own ID as the owner ID.
    owner_id = user.owner_id if user.role == "manager" else user.id

    # Total products for this owner's inventory
    total_products = db.query(Product).filter(
        Product.owner_id == owner_id
    ).count()

    # Low-stock products for this owner's inventory
    low_stock = db.query(Product).filter(
        Product.owner_id == owner_id,
        Product.stock < 5
    ).count()

    if user.role == "manager":
        # Manager sees only their own pending requests
        pending_requests = db.query(StockRequest).filter(
            StockRequest.manager_id == user.id,
            StockRequest.status == "pending"
        ).count()

    else:
        # Owner sees pending requests from managers
        # working under that owner.
        pending_requests = (
            db.query(StockRequest)
            .join(
                Product,
                StockRequest.product_id == Product.id
            )
            .filter(
                Product.owner_id == owner_id,
                StockRequest.status == "pending"
            )
            .count()
        )

    return {
        "total_products": total_products,
        "low_stock": low_stock,
        "pending_requests": pending_requests,
    }