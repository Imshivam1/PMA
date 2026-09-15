from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import products, sales, reports
from routes import auth
from database import Base, engine
from routes import stock_requests
from core.config import get_settings

import models

Base.metadata.create_all(bind=engine)
app = FastAPI()
settings = get_settings()

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health_check():
    return {"status": "ok"}


app.include_router(products.router, prefix="/products")
app.include_router(sales.router, prefix="/sales")
app.include_router(reports.router, prefix="/reports")
app.include_router(auth.router)
app.include_router(stock_requests.router)
