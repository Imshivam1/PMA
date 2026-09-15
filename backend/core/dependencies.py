# =========================
# 📦 IMPORTS
# =========================
from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from sqlalchemy.orm import Session

from database import SessionLocal
from models import User
from core.config import get_settings

settings = get_settings()

# =========================
# TOKEN SCHEME (OAuth2)
# =========================
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

# =========================
# DB DEPENDENCY
# =========================
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# =========================
# GET CURRENT USER
# =========================
def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
):
    try:
        # Decode JWT
        payload = jwt.decode(
            token,
            settings.secret_key,
            algorithms=[settings.algorithm],
        )
        user_id = payload.get("user_id")

        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

    # Fetch user from DB
    user = db.query(User).filter(User.id == user_id).first()

    if user is None:
        raise HTTPException(status_code=401, detail="User not found")

    return user


# =========================
# OWNER ONLY ACCESS
# =========================
def owner_required(current_user: User = Depends(get_current_user)):
    if current_user.role != "owner":
        raise HTTPException(
            status_code=403,
            detail="Owner access required"
        )
    return current_user


# =========================
#  MANAGER OR OWNER ACCESS
# =========================
def manager_required(current_user: User = Depends(get_current_user)):
    if current_user.role not in ["manager", "owner"]:
        raise HTTPException(
            status_code=403,
            detail="Manager access required"
        )
    return current_user
