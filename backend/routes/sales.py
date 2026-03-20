from fastapi import APIRouter

router = APIRouter(prefix="/sales", tags=["Sales"])

sales = []

@router.post("/")
def create_sale(sale: dict):
    sales.append(sale)
    return {
        "message": "Sale recorded successfully",
        "total_sales": len(sales)
    }
