from __future__ import annotations

import hashlib
import re
import uuid
from dataclasses import dataclass
from pathlib import Path, PurePosixPath

from fastapi import HTTPException, UploadFile, status

from app.config import settings

MAX_PRODUCT_IMAGE_BYTES = 10 * 1024 * 1024
MAX_DOCUMENT_BYTES = 20 * 1024 * 1024

_UPLOAD_TYPES = {
    "products": {
        ".jpg": ("image/jpeg", b"\xff\xd8\xff"),
        ".jpeg": ("image/jpeg", b"\xff\xd8\xff"),
        ".png": ("image/png", b"\x89PNG\r\n\x1a\n"),
        ".webp": ("image/webp", None),
    },
    "documents": {
        ".pdf": ("application/pdf", b"%PDF-"),
        ".jpg": ("image/jpeg", b"\xff\xd8\xff"),
        ".jpeg": ("image/jpeg", b"\xff\xd8\xff"),
        ".png": ("image/png", b"\x89PNG\r\n\x1a\n"),
    },
}
_GENERATED_NAME = re.compile(r"^[0-9a-f]{32}\.[a-z0-9]+$")


@dataclass(frozen=True)
class StoredUpload:
    stored_name: str
    sha256: str
    original_name: str


def upload_directory(area: str) -> Path:
    if area not in _UPLOAD_TYPES:
        raise ValueError(f"Unknown upload area: {area}")
    return (Path(settings.upload_dir).expanduser().resolve() / area)


def ensure_upload_directories() -> None:
    for area in _UPLOAD_TYPES:
        upload_directory(area).mkdir(parents=True, exist_ok=True)


def safe_original_name(filename: str | None) -> str:
    if not filename:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="A filename is required")
    name = PurePosixPath(filename.replace("\\", "/")).name.strip()
    if not name or name in {".", ".."} or len(name) > 200:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid filename")
    return name


def _signature_is_valid(extension: str, header: bytes) -> bool:
    expected = _UPLOAD_TYPES["products"].get(extension) or _UPLOAD_TYPES["documents"].get(extension)
    if expected is None:
        return False
    signature = expected[1]
    if signature is not None:
        return header.startswith(signature)
    return len(header) >= 12 and header.startswith(b"RIFF") and header[8:12] == b"WEBP"


async def store_upload(upload: UploadFile, area: str, max_bytes: int) -> StoredUpload:
    types = _UPLOAD_TYPES.get(area)
    if types is None:
        raise ValueError(f"Unknown upload area: {area}")

    original_name = safe_original_name(upload.filename)
    extension = PurePosixPath(original_name).suffix.lower()
    expected = types.get(extension)
    if expected is None:
        allowed = ", ".join(sorted(types))
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail=f"Unsupported file extension. Allowed: {allowed}",
        )
    if (upload.content_type or "").lower() != expected[0]:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail=f"File MIME type must be {expected[0]}",
        )

    directory = upload_directory(area)
    directory.mkdir(parents=True, exist_ok=True)
    stored_name = f"{uuid.uuid4().hex}{extension}"
    path = directory / stored_name
    digest = hashlib.sha256()
    header = bytearray()
    size = 0
    valid = False

    try:
        with path.open("xb") as target:
            while chunk := await upload.read(64 * 1024):
                size += len(chunk)
                if size > max_bytes:
                    raise HTTPException(
                        status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                        detail=f"File exceeds the {max_bytes // (1024 * 1024)} MB size limit",
                    )
                if len(header) < 12:
                    header.extend(chunk[: 12 - len(header)])
                digest.update(chunk)
                target.write(chunk)
        if size == 0:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="The uploaded file is empty")
        if not _signature_is_valid(extension, bytes(header)):
            raise HTTPException(
                status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
                detail="File contents do not match the declared file type",
            )
        valid = True
        return StoredUpload(stored_name, digest.hexdigest(), original_name)
    finally:
        if not valid and path.exists():
            path.unlink()


def resolve_stored_file(area: str, stored_name: str) -> Path:
    if (
        area not in _UPLOAD_TYPES
        or not stored_name
        or PurePosixPath(stored_name.replace("\\", "/")).name != stored_name
    ):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="File not found")
    path = upload_directory(area) / stored_name
    if not path.is_file() or path.parent.resolve() != upload_directory(area):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="File not found")
    return path


def remove_stored_file(area: str, stored_name: str | None) -> None:
    if not stored_name or not _GENERATED_NAME.fullmatch(stored_name):
        return
    path = upload_directory(area) / stored_name
    if path.parent.resolve() == upload_directory(area) and path.exists():
        path.unlink()
