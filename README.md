# TraceBack

TraceBack is a QR-based food traceability platform for customers, producers, and verifiers. It combines a FastAPI backend, SQLAlchemy + PostgreSQL data model, and a Flutter mobile client.

## Project structure

- `backend/` — FastAPI application, SQLAlchemy models, JWT auth, seed data, and PDF report generation.
- `mobile/` — Flutter mobile app built with Material 3.
- `docker-compose.yml` — PostgreSQL + backend container setup.

## Quick start

### 1) Start PostgreSQL and the API

```bash
docker compose up --build
```

The backend will be available at http://localhost:8000 and the API docs at http://localhost:8000/docs.

### 2) Seeded demo accounts

- Admin: admin@traceback.app / admin123
- Producer: producer@traceback.app / producer123
- Customer: customer@traceback.app / customer123

### 3) Run the Flutter app

```bash
cd mobile
flutter pub get
flutter run
```

## Backend notes

- Python FastAPI server with JWT auth and role checks
- PostgreSQL database configured through `DATABASE_URL`
- SQLAlchemy ORM and Alembic migration scaffold
- Product transparency score computed from real records
- Demo product and supply-chain data included
- Product images and private documents use persistent local storage under `UPLOAD_DIR`
- Producer image/document uploads are multipart requests; document downloads require the
  owning producer or an admin/verifier session

## Flutter notes

- Material 3 design using a forest green/cream palette
- Login, registration, home dashboard, QR scan, product detail, and admin screens
- Secure token storage with `flutter_secure_storage`
- API integration through a central service layer

## Database setup

Create a PostgreSQL database and role, then configure `backend/.env`:

```env
DATABASE_URL=postgresql+psycopg2://traceback:traceback@localhost:5432/traceback
SECRET_KEY=<use-a-long-random-secret>
ALGORITHM=HS256
APP_ENV=development
UPLOAD_DIR=./uploads
```

Demo records are intentionally separate from application startup. Seed or refresh the
idempotent demonstration catalog with:

```bash
cd backend
.venv\Scripts\python.exe -m app.seed
```

On Linux/macOS use the equivalent virtual-environment Python executable.

Before database migrations or destructive maintenance, create a PostgreSQL backup:

```bash
pg_dump -h 127.0.0.1 -U traceback -d traceback -Fc -f traceback-backup.dump
```

The document-title migration must be applied to an existing database after taking a fresh
backup:

```bash
cd backend
.venv\Scripts\alembic.exe upgrade head
```

Product image uploads are available at `POST /products/{product_id}/image` and can be
removed at `DELETE /products/{product_id}/image`. Producers submit documents through
`POST /documents` using multipart form fields `product_id`, `title`, `document_type`,
and `file`. Admin/verifier document downloads use `GET /documents/{document_id}/file`.
Uploaded product photos are served from `/uploads/products/`; uploaded documents are
never mounted as public static files.

## API startup

```bash
cd backend
.venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

Important endpoints include `/auth/login`, `/auth/me`, `/products`, `/products/mine`,
`/batches/{batch_id}`, `/batches/qr/{qr_code}`, `/admin/users`, `/admin/products`,
`/admin/documents`, `/admin/documents/{document_id}/verify`, `/admin/stats`, and
`/admin/audit-logs`.

## Testing

```bash
cd mobile
flutter pub get
flutter analyze
flutter test
```

## Demo accounts

- Admin: `admin@traceback.app`
- Producer: `producer@traceback.app`
- Customer: `customer@traceback.app`

The passwords are local demonstration credentials. Do not use them for production
data or expose real credentials in source control.
