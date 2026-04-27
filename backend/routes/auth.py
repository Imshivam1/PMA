from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import SessionLocal
from models import User
from core.security import hash_password, verify_password, create_access_token
from core.dependencies import get_current_user
from pydantic import BaseModel

# ✅ IMPORT YOUR NEW SCHEMA
from schemas import CreateUserRequest

router = APIRouter(prefix="/auth", tags=["Auth"])


# =========================
# 🗄️ DB DEPENDENCY
# =========================
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# =========================
# 📦 REQUEST SCHEMAS
# =========================
class UserCreate(BaseModel):
    name: str
    email: str
    password: str
    role: str


class UserLogin(BaseModel):
    email: str
    password: str


# =========================
# 📝 REGISTER (PUBLIC)
# =========================
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


# =========================
# 🔐 LOGIN
# =========================
@router.post("/login")
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()

    if not db_user or not verify_password(user.password, db_user.password):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token = create_access_token(
        data={"user_id": db_user.id, "role": db_user.role}
    )

    return {
        "access_token": token,
        "role": db_user.role,
        "user_id": db_user.id
    }


# =========================
# 👑 CREATE MANAGER (OWNER ONLY)
# =========================
@router.post("/create-user")
def create_user(
    user: CreateUserRequest,  # ✅ FIX: JSON BODY
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    # ❌ Block creating owner
    if user.role == "owner":
        raise HTTPException(status_code=403, detail="Cannot create owner")

    # ❌ Only owner allowed
    if current_user.role != "owner":
        raise HTTPException(status_code=403, detail="Only owner allowed")

    # ❌ Check duplicate email
    existing = db.query(User).filter(User.email == user.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email exists")

    # ✅ Create manager
    new_user = User(
        name=user.name,
        email=user.email,
        password=hash_password(user.password),
        role="manager",  # enforce manager
        owner_id=current_user.id
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {"message": "Manager created successfully"}


# =========================
# 👤 GET PROFILE
# =========================
@router.get("/me")
def get_profile(current_user=Depends(get_current_user)):
    return current_user

# =========================
# 👤 GET ALL MANAGERS (by owners only)
# =========================

@router.get("/managers")
def get_managers(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    if current_user.role != "owner":
        raise HTTPException(status_code=403, detail="Only owner allowed")

    managers = db.query(User).filter(
        User.owner_id == current_user.id
    ).all()

    return managers

# =========================
# ❌ Delete MANAGERS (by owners only)
# =========================

@router.delete("/managers/{manager_id}")
def delete_manager(
    manager_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    if current_user.role != "owner":
        raise HTTPException(status_code=403, detail="Only owner allowed")

    manager = db.query(User).filter(
        User.id == manager_id,
        User.owner_id == current_user.id
    ).first()

    if not manager:
        raise HTTPException(status_code=404, detail="Manager not found")

    db.delete(manager)
    db.commit()

    return {"message": "Manager deleted"}