from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError

SECRET_KEY = "your-secret-key"  # must match security.py
ALGORITHM = "HS256"

security = HTTPBearer()


# 🔐 Get current user from token
def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")


# 👑 Owner only access
def owner_required(user=Depends(get_current_user)):
    if user["role"] != "owner":
        raise HTTPException(status_code=403, detail="Owner access required")
    return user


# 👨‍💼 Manager + Owner access
def manager_required(user=Depends(get_current_user)):
    if user["role"] not in ["manager", "owner"]:
        raise HTTPException(status_code=403, detail="Manager access required")
    return user