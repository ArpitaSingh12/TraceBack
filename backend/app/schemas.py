from __future__ import annotations

from datetime import date, datetime
from typing import Literal

from pydantic import BaseModel, EmailStr, Field


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UserCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=120)
    email: EmailStr
    password: str = Field(..., min_length=6, max_length=128)
    role: Literal["customer", "producer", "admin"] = "customer"


class UserRead(BaseModel):
    id: int
    name: str
    email: str
    role: str

    model_config = {"from_attributes": True}


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class ProductBase(BaseModel):
    name: str
    description: str
    category: str
    brand: str
    image_url: str | None = None
    batch_number: str
    manufacturing_date: date
    expiry_date: date | None = None
    origin_location: str
    current_status: str = "In production"


class ProductRead(ProductBase):
    id: int
    producer_id: int
    transparency_score: int = 0
    created_at: datetime

    model_config = {"from_attributes": True}


class ProductCreate(ProductBase):
    pass


class JourneyEventBase(BaseModel):
    event_type: str
    location: str
    event_date: date
    description: str
    organization: str
    supporting_document: str | None = None


class JourneyEventRead(JourneyEventBase):
    id: int
    batch_id: int
    created_at: datetime

    model_config = {"from_attributes": True}


class JourneyEventCreate(JourneyEventBase):
    pass


class DocumentRead(BaseModel):
    id: int
    product_id: int
    product_name: str | None = None
    title: str = ""
    file_name: str
    mime_type: str
    file_hash: str
    status: str
    verifier_remarks: str | None = None
    uploaded_by_id: int
    uploader_name: str | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class DocumentCreate(BaseModel):
    document_type: str
    status: str = "pending"


class VerificationUpdate(BaseModel):
    status: Literal["pending", "verified", "rejected"]
    remarks: str | None = None


class BatchRead(BaseModel):
    id: int
    product_id: int
    batch_number: str
    qr_code: str
    created_at: datetime

    model_config = {"from_attributes": True}


class BatchDetail(BatchRead):
    events: list[JourneyEventRead] = []
    documents: list[DocumentRead] = []


class AuditLogRead(BaseModel):
    id: int
    action: str
    entity_type: str
    entity_id: int | None = None
    details: str | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class TransparencyScore(BaseModel):
    total: int
    breakdown: dict[str, int]
    completed: list[str]
    missing: list[str]
    note: str
