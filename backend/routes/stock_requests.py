from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import SessionLocal
from models import StockRequest, Product
from core.dependencies import manager_required, owner_required
from schemas import StockRequestCreate, StockRequestResponse

router = APIRouter(prefix="/requests", tags=["Stock Requests"])


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# Manager creates a stock request
@router.post("/", response_model=StockRequestResponse)
def create_request(
    request: StockRequestCreate,
    user=Depends(manager_required),
    db: Session = Depends(get_db),
):
    # Ensure the requested product belongs to this manager's owner
    owner_id = user.owner_id

    product = db.query(Product).filter(
        Product.id == request.product_id,
        Product.owner_id == owner_id,
    ).first()

    if not product:
        raise HTTPException(
            status_code=404,
            detail="Product not found",
        )

    if request.quantity <= 0:
        raise HTTPException(
            status_code=400,
            detail="Quantity must be greater than zero",
        )

    stock_request = StockRequest(
        product_id=product.id,
        quantity=request.quantity,
        manager_id=user.id,
        status="pending",
    )

    db.add(stock_request)
    db.commit()
    db.refresh(stock_request)

    return {
    "id": stock_request.id,
    "product_id": stock_request.product_id,
    "product_name": product.name,
    "quantity": stock_request.quantity,
    "status": stock_request.status,
    "manager_id": stock_request.manager_id,
}


# Owner sees requests from their managers.
# Manager sees only their own requests.
@router.get("/", response_model=list[StockRequestResponse])
def get_requests(
    user=Depends(manager_required),
    db: Session = Depends(get_db),
):
    query = db.query(StockRequest, Product).join(
        Product,
        StockRequest.product_id == Product.id,
    )

    if user.role == "manager":
        query = query.filter(
            StockRequest.manager_id == user.id
        )
    else:
        query = query.filter(
            Product.owner_id == user.id
        )
    rows = query.order_by(
        StockRequest.id.desc()
    ).all()


    return [
        {
            "id": request.id,
            "product_id": request.product_id,
            "product_name": product.name,
            "quantity": request.quantity,
            "status": request.status,
            "manager_id": request.manager_id,
        }
        for request, product in rows
    ]


# Only the Owner can approve or reject a request
@router.put("/{request_id}")
def update_request(
    request_id: int,
    status: str,
    user=Depends(owner_required),
    db: Session = Depends(get_db),
):
    stock_request = (
        db.query(StockRequest)
        .join(
            Product,
            StockRequest.product_id == Product.id,
        )
        .filter(
            StockRequest.id == request_id,
            Product.owner_id == user.id,
        )
        .first()
    )

    if not stock_request:
        raise HTTPException(
            status_code=404,
            detail="Request not found",
        )

    if stock_request.status != "pending":
        raise HTTPException(
            status_code=400,
            detail="Request already processed",
        )

    if status not in ["approved", "rejected"]:
        raise HTTPException(
            status_code=400,
            detail="Invalid status",
        )

    if status == "approved":
        product = stock_request.product

        if not product:
            raise HTTPException(
                status_code=404,
                detail="Product not found",
            )

        if product.stock < stock_request.quantity:
            raise HTTPException(
                status_code=400,
                detail="Not enough stock",
            )

        product.stock -= stock_request.quantity

    stock_request.status = status
    db.commit()

    return {"message": f"Request {status}"}