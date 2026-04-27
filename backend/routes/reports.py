from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from models import Product, StockRequest
from core.dependencies import get_db, manager_required

router = APIRouter(prefix="/reports", tags=["Reports"])


@router.get("/summary")
def get_summary(
    db: Session = Depends(get_db),
    user=Depends(manager_required)
):
    total_products = db.query(Product).count()

    low_stock = db.query(Product).filter(Product.stock < 5).count()

    pending_requests = db.query(StockRequest).filter(
        StockRequest.status == "pending"
    ).count()

    return {
        "total_products": total_products,
        "low_stock": low_stock,
        "pending_requests": pending_requests
    }