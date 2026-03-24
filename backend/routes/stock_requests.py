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
        requested_by=user["user_id"]
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
def update_request(request_id: int, status: str, user=Depends(owner_required), db: Session = Depends(get_db)):
    request = db.query(StockRequest).filter(StockRequest.id == request_id).first()

    if not request:
        raise HTTPException(status_code=404, detail="Request not found")

    request.status = status

    # ✅ If approved → update stock
    if status == "approved":
        product = db.query(Product).filter(Product.id == request.product_id).first()
        if product:
            product.stock -= request.quantity

    db.commit()
    return {"message": f"Request {status}"}