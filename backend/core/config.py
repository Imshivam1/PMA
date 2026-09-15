import os
from functools import lru_cache


class Settings:
    def __init__(self):
        self.database_url = self._normalize_database_url(
            os.getenv("DATABASE_URL", "sqlite:///./shop.db")
        )
        self.secret_key = os.getenv("SECRET_KEY", "change-this-local-secret")
        self.algorithm = os.getenv("ALGORITHM", "HS256")
        self.access_token_expire_minutes = int(
            os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "60")
        )
        self.cors_origins = self._parse_csv(os.getenv("CORS_ORIGINS", "*"))

    @staticmethod
    def _parse_csv(value: str) -> list[str]:
        return [item.strip() for item in value.split(",") if item.strip()]

    @staticmethod
    def _normalize_database_url(value: str) -> str:
        if value.startswith("postgres://"):
            return value.replace("postgres://", "postgresql+psycopg://", 1)
        if value.startswith("postgresql://"):
            return value.replace("postgresql://", "postgresql+psycopg://", 1)
        return value


@lru_cache
def get_settings() -> Settings:
    return Settings()
