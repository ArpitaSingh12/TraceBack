"""Add a distinct document title.

Revision ID: 20261118_01
"""

from alembic import op
import sqlalchemy as sa

revision = "20261118_01"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    inspector = sa.inspect(op.get_bind())
    if not inspector.has_table("documents"):
        return
    if "title" not in {column["name"] for column in inspector.get_columns("documents")}:
        op.add_column(
            "documents",
            sa.Column("title", sa.String(length=200), nullable=False, server_default=""),
        )
        op.execute("UPDATE documents SET title = file_name WHERE title = ''")
        op.alter_column("documents", "title", server_default=None)


def downgrade() -> None:
    inspector = sa.inspect(op.get_bind())
    if inspector.has_table("documents") and "title" in {
        column["name"] for column in inspector.get_columns("documents")
    }:
        op.drop_column("documents", "title")
