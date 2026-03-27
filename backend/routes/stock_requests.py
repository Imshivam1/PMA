from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import SessionLocal
from models import StockRequest, Product
from core.dependencies import manager_required, owner_required

router = APIRouter(prefix="/requests", tags=["Stock Requests"])


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# Manager creates request
@router.post("/")
def create_request(product_id: int, quantity: int, user=Depends(manager_required), db: Session = Depends(get_db)):
    request = StockRequest(
        product_id=product_id,
        quantity=quantity,
        manager_id=user.id
    )
    db.add(request)
    db.commit()
    return {"message": "Request created"}

#owner view request
@router.get("/")
def get_requests(user=Depends(owner_required), db: Session = Depends(get_db)):
    return db.query(StockRequest).all()

#approve/reject
@router.put("/{request_id}")
def update_request(
    request_id: int,
    status: str,
    user=Depends(owner_required),
    db: Session = Depends(get_db)
):
    stock_request = db.query(StockRequest).filter(StockRequest.id == request_id).first()

    if not stock_request:
        raise HTTPException(status_code=404, detail="Request not found")

    # 🔒 Prevent double processing
    if stock_request.status != "pending":
        raise HTTPException(status_code=400, detail="Request already processed")

    # 🔒 Validate status
    if status not in ["approved", "rejected"]:
        raise HTTPException(status_code=400, detail="Invalid status")

    # ✅ If approved → update stock
    if status == "approved":
        product = db.query(Product).filter(Product.id == stock_request.product_id).first()

        if not product:
            raise HTTPException(status_code=404, detail="Product not found")

        if product.stock < stock_request.quantity:
            raise HTTPException(status_code=400, detail="Not enough stock")

        product.stock -= stock_request.quantity

    stock_request.status = status
    db.commit()

    return {"message": f"Request {status}"}