from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.deps import get_db, require_roles
from app.models import AuditLog, Batch, Document, Product, User
from app.schemas import AuditLogRead, DocumentRead, VerificationUpdate

router = APIRouter()


@router.get("/stats")
def stats(db: Session = Depends(get_db), admin: User = Depends(require_roles("admin"))):
    del admin
    documents = db.query(Document).all()
    return {
        "total_users": db.query(User).count(),
        "producers": db.query(User).filter(User.role == "producer").count(),
        "customers": db.query(User).filter(User.role == "customer").count(),
        "products": db.query(Product).count(),
        "batches": db.query(Batch).count(),
        "documents": len(documents),
        "pending_documents": sum(d.status == "pending" for d in documents),
        "verified_documents": sum(d.status == "verified" for d in documents),
        "rejected_documents": sum(d.status == "rejected" for d in documents),
    }


@router.get("/users", response_model=list[dict])
def list_users(db: Session = Depends(get_db), admin: User = Depends(require_roles("admin"))):
    del admin
    return [
        {"id": user.id, "name": user.name, "email": user.email, "role": user.role}
        for user in db.query(User).order_by(User.created_at.desc()).all()
    ]


@router.get("/products", response_model=list[dict])
def list_products(db: Session = Depends(get_db), admin: User = Depends(require_roles("admin"))):
    del admin
    return [
        {
            "id": product.id,
            "name": product.name,
            "brand": product.brand,
            "current_status": product.current_status,
            "origin_location": product.origin_location,
        }
        for product in db.query(Product).order_by(Product.created_at.desc()).all()
    ]


@router.get("/documents", response_model=list[DocumentRead])
def list_documents(db: Session = Depends(get_db), admin: User = Depends(require_roles("admin"))):
    del admin
    return db.query(Document).order_by(Document.created_at.desc()).all()


@router.post("/documents/{document_id}/verify", response_model=DocumentRead)
def verify_document(
    document_id: int,
    update: VerificationUpdate,
    db: Session = Depends(get_db),
    admin: User = Depends(require_roles("admin")),
):
    document = db.query(Document).filter(Document.id == document_id).first()
    if not document:
        raise HTTPException(status_code=404, detail="Document not found")

    document.status = update.status
    document.verifier_remarks = update.remarks or document.verifier_remarks
    db.add(document)
    db.add(AuditLog(user_id=admin.id, action="verify_document", entity_type="document", entity_id=document.id, details=update.status))
    db.commit()
    db.refresh(document)
    return document


@router.get("/audit-logs", response_model=list[AuditLogRead])
def audit_logs(db: Session = Depends(get_db), admin: User = Depends(require_roles("admin"))):
    del admin
    return db.query(AuditLog).order_by(AuditLog.created_at.desc()).all()
