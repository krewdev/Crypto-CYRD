"""mpc tables

Revision ID: 20250916_000002
Revises: 20250916_000001
Create Date: 2025-09-16 00:30:00.000000

"""
from alembic import op
import sqlalchemy as sa


revision = "20250916_000002"
down_revision = "20250916_000001"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "mpc_wallets",
        sa.Column("wallet_id", sa.String(), primary_key=True),
        sa.Column("user_id", sa.String(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()")),
    )
    op.create_index("ix_mpc_wallets_user", "mpc_wallets", ["user_id"], unique=False)

    op.create_table(
        "mpc_key_shares",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("wallet_id", sa.String(), nullable=False),
        sa.Column("share_type", sa.String(), nullable=False),
        sa.Column("provider", sa.String(), nullable=True),
        sa.Column("share_encrypted", sa.Text(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()")),
    )
    op.create_index("ix_mpc_shares_wallet", "mpc_key_shares", ["wallet_id"], unique=False)

    op.create_table(
        "trusted_contacts",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("user_id", sa.String(), nullable=False),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("method", sa.String(), nullable=False),
        sa.Column("value", sa.String(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()")),
    )
    op.create_index("ix_contacts_user", "trusted_contacts", ["user_id"], unique=False)

    op.create_table(
        "recovery_requests",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("user_id", sa.String(), nullable=False),
        sa.Column("status", sa.String(), nullable=False, server_default=sa.text("'pending'")),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()")),
    )
    op.create_index("ix_recovery_user", "recovery_requests", ["user_id"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_recovery_user", table_name="recovery_requests")
    op.drop_table("recovery_requests")
    op.drop_index("ix_contacts_user", table_name="trusted_contacts")
    op.drop_table("trusted_contacts")
    op.drop_index("ix_mpc_shares_wallet", table_name="mpc_key_shares")
    op.drop_table("mpc_key_shares")
    op.drop_index("ix_mpc_wallets_user", table_name="mpc_wallets")
    op.drop_table("mpc_wallets")
