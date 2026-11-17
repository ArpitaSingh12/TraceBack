from __future__ import annotations

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from fastapi.responses import FileResponse
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.deps import get_current_user, get_db, require_roles
from app.models import Document, Product, User
from app.schemas import DocumentRead, ProductCreate, ProductRead, TransparencyScore
from app.services.scoring import compute_transparency_score
from app.services.upload_storage import (
    MAX_PRODUCT_IMAGE_BYTES,
    remove_stored_file,
    resolve_stored_file,
    store_upload,
)

router = APIRouter()


@router.get("", response_model=list[ProductRead])
def list_products(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    del user
    return db.query(Product).order_by(Product.created_at.desc()).all()


@router.get("/mine", response_model=list[ProductRead])
def list_my_products(db: Session = Depends(get_db), producer: User = Depends(require_roles("producer"))):
    return db.query(Product).filter(Product.producer_id == producer.id).order_by(Product.created_at.desc()).all()


@router.get("/recent", response_model=list[ProductRead])
def recent_products(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    del user
    return db.query(Product).order_by(Product.created_at.desc()).limit(5).all()


@router.get("/{product_id}", response_model=ProductRead)
def get_product(product_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    del user
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product


@router.get("/{product_id}/documents", response_model=list[DocumentRead])
def list_product_documents(
    product_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    del user
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return db.query(Document).filter(Document.product_id == product_id).order_by(Document.created_at.desc()).all()


@router.post("", response_model=ProductRead, status_code=status.HTTP_201_CREATED)
def create_product(
    product_in: ProductCreate,
    db: Session = Depends(get_db),
    producer: User = Depends(require_roles("producer")),
):
    duplicate = (
        db.query(Product)
        .filter(
            Product.producer_id == producer.id,
            Product.batch_number == product_in.batch_number,
        )
        .first()
    )
    if duplicate:
        raise HTTPException(status_code=409, detail="A product with this batch number already exists")

    product = Product(
        name=product_in.name,
        description=product_in.description,
        category=product_in.category,
        brand=product_in.brand,
        batch_number=product_in.batch_number,
        image_url=product_in.image_url,
        manufacturing_date=product_in.manufacturing_date,
        expiry_date=product_in.expiry_date,
        origin_location=product_in.origin_location,
        current_status=product_in.current_status,
        producer_id=producer.id,
    )
    db.add(product)
    db.commit()
    db.refresh(product)
    return product


@router.put("/{product_id}", response_model=ProductRead)
def update_product(
    product_id: int,
    product_in: ProductCreate,
    db: Session = Depends(get_db),
    producer: User = Depends(require_roles("producer")),
):
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    if product.producer_id != producer.id:
        raise HTTPException(status_code=403, detail="Not allowed to manage this product")
    for field, value in product_in.model_dump().items():
        setattr(product, field, value)
    db.commit()
    db.refresh(product)
    return product


@router.post("/{product_id}/image", response_model=ProductRead)
async def upload_product_image(
    product_id: int,
    image: UploadFile = File(...),
    db: Session = Depends(get_db),
    producer: User = Depends(require_roles("producer")),
):
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    if product.producer_id != producer.id:
        raise HTTPException(status_code=403, detail="Not allowed to manage this product")

    stored = await store_upload(image, "products", MAX_PRODUCT_IMAGE_BYTES)
    previous_url = product.image_url
    product.image_url = f"/uploads/products/{stored.stored_name}"
    try:
        db.commit()
        db.refresh(product)
    except SQLAlchemyError:
        db.rollback()
        remove_stored_file("products", stored.stored_name)
        raise
    if previous_url and previous_url.startswith("/uploads/products/"):
        remove_stored_file("products", previous_url.rsplit("/", 1)[-1])
    return product


@router.delete("/{product_id}/image", response_model=ProductRead)
def remove_product_image(
    product_id: int,
    db: Session = Depends(get_db),
    producer: User = Depends(require_roles("producer")),
):
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    if product.producer_id != producer.id:
        raise HTTPException(status_code=403, detail="Not allowed to manage this product")

    previous_url = product.image_url
    product.image_url = None
    db.commit()
    db.refresh(product)
    if previous_url and previous_url.startswith("/uploads/products/"):
        remove_stored_file("products", previous_url.rsplit("/", 1)[-1])
    return product


@router.get("/{product_id}/image-file")
def get_product_image_file(
    product_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    del user
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product or not product.image_url or not product.image_url.startswith("/uploads/products/"):
        raise HTTPException(status_code=404, detail="Product image not found")
    stored_name = product.image_url.rsplit("/", 1)[-1]
    return FileResponse(resolve_stored_file("products", stored_name))


@router.get("/{product_id}/score", response_model=TransparencyScore)
def score(product_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    del user
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    total = compute_transparency_score(product)
    breakdown = {
        "origin": 20 if product.origin_location else 0,
        "producer": 15 if product.producer_id else 0,
        "processing": 20 if product.batches and any(batch.events for batch in product.batches) else 0,
        "packaging": 15 if product.batches and any(batch.events for batch in product.batches) else 0,
        "documents": 20 if product.documents else 0,
        "verification": 10 if any(doc.status == "verified" for doc in product.documents) else 0,
    }
    completed = [name for name, value in breakdown.items() if value > 0]
    missing = [name for name, value in breakdown.items() if value == 0]
    return {
        "total": total,
        "breakdown": breakdown,
        "completed": completed,
        "missing": missing,
        "note": "This is an information-completeness score and not a food safety or authenticity guarantee.",
    }
