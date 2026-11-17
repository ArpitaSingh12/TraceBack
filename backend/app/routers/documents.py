from __future__ import annotations

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from fastapi.responses import FileResponse
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.deps import get_current_user, get_db, require_roles
from app.models import Document, Product, User
from app.schemas import DocumentRead
from app.services.upload_storage import (
    MAX_DOCUMENT_BYTES,
    remove_stored_file,
    resolve_stored_file,
    store_upload,
)

router = APIRouter()


@router.post("", response_model=DocumentRead, status_code=status.HTTP_201_CREATED)
async def upload_document(
    product_id: int = Form(...),
    title: str = Form(..., min_length=1, max_length=200),
    document_type: str = Form(..., min_length=1, max_length=80),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    producer: User = Depends(require_roles("producer")),
):
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    if product.producer_id != producer.id:
        raise HTTPException(status_code=403, detail="Not allowed to upload documents for this product")

    stored = await store_upload(file, "documents", MAX_DOCUMENT_BYTES)
    document = Document(
        product_id=product.id,
        uploaded_by_id=producer.id,
        title=title.strip(),
        file_name=stored.original_name,
        stored_name=stored.stored_name,
        mime_type=file.content_type or "application/octet-stream",
        file_hash=stored.sha256,
        document_type=document_type.strip(),
        status="pending",
        verifier_remarks=None,
    )
    try:
        db.add(document)
        db.commit()
        db.refresh(document)
    except SQLAlchemyError:
        db.rollback()
        remove_stored_file("documents", stored.stored_name)
        raise
    return document


@router.get("/mine", response_model=list[DocumentRead])
def list_my_documents(
    db: Session = Depends(get_db),
    producer: User = Depends(require_roles("producer")),
):
    return (
        db.query(Document)
        .filter(Document.uploaded_by_id == producer.id)
        .order_by(Document.created_at.desc())
        .all()
    )


@router.get("/{document_id}/file")
def download_document(
    document_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    document = db.query(Document).filter(Document.id == document_id).first()
    if not document:
        raise HTTPException(status_code=404, detail="Document not found")
    if user.role != "admin" and user.id != document.uploaded_by_id:
        raise HTTPException(status_code=403, detail="Not allowed to access this document")

    path = resolve_stored_file("documents", document.stored_name)
    return FileResponse(path, media_type=document.mime_type, filename=document.file_name)
