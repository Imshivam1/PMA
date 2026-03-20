from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import products, sales, reports
from routes import auth
from database import Base, engine
import models

Base.metadata.create_all(bind=engine)
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(products.router, prefix="/products")
app.include_router(sales.router, prefix="/sales")
app.include_router(reports.router, prefix="/reports")
app.include_router(auth.router)
