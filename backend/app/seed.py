from __future__ import annotations

from datetime import date

from sqlalchemy.orm import Session

from app.models import AuditLog, Batch, Document, JourneyEvent, Product, User
from app.security import hash_password


def seed_demo_data(db: Session) -> None:
    demo_accounts = [
        ("Nora Verifier", "admin@traceback.app", "admin123", "admin"),
        ("Aster Flow", "producer@traceback.app", "producer123", "producer"),
        ("Maya Shah", "customer@traceback.app", "customer123", "customer"),
        ("Meera Farms", "meera.farms@traceback.app", "demo123", "producer"),
        ("Green Valley Estates", "green.valley@traceback.app", "demo123", "producer"),
    ]
    for name, email, password, role in demo_accounts:
        user = db.query(User).filter(User.email == email).first()
        if not user:
            db.add(User(name=name, email=email, password_hash=hash_password(password), role=role))
    db.flush()

    producers = [
        db.query(User).filter(User.email == "producer@traceback.app").one(),
        db.query(User).filter(User.email == "meera.farms@traceback.app").one(),
        db.query(User).filter(User.email == "green.valley@traceback.app").one(),
    ]
    admin = db.query(User).filter(User.email == "admin@traceback.app").one()

    catalog = [
        ("Wildflower Forest Honey", "Honey", "Forest Bloom", "Wayanad, Kerala, India", "HNY-WLD-001", producers[0], "assets/images/wildflower_honey.jpg", "verified"),
        ("Arabica Estate Coffee", "Coffee", "Kaveri Hills", "Chikmagalur, Karnataka, India", "CAF-ARB-002", producers[1], "assets/images/coorg_arabica_coffee.jpg", "verified"),
        ("Munnar Green Tea", "Tea", "Misty Peak", "Munnar, Kerala, India", "TEA-GRN-003", producers[2], "assets/images/darjeeling_tea.jpg", "verified"),
        ("Lakadong Turmeric", "Spices", "Jaintia Gold", "Jaintia Hills, Meghalaya, India", "SPC-TUR-004", producers[0], "assets/images/himalayan_turmeric.jpg", "pending"),
        ("Ceylon Cinnamon", "Spices", "Malabar Crown", "Kasaragod, Kerala, India", "SPC-CIN-005", producers[1], "assets/images/ceylon_cinnamon.jpg", "verified"),
        ("Keralan Cardamom", "Spices", "High Range Pods", "Idukki, Kerala, India", "SPC-CAR-006", producers[2], "assets/images/cardamom_pods.jpg", "verified"),
        ("Malabar Black Pepper", "Spices", "Pepper Coast", "Wayanad, Kerala, India", "SPC-PEP-007", producers[0], "assets/images/wayanad_black_pepper.jpg", "rejected"),
        ("Ponni Rice", "Rice", "Delta Fields", "Thanjavur, Tamil Nadu, India", "RIC-PON-008", producers[1], "assets/images/basmati_rice.jpg", "verified"),
        ("Alphonso Mango", "Fruits", "Ratnagiri Grove", "Ratnagiri, Maharashtra, India", "FRU-MNG-009", producers[2], "assets/images/alphonso_mango.jpg", "pending"),
        ("Nagpur Orange", "Fruits", "Citrus Valley", "Nagpur, Maharashtra, India", "FRU-ORG-010", producers[1], "assets/images/nagpur_oranges.jpg", "verified"),
        ("Organic A2 Ghee", "Organic", "Grassfed Dairy", "Gir, Gujarat, India", "ORG-GHE-011", producers[0], "assets/images/desi_ghee.jpg", "verified"),
        ("Basmati Rice", "Rice", "Himalayan Grain", "Dehradun, Uttarakhand, India", "RIC-BAS-012", producers[2], "assets/images/basmati_rice.jpg", "pending"),
        ("Kashmiri Saffron", "Spices", "Pampore Aroma", "Pampore, Kashmir, India", "SPC-SAF-013", producers[1], "assets/images/kashmiri_saffron.jpg", "verified"),
        ("Organic Cashew Nuts", "Organic", "Coastal Harvest", "Canacona, Goa, India", "ORG-CAS-014", producers[0], "assets/images/cashew_nuts.jpg", "verified"),
    ]

    for name, category, brand, origin, batch_number, producer, image_url, doc_status in catalog:
        product = db.query(Product).filter(Product.batch_number == batch_number).first()
        if not product:
            product = Product(
                name=name,
                description=f"Traceable {name.lower()} sourced directly from the origin and supplied with batch-level records.",
                category=category,
                brand=brand,
                image_url=image_url,
                batch_number=batch_number,
                manufacturing_date=date(2026, 1, 15),
                expiry_date=date(2027, 1, 15),
                origin_location=origin,
                current_status="In market",
                transparency_score=85 if doc_status == "verified" else 70,
                producer_id=producer.id,
            )
            db.add(product)
            db.flush()
        else:
            product.image_url = image_url

        qr_code = f"traceback-{batch_number.lower()}"
        batch = db.query(Batch).filter(Batch.qr_code == qr_code).first()
        if not batch:
            batch = Batch(product_id=product.id, batch_number=f"{batch_number}-A", qr_code=qr_code)
            db.add(batch)
            db.flush()
            db.add_all([
                JourneyEvent(
                    batch_id=batch.id,
                    event_type="Raw material sourcing",
                    location=origin,
                    event_date=date(2026, 1, 3),
                    description=f"Raw material collected at the registered origin: {origin}.",
                    organization=brand,
                ),
                JourneyEvent(
                    batch_id=batch.id,
                    event_type="Quality inspection",
                    location="Regional TraceBack QA Laboratory",
                    event_date=date(2026, 1, 8),
                    description="Batch identity and required quality checks recorded.",
                    organization="TraceBack Verification Network",
                ),
                JourneyEvent(
                    batch_id=batch.id,
                    event_type="Packaging",
                    location=origin,
                    event_date=date(2026, 1, 12),
                    description="Finished goods labeled and sealed with the traceability batch code.",
                    organization=brand,
                ),
            ])

        file_name = f"{batch_number.lower()}-certificate.pdf"
        document = db.query(Document).filter(Document.product_id == product.id, Document.file_name == file_name).first()
        if not document:
            document = Document(
                product_id=product.id,
                uploaded_by_id=producer.id,
                file_name=file_name,
                stored_name=file_name,
                title="Batch Certificate",
                mime_type="application/pdf",
                file_hash=f"demo-{batch_number.lower()}",
                document_type="Batch Certificate",
                status=doc_status,
                verifier_remarks="Seeded demo document. Review the associated batch records." if doc_status != "verified" else "Verified in the TraceBack review workflow.",
            )
            db.add(document)
            db.flush()
            if doc_status == "verified":
                db.add(AuditLog(
                    user_id=admin.id,
                    action="verified_document",
                    entity_type="document",
                    entity_id=document.id,
                    details="Seeded demonstration document accepted.",
                ))

    db.commit()


if __name__ == "__main__":
    from app.db import SessionLocal, init_db

    init_db()
    db = SessionLocal()
    try:
        seed_demo_data(db)
        print("TraceBack demo seed completed.")
    finally:
        db.close()
