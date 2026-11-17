from __future__ import annotations

import tempfile
import unittest
from datetime import date
from pathlib import Path

from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app import deps
from app.config import settings
from app.db import Base
from app.main import app
from app.models import Product, User


class UploadApiTests(unittest.TestCase):
    def setUp(self) -> None:
        self.upload_root = tempfile.TemporaryDirectory()
        self.previous_upload_dir = settings.upload_dir
        settings.upload_dir = self.upload_root.name
        self.engine = create_engine(
            "sqlite://",
            connect_args={"check_same_thread": False},
            poolclass=StaticPool,
        )
        Base.metadata.create_all(bind=self.engine)
        self.session_factory = sessionmaker(bind=self.engine)
        with self.session_factory() as db:
            producer = User(
                name="Producer One",
                email="producer-one@example.test",
                password_hash="test",
                role="producer",
            )
            other_producer = User(
                name="Producer Two",
                email="producer-two@example.test",
                password_hash="test",
                role="producer",
            )
            admin = User(
                name="Verifier",
                email="admin@example.test",
                password_hash="test",
                role="admin",
            )
            db.add_all([producer, other_producer, admin])
            db.flush()
            self.producer_id = producer.id
            self.other_producer_id = other_producer.id
            self.admin_id = admin.id
            product = Product(
                name="Test Honey",
                description="Test product",
                category="Honey",
                brand="Test Farm",
                batch_number="HNY-TEST-1",
                manufacturing_date=date(2026, 1, 1),
                origin_location="Test location",
                producer_id=producer.id,
            )
            db.add(product)
            db.commit()
            self.product_id = product.id

        self.current_user = User(
            id=self.producer_id,
            name="Producer One",
            email="producer-one@example.test",
            password_hash="test",
            role="producer",
        )

        def override_db():
            db = self.session_factory()
            try:
                yield db
            finally:
                db.close()

        app.dependency_overrides[deps.get_db] = override_db
        app.dependency_overrides[deps.get_current_user] = lambda: self.current_user
        self.client = TestClient(app)

    def tearDown(self) -> None:
        self.client.close()
        app.dependency_overrides.clear()
        settings.upload_dir = self.previous_upload_dir
        self.engine.dispose()
        self.upload_root.cleanup()

    def test_document_upload_is_persisted_pending_and_private(self) -> None:
        response = self.client.post(
            "/documents",
            data={
                "product_id": str(self.product_id),
                "title": "Purity assay",
                "document_type": "Lab Test Report",
            },
            files={"file": ("../assay.pdf", b"%PDF-1.7\nsample", "application/pdf")},
        )
        self.assertEqual(response.status_code, 201, response.text)
        document = response.json()
        self.assertEqual(document["status"], "pending")
        self.assertEqual(document["title"], "Purity assay")
        self.assertEqual(document["file_name"], "assay.pdf")
        self.assertEqual(document["product_id"], self.product_id)
        stored_files = list((Path(settings.upload_dir) / "documents").iterdir())
        self.assertEqual(len(stored_files), 1)
        self.assertEqual(stored_files[0].read_bytes(), b"%PDF-1.7\nsample")

        downloaded = self.client.get(f"/documents/{document['id']}/file")
        self.assertEqual(downloaded.status_code, 200)
        self.assertEqual(downloaded.content, b"%PDF-1.7\nsample")

        self.current_user = User(
            id=self.other_producer_id,
            name="Producer Two",
            email="producer-two@example.test",
            password_hash="test",
            role="producer",
        )
        forbidden = self.client.get(f"/documents/{document['id']}/file")
        self.assertEqual(forbidden.status_code, 403)

        self.current_user = User(
            id=self.admin_id,
            name="Verifier",
            email="admin@example.test",
            password_hash="test",
            role="admin",
        )
        self.assertEqual(self.client.get(f"/documents/{document['id']}/file").status_code, 200)

    def test_product_image_upload_replaces_the_file_and_checks_ownership(self) -> None:
        image_bytes = b"\xff\xd8\xfffake-jpeg-data"
        first = self.client.post(
            f"/products/{self.product_id}/image",
            files={"image": ("photo.jpg", image_bytes, "image/jpeg")},
        )
        self.assertEqual(first.status_code, 200, first.text)
        first_url = first.json()["image_url"]
        self.assertTrue(first_url.startswith("/uploads/products/"))
        first_path = Path(settings.upload_dir) / "products" / first_url.rsplit("/", 1)[-1]
        self.assertEqual(first_path.read_bytes(), image_bytes)

        second = self.client.post(
            f"/products/{self.product_id}/image",
            files={"image": ("replacement.jpg", image_bytes + b"2", "image/jpeg")},
        )
        self.assertEqual(second.status_code, 200, second.text)
        self.assertFalse(first_path.exists())

        self.current_user = User(
            id=self.other_producer_id,
            name="Producer Two",
            email="producer-two@example.test",
            password_hash="test",
            role="producer",
        )
        forbidden = self.client.post(
            f"/products/{self.product_id}/image",
            files={"image": ("replacement.jpg", image_bytes, "image/jpeg")},
        )
        self.assertEqual(forbidden.status_code, 403)

    def test_upload_rejects_mime_mismatch(self) -> None:
        response = self.client.post(
            "/documents",
            data={
                "product_id": str(self.product_id),
                "title": "Invalid file",
                "document_type": "Lab Test Report",
            },
            files={"file": ("assay.pdf", b"\xff\xd8\xffnot-pdf", "image/jpeg")},
        )
        self.assertEqual(response.status_code, 415)


if __name__ == "__main__":
    unittest.main()
