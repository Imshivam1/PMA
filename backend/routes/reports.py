from fastapi import APIRouter

router = APIRouter(prefix="/reports", tags=["Reports"])

@router.get("/weekly")
def weekly_report():
    return {
        "total_sales": 38200,
        "top_item": "Milk",
        "dead_stock": ["Soap"],
        "naturally_selling": ["Milk", "Bread"]
    }
