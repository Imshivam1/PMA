from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import SessionLocal
from models import User
from core.security import hash_password, verify_password, create_access_token
from core.dependencies import get_current_user
from pydantic import BaseModel
from fastapi.security import OAuth2PasswordRequestForm
from schemas import LoginResponse


router = APIRouter(prefix="/auth", tags=["Auth"])


#  DB Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


#  Request Schemas
class UserCreate(BaseModel):
    name: str
    email: str
    password: str
    role: str


class UserLogin(BaseModel):
    email: str
    password: str


#  REGISTER
@router.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.email == user.email).first()

    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    new_user = User(
        name=user.name,
        email=user.email,
        password=hash_password(user.password),
        role=user.role
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {"message": "User created"}


#  LOGIN
@router.post("/login", response_model=LoginResponse)
def login(user: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == form_data.username).first()

    if not user or not verify_password(form_data.password, user.password):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token = create_access_token(
        data={"user_id": user.id, "role": user.role}
    )

    return {
        "access_token": token,
        "token_type": "bearer"
    }

@router.post("/create-user")
def create_user(
    name: str,
    email: str,
    password: str,
    role: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    if role == "owner":
        raise HTTPException(status_code=403, detail="Cannot create owner")

    if current_user.role != "owner":
        raise HTTPException(status_code=403, detail="Only owner allowed")

    existing = db.query(User).filter(User.email == email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email exists")

    user = User(
        name=name,
        email=email,
        password=hash_password(password),
        role="manager",
        owner_id=current_user.id
    )

    db.add(user)
    db.commit()

    return {"message": "Manager created"}

@router.get("/me")
def get_profile(current_user=Depends(get_current_user)):
    return current_user