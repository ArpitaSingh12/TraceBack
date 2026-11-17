from __future__ import annotations

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from app.deps import get_current_user, get_db, require_roles
from app.models import Batch, Document, JourneyEvent, Product, User
from app.schemas import BatchDetail, BatchRead, JourneyEventCreate, JourneyEventRead

router = APIRouter()


@router.get("/{batch_id}", response_model=BatchDetail)
def get_batch(batch_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    del user
    batch = db.query(Batch).filter(Batch.id == batch_id).first()
    if not batch:
        raise HTTPException(status_code=404, detail="Batch not found")
    return {
        "id": batch.id,
        "product_id": batch.product_id,
        "batch_number": batch.batch_number,
        "qr_code": batch.qr_code,
        "created_at": batch.created_at,
        "events": batch.events,
        "documents": batch.product.documents,
    }


@router.get("/product/{product_id}", response_model=list[BatchRead])
def list_product_batches(product_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    del user
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return db.query(Batch).filter(Batch.product_id == product_id).order_by(Batch.created_at.desc()).all()


@router.post("/{product_id}/events", response_model=JourneyEventRead, status_code=status.HTTP_201_CREATED)
def create_event(
    product_id: int,
    event: JourneyEventCreate,
    db: Session = Depends(get_db),
    producer: User = Depends(require_roles("producer")),
):
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    if product.producer_id != producer.id:
        raise HTTPException(status_code=403, detail="Not allowed to manage this product")

    batch = db.query(Batch).filter(Batch.product_id == product_id).order_by(Batch.created_at.desc()).first()
    if not batch:
        raise HTTPException(status_code=404, detail="No batch found for the product")

    new_event = JourneyEvent(
        batch_id=batch.id,
        event_type=event.event_type,
        location=event.location,
        event_date=event.event_date,
        description=event.description,
        organization=event.organization,
        supporting_document=event.supporting_document,
    )
    db.add(new_event)
    db.commit()
    db.refresh(new_event)
    return new_event


@router.get("/qr/{qr_code}")
def resolve_qr(qr_code: str, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    del user
    batch = db.query(Batch).filter(Batch.qr_code == qr_code).first()
    if not batch:
        raise HTTPException(status_code=404, detail="Unknown QR code")
    return {"batch_id": batch.id, "product_id": batch.product_id, "batch_number": batch.batch_number}
