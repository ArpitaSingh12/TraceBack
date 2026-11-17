from __future__ import annotations

from app.models import Product


def compute_transparency_score(product: Product) -> int:
    score = 0
    breakdown = {
        "origin": 20,
        "producer": 15,
        "processing": 20,
        "packaging": 15,
        "documents": 20,
        "verification": 10,
    }

    if product.origin_location:
        score += breakdown["origin"]
    if product.producer_id:
        score += breakdown["producer"]
    if product.batches and any(batch.events for batch in product.batches):
        score += breakdown["processing"]
    if product.batches and any(batch.events for batch in product.batches):
        score += breakdown["packaging"]
    if product.documents:
        score += breakdown["documents"]
    if any(doc.status == "verified" for doc in product.documents):
        score += breakdown["verification"]

    return min(score, 100)
