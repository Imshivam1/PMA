from fastapi import APIRouter, Body, Depends
from core.dependencies import manager_required, owner_required

router = APIRouter(tags=["Products"])

products = [
    {"id": 1, "name": "Milk", "price": 50, "stock": 3},
    {"id": 2, "name": "Sugar", "price": 45, "stock": 12},
]

@router.get("/")
def get_products(user=Depends(manager_required)):
    return products


@router.post("/")
def add_product(product: dict = Body(...), user=Depends(owner_required)):
    new_product = {
        "id": len(products) + 1,
        "name": product["name"],
        "price": product["price"],
        "stock": product["stock"],
    }
    products.append(new_product)
    return new_product